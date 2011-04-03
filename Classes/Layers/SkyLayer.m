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

- (void)cloudDone:(CCSprite *)cloud;

@property (readwrite, assign) BOOL                    fancySky;

@property (readwrite, assign) ccColor4B               skyColorFrom;
@property (readwrite, assign) ccColor4B               skyColorTo;
@property (readwrite, assign) CCTexture2D             **clouds;

@property (readwrite, assign) CGFloat                 cloudsX;

@end

@implementation SkyLayer

@synthesize fancySky = _fancySky;
@synthesize skyColorFrom = _skyColorFrom, skyColorTo = _skyColorTo;
@synthesize clouds = _clouds;
@synthesize cloudsX = _cloudsX;


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    self.contentSize = [CCDirector sharedDirector].winSize;

    self.clouds = malloc(sizeof(CCTexture2D *) * kCloudFrames);
    for (NSUInteger c = 0; c < kCloudFrames; ++c)
        self.clouds[c] = [[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"clouds.%d.png", c + 1]] retain];
    
    ccBlendFunc cloudBlend;
    cloudBlend.src = GL_ONE;
    cloudBlend.dst = GL_ONE_MINUS_SRC_ALPHA;
    
    for (NSUInteger c = 0; c < kCloudCount; ++c) {
        CCSprite *cloud = [CCSprite spriteWithTexture:self.clouds[random() % kCloudFrames]];
        cloud.position = CGPointMake(random() % (NSInteger)(self.contentSize.width + cloud.contentSize.width)
                                     + cloud.contentSize.width / 4,
                                     self.contentSize.height - random() % (NSInteger)cloud.contentSize.height / 3);
        NSInteger t = fmaxf(1.0f, kCloudTime - kCloudTime * cloud.position.x / (self.contentSize.width + cloud.contentSize.width));
        [cloud runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:random() % t / 2 + t / 2
                                                                   position:CGPointMake(self.contentSize.width + cloud.contentSize.width / 2,
                                                                                    cloud.position.y)]
                                         two:[CCCallFuncN actionWithTarget:self selector:@selector(cloudDone:)]]];
        [cloud setBlendFunc:cloudBlend];
        [self addChild:cloud z:1];
    }
    
    return self;
}


- (void)cloudDone:(CCSprite *)cloud {
    
    cloud.position = CGPointMake(-cloud.contentSize.width / 2,
                                 self.contentSize.height + random() % (NSInteger)cloud.contentSize.height / 4);
    [cloud runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:random() % kCloudTime / 2 + kCloudTime / 2
                                                               position:CGPointMake(self.contentSize.width + cloud.contentSize.width / 2,
                                                                                cloud.position.y)]
                                     two:[CCCallFuncN actionWithTarget:self selector:@selector(cloudDone:)]]];
}


- (void)onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) reset {

    self.skyColorFrom = ccc4l([[DeblockConfig get].skyColorFrom longValue]);
    self.skyColorTo = ccc4l([[DeblockConfig get].skyColorTo longValue]);
    self.fancySky = [[Config get].visualFx boolValue];
}


-(void) draw {
    
    [super draw];

    if(self.fancySky)
        DrawBoxFrom(CGPointZero, ccp(self.contentSize.width, self.contentSize.height), self.skyColorFrom, self.skyColorTo);
    
    else {
        glClearColor(self.skyColorFrom.r / (float)0xff, self.skyColorFrom.g / (float)0xff,
                     self.skyColorFrom.b / (float)0xff, self.skyColorFrom.a / (float)0xff);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}


-(void) dealloc {
    
    for (NSUInteger c = 0; c < kCloudFrames; ++c)
        [self.clouds[c] release];
    free(self.clouds);
    self.clouds = nil;
    
    [super dealloc];
}


@end
