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
    clouds = [[[TextureMgr sharedTextureMgr] addImage:@"clouds.png"] retain];
    
    return self;
}


- (void)onEnter {
    
    [self schedule:@selector(updateClouds:)];
    
    [self reset];
    
    [super onEnter];
}


-(void) reset {

    skyColorFrom = ccc([[DMConfig get].skyColorFrom longValue]);
    skyColorTo = ccc([[DMConfig get].skyColorTo longValue]);
    fancySky = [[Config get].visualFx boolValue];
}


- (void)updateClouds:(ccTime)dt {
    
    cloudsX += dt * 10;
    while (cloudsX > clouds.contentSize.width)
        cloudsX -= clouds.contentSize.width;
}


-(void) draw {
    
    if(fancySky) {
        DrawBoxFrom(CGPointZero, ccp(self.contentSize.width, self.contentSize.height), skyColorFrom, skyColorTo);
        
        glEnableClientState( GL_VERTEX_ARRAY);
        glEnableClientState( GL_TEXTURE_COORD_ARRAY );
        glEnable( GL_TEXTURE_2D);
        
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        [clouds drawAtPoint:CGPointMake(cloudsX - clouds.contentSize.width, 0)];
        if (cloudsX < self.contentSize.width)
            [clouds drawAtPoint:CGPointMake(cloudsX, 0)];
        
        glDisable( GL_TEXTURE_2D);
        
        glDisableClientState(GL_VERTEX_ARRAY );
        glDisableClientState( GL_TEXTURE_COORD_ARRAY );
    }
    
    else {
        glClearColor(skyColorFrom.r / (float)0xff, skyColorFrom.g / (float)0xff,
                     skyColorFrom.b / (float)0xff, skyColorFrom.a / (float)0xff);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}


-(void) dealloc {
    
    [super dealloc];
}


@end
