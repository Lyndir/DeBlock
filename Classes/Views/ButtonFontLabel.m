//
//  ButtonFontLabel.m
//  Deblock
//
//  Created by Maarten Billemont on 18/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ButtonFontLabel.h"


@implementation ButtonFontLabel

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame zFont:(ZFont *)font {
    
    if ((self = [super initWithFrame:frame zFont:font]))
        self.userInteractionEnabled = YES;
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([touches count] == 1) {
        CGPoint touchPoint = [(UITouch *)[touches anyObject] locationInView:self];
        if ([self pointInside:touchPoint withEvent:event])
            [self.delegate touched];
    }
}

@end
