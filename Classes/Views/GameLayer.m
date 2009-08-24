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

-(void) setPausedSilently:(BOOL)_paused;

@end

@implementation GameLayer


#pragma mark Properties

@synthesize paused;
@synthesize skyLayer, fieldLayer;
@synthesize scaleTimeAction;


-(void) setPaused:(BOOL)_paused {

    if(paused == _paused)
        // Nothing changed.
        return;
    
    [self setPausedSilently:_paused];
    
    if(running) {
        if(paused)
            [[DeblockAppDelegate get].uiLayer message:NSLocalizedString(@"messages.paused", @"Paused")];
        else {
            [[DeblockAppDelegate get].uiLayer message:NSLocalizedString(@"messages.unpaused", @"Unpaused")];
        }
    }
}


-(void) setPausedSilently:(BOOL)_paused {
    
    paused = _paused;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!paused animated:YES];
    
    if(paused) {
        if(running)
            [self scaleTimeTo:0 duration:0.5f];
        [[DeblockAppDelegate get] hideHud];
    } else {
        [self scaleTimeTo:1.0f duration:1.0f];
        [[DeblockAppDelegate get] popAllLayers];
        [[DeblockAppDelegate get] revealHud];
    }
}


- (void)scaleTimeTo:(float)aTimeScale duration:(ccTime)aDuration {

    if (scaleTimeAction)
        [self stopAction:scaleTimeAction];
    [scaleTimeAction release];
    
    scaleTimeAction = [[ScaleTime actionWithTimeScaleTarget:aTimeScale duration:aDuration] retain];
    [self runAction:scaleTimeAction scaleTime:NO];
}


#pragma mark Interact

-(void) reset {
    
    [skyLayer reset];
    [fieldLayer reset];
}


-(void) shake {
    
    if ([[Config get].vibration boolValue])
        [AudioController vibrate];
    
    [fieldLayer runAction:shakeAction];
}


-(void) newGame {
    
    [DMConfig get].level = [NSNumber numberWithInt:1];
    [[DMConfig get] recordScore:0];
    [[DeblockAppDelegate get].hudLayer updateHudWithScore:0];
    
    [self startGame];
}


-(void) startGame {

    if(running)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while one's still running."
                                     userInfo:nil];
    endReason = DbEndReasonEnded;
    [DMConfig get].levelScore = [NSNumber numberWithInt:0];
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

    [fieldLayer stopGame];
}


#pragma mark Internal

-(id) init {
    
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
    
    CGSize winSize = [Director sharedDirector].winSize;
    fieldLayer.contentSize  = CGSizeMake(winSize.width * 9/10, winSize.height * 4/5);
    fieldLayer.position     = ccp((winSize.width - fieldLayer.contentSize.width) / 2.0f,
                                  (winSize.height - fieldLayer.contentSize.height - [DeblockAppDelegate get].hudLayer.contentSize.height) / 2.0f +  [DeblockAppDelegate get].hudLayer.contentSize.height);
    
    [self addChild:skyLayer z:-1];
    [self addChild:fieldLayer z:1];
    
    paused = YES;
    
    return self;
}


-(void) onEnterTransitionDidFinish {
    
    [super onEnterTransitionDidFinish];
    
    [self newGame];
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
    
    running = NO;
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
    
    endReason = DbEndReasonEnded;
}


-(void) dealloc {
    
    [skyLayer release];
    skyLayer = nil;
    
    [fieldLayer release];
    fieldLayer = nil;
    
    [super dealloc];
}


@end
