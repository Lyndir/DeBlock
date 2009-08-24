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

#define dSkyColorFrom   NSStringFromSelector(@selector(skyColorFrom))
#define dSkyColorTo     NSStringFromSelector(@selector(skyColorTo))

#define dFlawlessBonus  NSStringFromSelector(@selector(flawlessBonus))

#import "DMConfig.h"

@implementation DMConfig

@dynamic level, levelScore;
@dynamic skyColorFrom, skyColorTo;
@dynamic flawlessBonus;

- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithLong:0],                        dLevel,
                                [NSNumber numberWithLong:0],                        dLevelScore,
                                
                                [NSNumber numberWithLong:0x58748Cff],               dSkyColorFrom,
                                [NSNumber numberWithLong:0xB3D5F2ff],               dSkyColorTo,
//                                [NSNumber numberWithLong:0xD8E6F2ff],               dSkyColorTo,
                                
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
