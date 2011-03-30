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
//  DbHUDLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 04/08/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "HUDLayer.h"


@interface DbHUDLayer : HUDLayer {

@private
    CCLabelAtlas          *_levelScoreCount, *_levelPenaltyCount;
}

-(void) updateHudWasGood:(BOOL)wasGood;


@end
