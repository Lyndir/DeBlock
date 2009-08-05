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
//  AnimateProperty.m
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "AnimateProperty.h"


@implementation AnimateProperty

+ (id)actionWithDuration:(ccTime)aDuration key:(NSString *)aKey from:(NSNumber *)aFrom to:(NSNumber *)aTo {

    return [[[[self class] alloc] initWithDuration:aDuration key:aKey from:aFrom to:aTo] autorelease];
}


- (id)initWithDuration:(ccTime)aDuration key:(NSString *)aKey from:(NSNumber *)aFrom to:(NSNumber *)aTo {
    
    if (!(self = [super initWithDuration:aDuration]))
        return nil;
    
    key     = [aKey copy];
    from    = [aFrom copy];
    to      = [aTo copy];
    
    return self;
}

- (void)start {
    
    [super start];
    
    if (from)
        [self.target setValue:from forKey:key];
    
    delta = [to floatValue] - [from floatValue];
}

- (void) update:(ccTime) dt {
    
    [self.target setValue:[NSNumber numberWithFloat:[to floatValue] - delta * (1 - dt)] forKey:key];
}

- (IntervalAction *) reverse
{
	return [[self class] actionWithDuration:self.duration key:key from:to to:from];
}

@end
