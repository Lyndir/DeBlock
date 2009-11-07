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
//  ScoresLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 03/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ScoresLayer.h"


@implementation ScoresLayer


- (id)init {

    if (!(self = [super init]))
        return nil;
    
    self.background = [Sprite spriteWithFile:@"splash.png"];
    
    graph = [GraphNode new];
    [self addChild:graph];
    
    return self;
}

- (void)onEnter {
    
    NSMutableArray *scores = [NSMutableArray arrayWithCapacity:[[DeblockConfig get].userScoreHistory count]];
    for (NSString *user in [[DeblockConfig get].userScoreHistory allKeys]) {
        NSDictionary *userScores = [[DeblockConfig get].userScoreHistory objectForKey:user];
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
    
    [graph setScores:scores];
    
    [super onEnter];
}

+ (ScoresLayer *)get {

    static ScoresLayer *scoresLayer = nil;
    if (scoresLayer == nil)
        scoresLayer = [self new];

    return scoresLayer;
}


@end
