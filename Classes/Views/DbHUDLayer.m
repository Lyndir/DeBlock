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
//  DbHUDLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 04/08/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "DbHUDLayer.h"
#import "ShadeTo.h"


@implementation DbHUDLayer

- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    levelScoreCount = [[LabelAtlas alloc] initWithString:@""
                                             charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '];
    levelScoreCount.position = ccp(scoreCount.position.x + 13 * 4, scoreCount.position.y);
    [self addChild:levelScoreCount];
    
    return self;
}

-(void) updateHudWithScore:(int)score {
    
    [super updateHudWithScore:0];
    
    [levelScoreCount setString:[NSString stringWithFormat:@"%+04d", [[DMConfig get].levelScore intValue]]];
    
    if(score) {
        long scoreColor;
        if(score > 0)
            scoreColor = 0x99FF99ff;
        else if(score < 0)
            scoreColor = 0xFF9999ff;
        
        [levelScoreCount runAction:[Sequence actions:
                                    [ShadeTo actionWithDuration:0.5f color:scoreColor],
                                    [ShadeTo actionWithDuration:0.5f color:0xFFFFFFff],
                                    nil]];
    }
}

@end
