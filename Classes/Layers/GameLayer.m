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
//  GameLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//


#import "GameLayer.h"
#import "DeblockAppDelegate.h"


@interface GameLayer ()

- (void)setPausedSilently:(BOOL)_paused;
- (void)increaseTimedPenalty:(ccTime)dt;

@property (readwrite, assign) DbEndReason                                         endReason;

@property (nonatomic, readwrite, retain) SkyLayer                                 *skyLayer;
@property (nonatomic, readwrite, retain) FieldLayer                               *fieldLayer;
@property (readwrite, retain) CCLayer                                             *fieldScroller;

@property (readwrite, retain) CCAction                                            *shakeAction;

@property (readwrite, assign) ccTime                                              penaltyInterval;
@property (readwrite, assign) ccTime                                              remainingPenaltyTime;

@end

@implementation GameLayer

@synthesize paused = _paused;
@synthesize running = _running;
@synthesize endReason = _endReason;
@synthesize skyLayer = _skyLayer;
@synthesize fieldLayer = _fieldLayer;
@synthesize fieldScroller = _fieldScroller;
@synthesize shakeAction = _shakeAction;
@synthesize penaltyInterval = _penaltyInterval;
@synthesize remainingPenaltyTime = _remainingPenaltyTime;


#pragma mark Properties



-(void) setPaused:(BOOL)isPaused {

    if(self.paused == isPaused)
        // Nothing changed.
        return;
    
    [self setPausedSilently:isPaused];
    
    if(self.running) {
        if(self.paused)
            [[DeblockAppDelegate get].uiLayer message:l(@"message.paused")];
        
        else
            [[DeblockAppDelegate get].uiLayer message:l(@"message.unpaused")];
    }
}


-(void) setPausedSilently:(BOOL)isPaused {
    
    _paused = isPaused;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!self.paused withAnimation:YES];
    
    if(self.paused) {
        [self unschedule:@selector(increaseTimedPenalty:)];
        [self.fieldScroller runAction:[CCMoveTo actionWithDuration:0.5f
                                                position:CGPointMake(0, self.fieldScroller.contentSize.height)]];
    } else {
        [self schedule:@selector(increaseTimedPenalty:) interval:0.1f];
        [[DeblockAppDelegate get] popAllLayers];
        [self.fieldScroller runAction:[CCMoveTo actionWithDuration:0.5f
                                                   position:CGPointZero]];
    }
}


#pragma mark Interact

- (void)reset {
    
    [self.skyLayer reset];
    [self.fieldLayer reset];
}


- (void)shake {
    
    if ([[Config get].vibration boolValue])
        [AudioController vibrate];
    
    [self.fieldLayer runAction:self.shakeAction];
}


- (void)newGameWithMode:(DbMode)gameMode {
    
    [Player currentPlayer].score = 0;
    [Player currentPlayer].level = 1;
    [Player currentPlayer].mode = gameMode;
    
    [self startGame];
}

- (void)startGame {

    if(self.running) {
        [[Logger get] wrn:@"WARN: Tried to start a game while one's still running."];
        return;
    }
    
    self.endReason                           = DbEndReasonEnded;
    self.penaltyInterval                     = 2;
    [DeblockConfig get].levelScore      = [NSNumber numberWithInt:0];
    [DeblockConfig get].levelPenalty    = [NSNumber numberWithInt:0];
    [[DeblockAppDelegate get].hudLayer updateHudWasGood:YES];
    
    // Reset the game field and start the game.
    [self reset];
    [self.fieldLayer startGame];
}


- (void)levelRedo {

    [self stopGame:DbEndReasonNextField];
}


- (void)stopGame:(DbEndReason)reason {
    
    self.endReason = reason;
    [self setPausedSilently:NO];

    self.running = NO;

    [self.fieldLayer stopGame];
}


#pragma mark Internal

- (id)init {
    
	if (!(self = [super init]))
		return self;

    self.running                = NO;
    
    CCActionInterval *l         = [CCMoveBy actionWithDuration:.05f position:ccp(-3, 0)];
    CCActionInterval *r         = [CCMoveBy actionWithDuration:.05f position:ccp(6, 0)];
    self.shakeAction            = [CCSequence actions:l, r, l, l, r, l, r, l, l, nil];
    
    // Set up our own layer.
    self.anchorPoint            = ccp(0.5f, 0.5f);
    
    // Sky and field.
    self.fieldLayer             = [FieldLayer node];
    self.skyLayer               = [SkyLayer node];
    
    self.fieldLayer.contentSize = CGSizeMake(self.contentSize.width * 9/10, self.contentSize.height * 4/5);
    self.fieldLayer.position    = ccp((self.contentSize.width - self.fieldLayer.contentSize.width) / 2.0f,
                                      (self.contentSize.height - self.fieldLayer.contentSize.height - [DeblockAppDelegate get].hudLayer.contentSize.height) / 2.0f +  [DeblockAppDelegate get].hudLayer.contentSize.height);

    self.fieldScroller          = [CCLayer node];
    [self.fieldScroller addChild:self.fieldLayer];

    [self addChild:self.skyLayer];
    [self addChild:self.fieldScroller z:1];
    
    _paused                     = YES;
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    [self setPausedSilently:YES];
}


-(void) onExit {

    [super onExit];
    
    [self setPausedSilently:YES];
}


-(void) started {

    [[DeblockAppDelegate get].uiLayer message:l(@"message.level", [Player currentPlayer].level)];
    
    self.running = YES;

    [self setPausedSilently:NO];
}


-(void) stopped {
    
    self.running     = NO;

    switch (self.endReason) {
        case DbEndReasonEnded:
            [[DeblockAppDelegate get] showScores];
            break;
        case DbEndReasonStopped:
            [[DeblockAppDelegate get] showMainMenu];
            break;
        case DbEndReasonGameOver:
            [[DeblockAppDelegate get] showGameOverMenu];
            break;
        case DbEndReasonNextField:
            [self startGame];
            break;
        default:
            [NSException raise:NSInternalInconsistencyException
                        format:@"End reason not implemented: %d", self.endReason];
    }
    
    self.endReason   = DbEndReasonEnded;
}


- (void)increaseTimedPenalty:(ccTime)dt {
    
    if ([Player currentPlayer].mode != DbModeTimed)
        // Don't increase penalty during non-timed games.
        return;
    if (!self.running || self.paused)
        // Don't increase penalty while game not running or paused.
        return;
    
    self.remainingPenaltyTime        += dt;
    NSInteger penalty           = self.remainingPenaltyTime / self.penaltyInterval;
    self.remainingPenaltyTime        -= penalty * self.penaltyInterval;
    [DeblockConfig get].levelPenalty = [NSNumber numberWithInt:[[DeblockConfig get].levelPenalty intValue] - penalty];
    
    [[DeblockAppDelegate get].hudLayer updateHudWasGood:NO];
}


-(void) dealloc {
    
    self.skyLayer = nil;
    self.fieldLayer = nil;
    
    self.fieldScroller = nil;
    self.shakeAction = nil;

    [super dealloc];
}


@end
