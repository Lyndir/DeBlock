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

#define kCloudCount         10
#define kCloudFrames        6
#define kCloudAnimation     @"clouds"
#define kCloudTime          40


@interface SkyLayer ()

- (void)cloudDone:(Sprite *)cloud;

@end

@implementation SkyLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    self.contentSize = [Director sharedDirector].winSize;

    clouds = malloc(sizeof(Texture2D *) * kCloudFrames);
    for (NSUInteger c = 0; c < kCloudFrames; ++c)
        clouds[c] = [[[TextureMgr sharedTextureMgr] addImage:[NSString stringWithFormat:@"clouds.%d.png", c + 1]] retain];
    
    ccBlendFunc cloudBlend;
    cloudBlend.src = GL_ONE;
    cloudBlend.dst = GL_ONE_MINUS_SRC_ALPHA;
    
    for (NSUInteger c = 0; c < kCloudCount; ++c) {
        Sprite *cloud = [Sprite spriteWithTexture:clouds[random() % kCloudFrames]];
        cloud.position = CGPointMake(random() % (NSInteger)(self.contentSize.width + cloud.contentSize.width)
                                     + cloud.contentSize.width / 4,
                                     self.contentSize.height - random() % (NSInteger)cloud.contentSize.height / 3);
        NSInteger t = fmaxf(1.0f, kCloudTime - kCloudTime * cloud.position.x / (self.contentSize.width + cloud.contentSize.width));
        [cloud runAction:[Sequence actionOne:[MoveTo actionWithDuration:random() % t / 2 + t / 2
                                                               position:CGPointMake(self.contentSize.width + cloud.contentSize.width / 2,
                                                                                    cloud.position.y)]
                                         two:[CallFuncN actionWithTarget:self selector:@selector(cloudDone:)]]];
        [cloud setBlendFunc:cloudBlend];
        [self addChild:cloud z:1];
    }
    
    return self;
}


- (void)cloudDone:(Sprite *)cloud {
    
    cloud.position = CGPointMake(-cloud.contentSize.width / 2,
                                 self.contentSize.height + random() % (NSInteger)cloud.contentSize.height / 4);
    [cloud runAction:[Sequence actionOne:[MoveTo actionWithDuration:random() % kCloudTime / 2 + kCloudTime / 2
                                                           position:CGPointMake(self.contentSize.width + cloud.contentSize.width / 2,
                                                                                cloud.position.y)]
                                     two:[CallFuncN actionWithTarget:self selector:@selector(cloudDone:)]]];
}


- (void)onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) reset {

    skyColorFrom = ccc4l([[DMConfig get].skyColorFrom longValue]);
    skyColorTo = ccc4l([[DMConfig get].skyColorTo longValue]);
    fancySky = [[Config get].visualFx boolValue];
}


-(void) draw {
    
    if(fancySky) {
        DrawBoxFrom(CGPointZero, ccp(self.contentSize.width, self.contentSize.height), skyColorFrom, skyColorTo);
    }
    
    else {
        glClearColor(skyColorFrom.r / (float)0xff, skyColorFrom.g / (float)0xff,
                     skyColorFrom.b / (float)0xff, skyColorFrom.a / (float)0xff);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}


-(void) dealloc {
    
    free(clouds);
    
    [super dealloc];
}


@end
