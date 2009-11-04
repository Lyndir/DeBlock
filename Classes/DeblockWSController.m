//
//  DeblockWSController.m
//  Deblock
//
//  Created by Maarten Billemont on 03/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "DeblockWSController.h"
#import "ASIFormDataRequest.h"
#import "NSDictionary_JSONExtensions.h"

#define dScoreServlet   @"/scores.json"


@implementation DeblockWSController

+ (DeblockWSController *)get {
    
    static DeblockWSController* instance;
    if (!instance)
        instance = [DeblockWSController new];
    
    return instance;
}

- (void)reloadScores {

    [self submitScore:nil forPlayer:nil achievedAt:nil];
}


- (void)submitScore:(NSNumber *)score forPlayer:(NSString *)playerName achievedAt:(NSDate *)achievedDate {

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:dScoreServlet
                                                                            relativeToURL:[NSURL URLWithString:[DMConfig get].wsUrl]]];
    [request setDelegate:self];

    if (score && playerName && achievedDate) {
    NSNumber *timeStamp = [NSNumber numberWithLong:(long)([achievedDate timeIntervalSince1970] * 1000)];
        [request setData:[[score description] dataUsingEncoding:NSUTF8StringEncoding]
                  forKey:@"score"];
        [request setData:[playerName dataUsingEncoding:NSUTF8StringEncoding]
                  forKey:@"name"];
        [request setData:[[timeStamp description] dataUsingEncoding:NSUTF8StringEncoding]
                  forKey:@"name"];
    }
    
    [request startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSError *error = nil;
    NSDictionary *playersScoreHistory = [NSDictionary dictionaryWithJSONData:[request responseData] error:&error];
    if (error)
        NSLog(@"Score response parsing failed: %@", error);
    else {
        [DMConfig get].userScoreHistory = playersScoreHistory;
        NSLog(@"Saved new scores: %@", playersScoreHistory);
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request {

    NSLog(@"Score fetch request failed: %@", request.error);
}


@end
