//
//  ASIFormDataRequestTests.m
//  asi-http-request
//
//  Created by Ben Copsey on 08/11/2008.
//  Copyright 2008 All-Seeing Interactive. All rights reserved.
//

#import "ASIFormDataRequestTests.h"
#import "ASIFormDataRequest.h"

// Used for subclass test
@interface ASIFormDataRequestSubclass : ASIFormDataRequest {}
@end
@implementation ASIFormDataRequestSubclass;
@end

@implementation ASIFormDataRequestTests

- (void)testPostWithFileUpload
{
	NSURL *url = [NSURL URLWithString:@"http://allseeing-i.com/ASIHTTPRequest/tests/post"];
	
	//Create a 32kb file
	unsigned int size = 1024*32;
	NSMutableData *data = [NSMutableData dataWithLength:size];
	NSString *path = [[self filePathForTemporaryTestFiles] stringByAppendingPathComponent:@"bigfile"];
	[data writeToFile:path atomically:NO];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	
	NSDate *d = [NSDate date];
#if TARGET_OS_IPHONE
	NSValue *v = [NSValue valueWithCGRect:CGRectMake(0, 0, 200, 200)];
#else
	NSValue *v = [NSValue valueWithRect:NSMakeRect(0, 0, 200, 200)];	
#endif
	[request setPostValue:@"foo" forKey:@"post_var"];
	[request setPostValue:d forKey:@"post_var2"];
	[request setPostValue:v forKey:@"post_var3"];
	[request setFile:path forKey:@"file"];
	[request start];

	BOOL success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"post_var: %@\r\npost_var2: %@\r\npost_var3: %@\r\nfile_name: %@\r\nfile_size: %hu\r\ncontent_type: %@",@"foo",d,v,@"bigfile",size,@"application/octet-stream"]]);
	GHAssertTrue(success,@"Failed to upload the correct data (using local file)");	
	
	//Try the same with the raw data
	request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setPostValue:@"foo" forKey:@"post_var"];
	[request setPostValue:d forKey:@"post_var2"];
	[request setPostValue:v forKey:@"post_var3"];
	[request setData:data forKey:@"file"];
	[request start];

	success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"post_var: %@\r\npost_var2: %@\r\npost_var3: %@\r\nfile_name: %@\r\nfile_size: %hu\r\ncontent_type: %@",@"foo",d,v,@"file",size,@"application/octet-stream"]]);
	GHAssertTrue(success,@"Failed to upload the correct data (using NSData)");	

	//Post with custom content-type and file name
	request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setPostValue:@"foo" forKey:@"post_var"];
	[request setPostValue:d forKey:@"post_var2"];
	[request setPostValue:v forKey:@"post_var3"];	
	[request setFile:path withFileName:@"myfile" andContentType:@"text/plain" forKey:@"file"];
	[request start];
	
	success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"post_var: %@\r\npost_var2: %@\r\npost_var3: %@\r\nfile_name: %@\r\nfile_size: %hu\r\ncontent_type: %@",@"foo",d,v,@"myfile",size,@"text/plain"]]);
	GHAssertTrue(success,@"Failed to send the correct content-type / file name");	
	
	//Post raw data with custom content-type and file name
	request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setPostValue:@"foo" forKey:@"post_var"];
	[request setPostValue:d forKey:@"post_var2"];
	[request setPostValue:v forKey:@"post_var3"];	
	[request setData:data withFileName:@"myfile" andContentType:@"text/plain" forKey:@"file"];
	[request start];
	
	success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"post_var: %@\r\npost_var2: %@\r\npost_var3: %@\r\nfile_name: %@\r\nfile_size: %hu\r\ncontent_type: %@",@"foo",d,v,@"myfile",size,@"text/plain"]]);
	GHAssertTrue(success,@"Failed to send the correct content-type / file name");	
	
}

// Test fix for bug where setting an empty string for a form post value would cause the rest of the post body to be ignored (because an NSOutputStream won't like it if you try to write 0 bytes)
- (void)testEmptyData
{
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://allseeing-i.com/ASIHTTPRequest/tests/post-empty"]];
	[request setPostValue:@"hello" forKey:@"a_non_empty_string"];
	[request setPostValue:@"" forKey:@"zzz_empty_string"];
	[request setPostValue:@"there" forKey:@"xxx_non_empty_string"];
	[request setShouldStreamPostDataFromDisk:YES];
	[request buildPostBody];
	[request start];
	
	BOOL success = ([[request responseString] isEqualToString:@"a_non_empty_string: hello\r\nzzz_empty_string: \r\nxxx_non_empty_string: there"]);
	GHAssertTrue(success,@"Failed to send the correct post data");		
	
}

// Ensure class convenience constructor returns an instance of our subclass
- (void)testSubclass
{
	ASIFormDataRequestSubclass *instance = [ASIFormDataRequestSubclass requestWithURL:[NSURL URLWithString:@"http://allseeing-i.com"]];
	BOOL success = [instance isKindOfClass:[ASIFormDataRequestSubclass class]];
	GHAssertTrue(success,@"Convenience constructor failed to return an instance of the correct class");	
}

- (void)testURLEncodedPost
{
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://allseeing-i.com/ASIHTTPRequest/tests/url-encoded-post"]];
	[request setPostValue:@"value1" forKey:@"value1"];
	[request setPostValue:@"(%20 ? =)" forKey:@"value2"];
	[request setPostValue:@"£100.00" forKey:@"value3"];
	[request setPostValue:@"" forKey:@"value4"];
	[request setPostValue:@"&??aaa=//ciaoèèè" forKey:@"teskey&aa"]; 
	
	[request setShouldStreamPostDataFromDisk:YES];
	[request setPostFormat:ASIURLEncodedPostFormat];
	[request start];

	
	BOOL success = ([[request responseString] isEqualToString:@"value1: value1\r\nvalue2: (%20 ? =)\r\nvalue3: £100.00\r\nvalue4: \r\nteskey&aa: &??aaa=//ciaoèèè"]);
	GHAssertTrue(success,@"Failed to send the correct post data");			
}

- (void)testCharset
{
	NSURL *url = [NSURL URLWithString:@"http://allseeing-i.com/ASIHTTPRequest/tests/formdata-charset"];
	NSString *testString = @"£££s don't seem to buy me many €€€s these days";
	
	// Test the default (UTF-8) with a url-encoded request
	NSString *charset = @"utf-8";
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:testString forKey:@"value"];
	[request start];
	BOOL success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"Got data in %@: %@",charset,testString]]);
	GHAssertTrue(success,@"Failed to correctly encode the data");	
	
	// Test the default (UTF-8) with a multipart/form-data request
	request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:testString forKey:@"value"];
	[request setPostFormat:ASIMultipartFormDataPostFormat];
	[request start];
	success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"Got data in %@: %@",charset,testString]]);
	GHAssertTrue(success,@"Failed to correctly encode the data");
	
	// Test a different charset
	testString = @"£££s don't seem to buy me many $$$s these days";
	charset = @"iso-8859-1";
	request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:testString forKey:@"value"];
	[request setStringEncoding:NSISOLatin1StringEncoding];
	[request start];
	success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"Got data in %@: %@",charset,testString]]);
	GHAssertTrue(success,@"Failed to correctly encode the data");	
	
	// And again with multipart/form-data request
	request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:testString forKey:@"value"];
	[request setPostFormat:ASIMultipartFormDataPostFormat];
	[request setStringEncoding:NSISOLatin1StringEncoding];
	[request start];
	success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"Got data in %@: %@",charset,testString]]);
	GHAssertTrue(success,@"Failed to correctly encode the data");	
	
	// Once more for luck
	charset = @"windows-1252";
	request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:testString forKey:@"value"];
	[request setStringEncoding:NSWindowsCP1252StringEncoding];
	[request start];
	success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"Got data in %@: %@",charset,testString]]);
	GHAssertTrue(success,@"Failed to correctly encode the data");

	request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:testString forKey:@"value"];
	[request setPostFormat:ASIMultipartFormDataPostFormat];
	[request setStringEncoding:NSWindowsCP1252StringEncoding];
	[request start];
	success = ([[request responseString] isEqualToString:[NSString stringWithFormat:@"Got data in %@: %@",charset,testString]]);
	GHAssertTrue(success,@"Failed to correctly encode the data");	

}



@end
