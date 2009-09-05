/*
 * This file is part of Deblock.
 *
 *  Deblock is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Deblock is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Deblock in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

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
    
    graph = [[GraphNode alloc] initWithArray:[NSArray arrayWithObjects:
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              [Score scoreWithScore:random() % 200
                                                                 by:@"lhunath"
                                                                 at:[NSDate dateWithTimeIntervalSinceNow:random() % 10000]],
                                              nil]];
    [self addChild:graph];
    
    return self;
}

+ (StatsLayer *)get {

    static StatsLayer *statsLayer = nil;
    if (statsLayer == nil)
        statsLayer = [self new];

    return statsLayer;
}


@end
