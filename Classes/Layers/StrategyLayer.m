//
//  StrategyLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 23/10/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "StrategyLayer.h"


@implementation StrategyLayer


- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    guide = [[FlickLayer alloc] initWithSprites:
             [Sprite spriteWithFile:@"strategy-1.png"],
             [Sprite spriteWithFile:@"strategy-2.png"],
             [Sprite spriteWithFile:@"strategy-3.png"],
             [Sprite spriteWithFile:@"strategy-4.png"],
             [Sprite spriteWithFile:@"strategy-5.png"],
             [Sprite spriteWithFile:@"strategy-6.png"],
             [Sprite spriteWithFile:@"strategy-7.png"],
             nil];
    [self addChild:guide];
    
    return self;
}

@end
