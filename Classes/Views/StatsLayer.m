//
//  StatsLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 03/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "StatsLayer.h"


@implementation StatsLayer


- (id)init {

    if (!(self = [super init]))
        return nil;
    
    
    
    return self;
}

+ (StatsLayer *)get {

    static StatsLayer *statsLayer = nil;
    if (statsLayer == nil)
        statsLayer = [self new];

    return statsLayer;
}


@end
