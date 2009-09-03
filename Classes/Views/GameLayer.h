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
//  GameLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//


#import "SkyLayer.h"
#import "FieldLayer.h"

typedef enum DbEndReason {
    DbEndReasonEnded,
    DbEndReasonGameOver,
    DbEndReasonNextField
} DbEndReason;


@interface GameLayer : Layer <Resettable> {

    BOOL                                                paused;
    BOOL                                                running;
    DbEndReason                                         endReason;
    
    SkyLayer                                            *skyLayer;
    FieldLayer                                          *fieldLayer;
    Layer                                               *fieldScroller;
    
    Action                                              *shakeAction;
    ScaleTime                                           *scaleTimeAction;
}

@property (nonatomic, readwrite) BOOL                   paused;

@property (nonatomic, readonly) SkyLayer                *skyLayer;
@property (nonatomic, readonly) FieldLayer              *fieldLayer;

@property (nonatomic, readonly) ScaleTime               *scaleTimeAction;

- (void)shake;
- (void)scaleTimeTo:(float)aTimeScale duration:(ccTime)aDuration;

- (void)newGame;
- (void)startGame;
- (void)stopGame:(DbEndReason)reason;

- (void)started;
- (void)stopped;

- (void)levelRedo;

@end
