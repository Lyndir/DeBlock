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


@interface GameLayer (Private)

- (void)setPausedSilently:(BOOL)_paused;
- (void)increaseTimedPenalty:(ccTime)dt;

@end

@implementation GameLayer


#pragma mark Properties

@synthesize paused, running;
@synthesize skyLayer, fieldLayer;


-(void) setPaused:(BOOL)isPaused {

    if(paused == isPaused)
        // Nothing changed.
        return;
    
    [self setPausedSilently:isPaused];
    
    if(running) {
        if(paused){
            [[DeblockAppDelegate get].uiLayer message:NSLocalizedString(@"messages.paused", @"Paused")];
        }
        
        else {
            [[DeblockAppDelegate get].uiLayer message:NSLocalizedString(@"messages.unpaused", @"Unpaused")];
        }
    }
}


-(void) setPausedSilently:(BOOL)isPaused {
    
    paused = isPaused;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!paused animated:YES];
    
    if(paused) {
        [self unschedule:@selector(increaseTimedPenalty:)];
        [[DeblockAppDelegate get] hideHud];
        [fieldScroller runAction:[MoveTo actionWithDuration:0.5f
                                                position:CGPointMake(0, fieldScroller.contentSize.height)]];
    } else {
        [self schedule:@selector(increaseTimedPenalty:) interval:0.1f];
        [[DeblockAppDelegate get] popAllLayers];
        [[DeblockAppDelegate get] revealHud];
        [fieldScroller runAction:[MoveTo actionWithDuration:0.5f
                                                   position:CGPointZero]];
    }
}


#pragma mark Interact

- (void)reset {
    
    [skyLayer reset];
    [fieldLayer reset];
}


- (void)shake {
    
    if ([[Config get].vibration boolValue])
        [AudioController vibrate];
    
    [fieldLayer runAction:shakeAction];
}


- (void)newGameWithMode:(DbMode)gameMode {
    
    [DMConfig get].level = [NSNumber numberWithInt:1];
    [DMConfig get].gameMode = [NSNumber numberWithUnsignedInt:gameMode];
    [[DMConfig get] recordScore:0];
    
    [self startGame];
}

- (void)startGame {

    if(running)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while one's still running."
                                     userInfo:nil];
    endReason                   = DbEndReasonEnded;
    penaltyInterval             = 2;
    [DMConfig get].levelScore   = [NSNumber numberWithInt:0];
    [DMConfig get].levelPenalty = [NSNumber numberWithInt:0];
    [[DeblockAppDelegate get].hudLayer updateHudWithScore:0];
    
    // Reset the game field and start the game.
    [self reset];
    [fieldLayer startGame];
}


- (void)levelRedo {

    [self stopGame:DbEndReasonNextField];
}


- (void)stopGame:(DbEndReason)reason {
    
    endReason = reason;
    [self setPausedSilently:NO];

    running = NO;

    [fieldLayer stopGame];
}


#pragma mark Internal

- (id)init {
    
	if (!(self = [super init]))
		return self;

    running = NO;
    
    IntervalAction *l       = [MoveBy actionWithDuration:.05f position:ccp(-3, 0)];
    IntervalAction *r       = [MoveBy actionWithDuration:.05f position:ccp(6, 0)];
    shakeAction             = [[Sequence actions:l, r, l, l, r, l, r, l, l, nil] retain];
    
    // Set up our own layer.
    self.anchorPoint        = ccp(0.5f, 0.5f);
    
    // Sky and field.
    fieldLayer              = [[FieldLayer alloc] init];
    skyLayer                = [[SkyLayer alloc] init];
    
    fieldLayer.contentSize  = CGSizeMake(self.contentSize.width * 9/10, self.contentSize.height * 4/5);
    fieldLayer.position     = ccp((self.contentSize.width - fieldLayer.contentSize.width) / 2.0f,
                                  (self.contentSize.height - fieldLayer.contentSize.height - [DeblockAppDelegate get].hudLayer.contentSize.height) / 2.0f +  [DeblockAppDelegate get].hudLayer.contentSize.height);

    fieldScroller           = [Layer new];
    [fieldScroller addChild:fieldLayer];
    
    [self addChild:skyLayer z:-1];
    [self addChild:fieldScroller z:1];
    
    paused = YES;
    
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

    [[DeblockAppDelegate get].uiLayer message:[NSString stringWithFormat:@"Level %d", [[DMConfig get].level intValue]]];
    
    running = YES;

    [self setPausedSilently:NO];
}


-(void) stopped {
    
    running     = NO;

    switch (endReason) {
        case DbEndReasonEnded:
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
                        format:@"End reason not implemented: %d", endReason];
    }
    
    endReason   = DbEndReasonEnded;
}


- (void)increaseTimedPenalty:(ccTime)dt {
    
    if ([[DMConfig get].gameMode unsignedIntValue] != DbModeTimed)
        // Don't increase penalty during non-timed games.
        return;
    if (!running || paused)
        // Don't increase penalty while game not running or paused.
        return;
    
    remainingPenaltyTime        += dt;
    NSInteger penalty           = remainingPenaltyTime / penaltyInterval;
    remainingPenaltyTime        -= penalty * penaltyInterval;
    [DMConfig get].levelPenalty = [NSNumber numberWithInt:[[DMConfig get].levelPenalty intValue] - penalty];
    
    [[DeblockAppDelegate get].hudLayer updateHudWithScore:0];
}


-(void) dealloc {
    
    [skyLayer release];
    skyLayer = nil;
    
    [fieldLayer release];
    fieldLayer = nil;
    
    [super dealloc];
}


@end
