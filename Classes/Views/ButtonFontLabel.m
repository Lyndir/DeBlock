//
//  ButtonFontLabel.m
//  Deblock
//
//  Created by Maarten Billemont on 18/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ButtonFontLabel.h"


@interface ButtonFontLabel ()



@end


@implementation ButtonFontLabel

@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame zFont:(ZFont *)font {
    
    if ((self = [super initWithFrame:frame zFont:font]))
        self.userInteractionEnabled = YES;
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame]))
        self.userInteractionEnabled = YES;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder]))
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
