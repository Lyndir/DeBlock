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
//  DMConfig.m
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#define dLevel          NSStringFromSelector(@selector(level))
#define dLevelScore     NSStringFromSelector(@selector(levelScore))

#define dSkyColor       NSStringFromSelector(@selector(skyColor))

#define dFlawlessBonus  NSStringFromSelector(@selector(flawlessBonus))

#import "DMConfig.h"

@implementation DMConfig

@dynamic level, levelScore;
@dynamic skyColor;
@dynamic flawlessBonus;

- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithLong:0],                        dLevel,
                                [NSNumber numberWithLong:0],                        dLevelScore,
                                
                                [NSNumber numberWithLong:0x778077ff],               dSkyColor,
                                
                                [NSNumber numberWithInt:200],                       dFlawlessBonus,
                                     
                                nil
                                ]];
    
    return self;
}


+ (DMConfig *)get {

    static DMConfig *dmConfig;
    if(!dmConfig)
        dmConfig = [[DMConfig alloc] init];
    
    return dmConfig;
}

@end
