//
//  LogLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 15/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "LogLayer.h"
#import "ScrollLayer.h"


@implementation LogLayer


- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    self.background = [Sprite spriteWithFile:@"splash.png"];
    logLabel = [[Label alloc] initWithString:@"" dimensions:CGSizeMake(self.contentSize.width * 0.8f, 1000)
                                   alignment:UITextAlignmentLeft fontName:[Config get].fixedFontName fontSize:[[Config get].smallFontSize intValue]];
    logLabel.anchorPoint = CGPointZero;
    
    ScrollLayer *scrollLayer    = [ScrollLayer scrollNode:logLabel direction:ScrollContentDirectionTopToBottom];
    Layer *log                  = [Layer node];
    [log addChild:scrollLayer];
    scrollLayer.contentSize     = CGSizeMake(logLabel.contentSize.width, self.contentSize.height * 0.7f);
    log.position                = ccp((self.contentSize.width - scrollLayer.contentSize.width) * 0.5f,
                                      (self.contentSize.height - scrollLayer.contentSize.height) * 0.7f);
    logLabel.position           = ccp(0, scrollLayer.contentSize.height - logLabel.contentSize.height);
    
    [self addChild:log];
    
    return self;
}

- (void)onEnter {

    NSString *newLogString = [[Logger get] formatMessages];
    if (![logString isEqualToString:newLogString]) {
        [logLabel setString:newLogString];
        [logString release];
        logString = [newLogString retain];
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

+ (LogLayer *)get {
    
    static LogLayer *logLayer = nil;
    if (logLayer == nil)
        logLayer = [self new];
    
    return logLayer;
}

@end
