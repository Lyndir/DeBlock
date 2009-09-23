//
//  PlayerViewController.m
//  Deblock
//
//  Created by Maarten Billemont on 17/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "PlayerViewController.h"
#import "DeblockAppDelegate.h"


@interface PlayerViewController ()

@property (readwrite, retain) UITextField           *playerField;

@end


@implementation PlayerViewController

@synthesize playerField;

- (void)loadView {
    
    self.view                           = [[[UIView alloc] initWithFrame:
                                            [[UIScreen mainScreen] applicationFrame]] autorelease];
    self.view.backgroundColor           = [UIColor colorWithPatternImage:
                                           [UIImage imageNamed:@"splash_notitle.png"]];
    
    self.playerField                    = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
    self.playerField.textAlignment      = UITextAlignmentCenter;
    self.playerField.font               = [UIFont fontWithName:@"Courier" size:[[Config get].largeFontSize intValue]];
    self.playerField.text               = @"lhunath";
    [self.playerField sizeToFit];
    self.playerField.center             = ccp(self.view.center.x, 100);
    self.playerField.autoresizingMask   = UIViewAutoresizingFlexibleWidth;
    self.playerField.delegate           = self;
    [self.view addSubview:self.playerField];
    
    ButtonFontLabel *nextButton         = [[ButtonFontLabel alloc] initWithFrame:CGRectZero
                                                                  fontName:[Config get].fontName
                                                                 pointSize:[[Config get].fontSize intValue]];
    nextButton.backgroundColor          = [UIColor clearColor];
    nextButton.textColor                = [UIColor whiteColor];
    nextButton.text                     = @"   >   ";
    nextButton.center                   = ccp(410, 140);
    nextButton.delegate                 = self;
    [nextButton sizeToFit];
    [self.view addSubview:nextButton];
    [nextButton release];
}

- (void)touched {
    
    if (!self.playerField.text.length) {
        [AudioController vibrate];
        return;
    }
    
    [DMConfig get].userName = self.playerField.text;
    [[DeblockAppDelegate get] showDirector];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (![textField.text length])
        return NO;
    
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    [super dealloc];
}


@end
