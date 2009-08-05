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
//  BlockLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "BlockLayer.h"
#import "AnimateProperty.h"
#import "DeblockAppDelegate.h"

#define kAllBlocksLevel 10
#define kMinBlocks      3

@implementation BlockLayer

@synthesize type, moving, destroyed, moveAction;
@synthesize targetRow, targetCol;
@synthesize frames, frame, modColor;


- (id)initWithBlockSize:(CGSize)size {
    
    if (!(self = [super init]))
        return nil;
    
    self.contentSize                = size;
    self.type                       = random() % ((int)fmaxf(fminf(DMBlockTypeCount * [[DMConfig get].level intValue] / kAllBlocksLevel, DMBlockTypeCount), kMinBlocks));
    self.destroyed                  = NO;
    self.modColor                   = cccf(1, 1, 1, 1);

    frames                          = 11;
    frame                           = 0;
    textures                        = malloc(sizeof(Texture2D *) * frames);
    textures[0]                     = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.png"] retain];
    for (NSUInteger i = 1; i < 11; ++i)
        textures[i]                 = [[[TextureMgr sharedTextureMgr] addImage:
                                        [NSString stringWithFormat:@"block.cracked.%d.png", i]] retain];

    blockColors             = [[NSDictionary alloc] initWithObjectsAndKeys:
//                               [NSNumber numberWithLong:0x385D8Aff],    [NSNumber numberWithUnsignedInt:DMBlockTypeOne],
//                               [NSNumber numberWithLong:0x37A647ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeTwo],
//                               [NSNumber numberWithLong:0xF2E63Dff],    [NSNumber numberWithUnsignedInt:DMBlockTypeThree],
//                               [NSNumber numberWithLong:0xBF5F02ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFour],
//                               [NSNumber numberWithLong:0xF23535ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFive],
                               
//                               [NSNumber numberWithLong:0x312316ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeOne],
//                               [NSNumber numberWithLong:0xF2DBAEff],    [NSNumber numberWithUnsignedInt:DMBlockTypeTwo],
//                               [NSNumber numberWithLong:0xBF6A39ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeThree],
//                               [NSNumber numberWithLong:0x401208ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFour],
//                               [NSNumber numberWithLong:0xBF3434ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFive],
                               
                               [NSNumber numberWithLong:0x59383Eff],    [NSNumber numberWithUnsignedInt:DMBlockTypeOne],
                               [NSNumber numberWithLong:0xF0F0F2ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeTwo],
                               [NSNumber numberWithLong:0x4D5339ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeThree],
                               [NSNumber numberWithLong:0x8B7351ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFour],
                               [NSNumber numberWithLong:0x74502Eff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFive],
                               
                               nil
                               ];
    /*label                   = [[Label alloc] initWithString:@"x" dimensions:size alignment:UITextAlignmentCenter
                                                   fontName:[Config get].fixedFontName fontSize:[[Config get].smallFontSize unsignedIntValue]];
    label.position          = ccp(size.width / 2, size.height / 2);
    [self addChild:label];*/
    
    isTouchEnabled = YES;
    
    [self schedule:@selector(randomEvent:) interval:0.1f];
    
    return self;
}


- (void)notifyDropped {

    if (dropEmitter)
        [dropEmitter resetSystem];
    
    else {
        dropEmitter                     = [[ParticleSmoke alloc] initWithTotalParticles:1000];
        dropEmitter.duration            = 0.2f;
        dropEmitter.life                = 0.7f;
        dropEmitter.lifeVar             = 0.3f;
        dropEmitter.speed               = 15;
        dropEmitter.speedVar            = 3;
        dropEmitter.startSize           = 3;
        dropEmitter.startSizeVar        = 2;
        dropEmitter.endSize             = 10;
        dropEmitter.endSizeVar          = 3;
        dropEmitter.angle               = 90;
        dropEmitter.angleVar            = 90;
        dropEmitter.gravity             = ccp(0, -5);
        dropEmitter.posVar              = ccp(self.contentSize.width / 2, 0);
        dropEmitter.position            = CGPointZero;
#if TARGET_IPHONE_SIMULATOR
        dropEmitter.startColor          = cccf(1, 1, 1, 0.3f);
        dropEmitter.endColor            = cccf(1, 1, 1, 0);
#else
        dropEmitter.startColor          = cccf(0.3f, 0.3f, 0.3f, 0.3f);
        dropEmitter.endColor            = cccf(0, 0, 0, 0);
#endif
        dropEmitter.autoRemoveOnFinish  = YES;
    }

    if (!dropEmitter.parent)
        [parent addChild:dropEmitter];

    dropEmitter.centerOfGravity = ccp(self.position.x + self.contentSize.width / 2, self.position.y);
}


- (void)notifyCollapsed {
    
}


- (void)notifyDestroyed {
    
    [dropEmitter stopSystem];
    [self.parent removeChild:self cleanup:YES];
}


- (void)setTargetRow:(NSInteger)r {
    
    targetRow = r;
    [label setString:[NSString stringWithFormat:@"%d,%d", targetRow, targetCol]];
}


- (void)setTargetCol:(NSInteger)c {
    
    targetCol = c;
    [label setString:[NSString stringWithFormat:@"%d,%d", targetRow, targetCol]];
}


- (GLubyte)r {
    
    return modColor.r * UCHAR_MAX;
}


- (GLubyte)b {
    
    return modColor.b * UCHAR_MAX;
}


- (GLubyte)g {
    
    return modColor.g * UCHAR_MAX;
}


- (GLubyte)opacity {
    
    return modColor.a * UCHAR_MAX;
}


- (void)setRGB:(GLubyte)r :(GLubyte)g :(GLubyte)b {
    
    modColor.r = r / (float)UCHAR_MAX;
    modColor.g = g / (float)UCHAR_MAX;
    modColor.b = b / (float)UCHAR_MAX;
}


- (void)setOpacity:(GLubyte)a {
    
    modColor.a = a / (float)UCHAR_MAX;
}


- (void)setColorMultiplier:(CGFloat)m {
    
    modColor.r = m;
    modColor.g = m;
    modColor.b = m;
}


-(void) registerWithTouchDispatcher {
    
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (!self.valid || [DeblockAppDelegate get].gameLayer.paused || [DeblockAppDelegate get].gameLayer.fieldLayer.locked)
        return NO;

    CGPoint touchPoint  = [self convertTouchToNodeSpace:touch];
    CGRect blockRect;
    blockRect.origin    = CGPointZero;
    blockRect.size      = self.contentSize;
    
    return CGRectContainsPoint(blockRect, touchPoint);
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [[DeblockAppDelegate get].gameLayer.fieldLayer destroyBlock:self];
}


- (void)randomEvent:(ccTime)dt {
    
    if (random() % 1000 > 1)
        // 1 chance in 1000 to occur.
        return;

    [self blink];
}


- (void)blink {
    
    AnimateProperty *animateColor = [AnimateProperty actionWithDuration:0.3f key:@"colorMultiplier"
                                                                   from:[NSNumber numberWithFloat:1.0f]
                                                                     to:[NSNumber numberWithFloat:1.5f]];
    [self runAction:[Sequence actions:animateColor, [animateColor reverse], nil]];
}


- (void)crumble {
    
    AnimateProperty *animateFrames = [AnimateProperty actionWithDuration:0.4f key:@"frame"
                                                                   from:[NSNumber numberWithUnsignedInt:0]
                                                                     to:[NSNumber numberWithUnsignedInt:frames - 1]];
    [self runAction:[Sequence actions:
                     animateFrames,
                     [CallFunc actionWithTarget:self selector:@selector(notifyDestroyed)],
                     nil]];
}


- (BOOL)moving {
    
    return moveAction && ![moveAction isDone];
}


- (BOOL)valid {
    
    return !self.moving && !destroyed;
}


- (void)draw {

    //CGPoint to      = CGPointMake(self.contentSize.width, self.contentSize.height);
    ccColor4B fromC = ccc([(NSNumber *) [blockColors objectForKey:[NSNumber numberWithUnsignedInt:self.type]] longValue]);
    fromC.r         = fminf(0xff, fmaxf(0x00, fromC.r * modColor.r));
    fromC.g         = fminf(0xff, fmaxf(0x00, fromC.g * modColor.g));
    fromC.b         = fminf(0xff, fmaxf(0x00, fromC.b * modColor.b));
    fromC.a         = fminf(0xff, fmaxf(0x00, fromC.a * modColor.a));
    ccColor4B toC   = fromC;
    toC.r           = fmaxf(0x00, toC.r * 0.5f);
    toC.g           = fmaxf(0x00, toC.g * 0.5f);
    toC.b           = fmaxf(0x00, toC.b * 0.5f);
    
    glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glEnable( GL_TEXTURE_2D);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4ub( fromC.r, fromC.g, fromC.b, fromC.a);
    
    CGRect textureRect;
    textureRect.origin = CGPointZero;
    textureRect.size   = self.contentSize;
    [textures[frame] drawInRect:textureRect];
	
	// is this chepear than saving/restoring color state ?
	glColor4ub( 255, 255, 255, 255);
    
	glDisable( GL_TEXTURE_2D);
    
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
    
    //DrawBoxFrom(CGPointZero, to, fromC, toC);
    //DrawBorderFrom(CGPointZero, to, fromC, 1.0f);
}

@end
