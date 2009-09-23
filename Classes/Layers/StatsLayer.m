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
    
    self.background = [Sprite spriteWithFile:@"splash.png"];

    NSMutableArray *scores = [NSMutableArray arrayWithCapacity:[[DMConfig get].userScoreHistory count]];
    for (NSString *user in [[DMConfig get].userScoreHistory allKeys]) {
        NSDictionary *userScores = [[DMConfig get].userScoreHistory objectForKey:user];
        NSNumber *topUserScore = nil;
        NSDate *topUserScoreDate = nil;

        for (NSString *dateEncoded in [userScores allKeys]) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dateEncoded floatValue]];
            NSNumber *currentUserScore = [userScores objectForKey:dateEncoded];
            if (!topUserScore || [currentUserScore compare:topUserScore] == NSOrderedDescending) {
                topUserScore = currentUserScore;
                topUserScoreDate = date;
            }
        }
        
        [scores addObject:[Score scoreWithScore:[topUserScore intValue] by:user at:topUserScoreDate]];
    }
    
    graph = [[GraphNode alloc] initWithArray:scores];
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
