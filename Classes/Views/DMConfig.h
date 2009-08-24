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
//  DMConfig.h
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Config.h"


@interface DMConfig : Config {

}

+ (DMConfig *)get;

@property (readwrite, retain) NSNumber          *level;
@property (readwrite, retain) NSNumber          *levelScore;

@property (readwrite, retain) NSNumber          *skyColorFrom;
@property (readwrite, retain) NSNumber          *skyColorTo;

@property (readwrite, retain) NSNumber          *flawlessBonus;

@end
