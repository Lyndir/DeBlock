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
#import "DeblockWSController.h"
#import "MenuItemSymbolic.h"


@interface ScoresLayer ()

- (void)wsButton;
- (void)checkWS;

@property (readwrite, retain) GraphNode             *graph;
@property (readwrite, retain) ActivitySprite        *wheel;

@end


@implementation ScoresLayer

@synthesize graph = _graph, wheel = _wheel;


- (id)init {

    if (!(self = [super init]))
        return nil;
    
    CGSize winSize                  = [Director sharedDirector].winSize;
    self.background                 = [Sprite spriteWithFile:@"back.png"];
    
    self.graph                      = [GraphNode node];
    self.graph.contentSize          = CGSizeMake((int)(winSize.width * 0.9f), (int)(winSize.height * 0.6f));
    self.graph.position             = ccp((int)((winSize.width - self.graph.contentSize.width) / 2),
                                          (int)((winSize.height - self.graph.contentSize.height) / 1.5f));
    [self addChild:self.graph];
    
    [self setNextButton:[MenuItemSymbolic itemFromString:@"  ⟳  "]];

    self.wheel = [ActivitySprite node];
    self.wheel.position = _nextMenu.position;
    [self addChild:self.wheel];
    
    [self schedule:@selector(checkWS) interval:0.5f];
    
    return self;
}

- (void)onEnter {

    [self reset];
    
    [self checkWS];
    
    [super onEnter];
}

- (void)reset {
    
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
    
    [self.graph setScores:scores];
}

- (void)checkWS {
    
    self.wheel.visible = [DeblockWSController get].submittingScores;

    if ([DeblockWSController get].submittingScores)
        [self setNextButtonTarget:nil selector:nil];
    else
        [self setNextButtonTarget:self selector:@selector(wsButton)];
    
}

- (void)wsButton {
    
    [[DeblockWSController get] reloadScores];
    [self checkWS];
}

+ (ScoresLayer *)get {

    static ScoresLayer *scoresLayer = nil;
    if (scoresLayer == nil)
        scoresLayer = [self new];

    return scoresLayer;
}


- (void)dealloc {

    self.graph = nil;

    [super dealloc];
}

@end
