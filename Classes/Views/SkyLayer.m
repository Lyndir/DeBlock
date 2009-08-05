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

/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  SkyLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "SkyLayer.h"
#import "DeblockAppDelegate.h"


@implementation SkyLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    self.contentSize = [Director sharedDirector].winSize;
    
    return self;
}


- (void)onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) reset {

    skyColor = ccc([[DMConfig get].skyColor longValue]);
    fancySky = [[Config get].visualFx boolValue];
}


-(void) draw {
    
    if(fancySky) {
        ccColor4B skyColorTo = skyColor;
        skyColorTo.r *= 0.5f;
        skyColorTo.g *= 0.5f;
        skyColorTo.b *= 0.5f;
        DrawBoxFrom(CGPointZero, ccp(self.contentSize.width, self.contentSize.height), skyColor, skyColorTo);
    }
    
    else {
        glClearColor(skyColor.r / (float)0xff, skyColor.g / (float)0xff, skyColor.b / (float)0xff, skyColor.a / (float)0xff);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}


-(void) dealloc {
    
    [super dealloc];
}


@end
