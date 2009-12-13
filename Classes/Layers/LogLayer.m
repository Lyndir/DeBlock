//
//  LogLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 15/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "LogLayer.h"
#import "ScrollLayer.h"


@interface LogLayer ()

@property (readwrite, retain) Label                   *logLabel;
@property (readwrite, copy) NSString                *logString;

@end


@implementation LogLayer

@synthesize logLabel = _logLabel;
@synthesize logString = _logString;


- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    self.background = [Sprite spriteWithFile:@"back.png"];
    self.logLabel = [Label labelWithString:@"" dimensions:CGSizeMake(self.contentSize.width * 0.8f, 1000)
                                   alignment:UITextAlignmentLeft fontName:[Config get].fixedFontName fontSize:[[Config get].smallFontSize intValue]];
    self.logLabel.anchorPoint = CGPointZero;
    
    ScrollLayer *scrollLayer    = [ScrollLayer scrollNode:self.logLabel direction:ScrollContentDirectionTopToBottom];
    Layer *log                  = [Layer node];
    [log addChild:scrollLayer];
    scrollLayer.contentSize     = CGSizeMake(self.logLabel.contentSize.width, self.contentSize.height * 0.7f);
    log.position                = ccp((self.contentSize.width - scrollLayer.contentSize.width) * 0.5f,
                                      (self.contentSize.height - scrollLayer.contentSize.height) * 0.7f);
    self.logLabel.position           = ccp(0, scrollLayer.contentSize.height - self.logLabel.contentSize.height);
    
    [self addChild:log];
    
    return self;
}

- (void)onEnter {

    NSString *newLogString = [[Logger get] formatMessages];
    if (![self.logString isEqualToString:newLogString]) {
        [self.logLabel setString:newLogString];
        self.logString = newLogString;
    }
    
    [super onEnter];
}


- (void)draw {
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    DrawBoxFrom(CGPointZero, CGPointFromSize(self.contentSize),
                ccc4(0x00, 0x00, 0x00, 0x66), ccc4(0x00, 0x00, 0x00, 0xCC));
    DrawBorderFrom(CGPointZero, CGPointFromSize(self.contentSize),
                   ccc4(0xff, 0xff, 0xff, 0x66), 2);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}

@end
