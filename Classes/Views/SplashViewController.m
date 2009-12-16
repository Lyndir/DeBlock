//
//  SplashViewController.m
//  Deblock
//
//  Created by Maarten Billemont on 22/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "SplashViewController.h"
#import "PlayerViewController.h"


@interface SplashViewController ()



@end


@implementation SplashViewController

@synthesize top = _top, bottom = _bottom;


- (id)init {
    
    return [self initWithNibName:@"Splash" bundle:nil];
}

- (void)viewDidLoad {

    UIView *playerView = ((PlayerViewController *)[[PlayerViewController new] autorelease]).view;
    [self.view addSubview:playerView];
    [self.view sendSubviewToBack:playerView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    self.top.center     = ccpSub(self.top.center,       ccp(0, self.top.bounds.size.height));
    self.bottom.center  = ccpAdd(self.bottom.center,    ccp(0, self.bottom.bounds.size.height));
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {

    self.top = nil;
    self.bottom = nil;

    [super dealloc];
}

@end
