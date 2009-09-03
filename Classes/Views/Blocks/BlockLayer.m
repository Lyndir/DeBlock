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
#import "PropertyAction.h"
#import "DeblockAppDelegate.h"
#import "SpecialBlocks.h"

#define kAllBlocksLevel 10
#define kMinBlocks      3


@implementation BlockLayer

@synthesize type, destroyed, destructible, moveAction;
@synthesize targetRow, targetCol;
@synthesize frames, frame, modColor;

static NSDictionary *blockColors;

+ (void)initialize {

    blockColors = [[NSDictionary alloc] initWithObjectsAndKeys:
//                 [NSNumber numberWithLong:0x385D8Aff],    [NSNumber numberWithUnsignedInt:DMBlockTypeOne],
//                 [NSNumber numberWithLong:0x37A647ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeTwo],
//                 [NSNumber numberWithLong:0xF2E63Dff],    [NSNumber numberWithUnsignedInt:DMBlockTypeThree],
//                 [NSNumber numberWithLong:0xBF5F02ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFour],
//                 [NSNumber numberWithLong:0xF23535ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFive],
                                    
//                 [NSNumber numberWithLong:0x312316ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeOne],
//                 [NSNumber numberWithLong:0xF2DBAEff],    [NSNumber numberWithUnsignedInt:DMBlockTypeTwo],
//                 [NSNumber numberWithLong:0xBF6A39ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeThree],
//                 [NSNumber numberWithLong:0x401208ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFour],
//                 [NSNumber numberWithLong:0xBF3434ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFive],
                                    
//                 [NSNumber numberWithLong:0x59383Eff],    [NSNumber numberWithUnsignedInt:DMBlockTypeOne],
//                 [NSNumber numberWithLong:0xF0F0F2ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeTwo],
//                 [NSNumber numberWithLong:0x4D5339ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeThree],
//                 [NSNumber numberWithLong:0x8B7351ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFour],
//                 [NSNumber numberWithLong:0x74502Eff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFive],
                                    
                   [NSNumber numberWithLong:0xB04B3Cff],    [NSNumber numberWithUnsignedInt:DMBlockTypeOne],
                   [NSNumber numberWithLong:0xB8B257ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeTwo],
                   [NSNumber numberWithLong:0xFCE2B1ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeThree],
                   [NSNumber numberWithLong:0x648F94ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFour],
                   [NSNumber numberWithLong:0xE39549ff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFive],

                   [NSNull null],                           [NSNumber numberWithUnsignedInt:DMBlockTypeCount],
                   [NSNumber numberWithLong:0xEEEEEEff],    [NSNumber numberWithUnsignedInt:DMBlockTypeSpecial],
                   [NSNumber numberWithLong:0x9999CCff],    [NSNumber numberWithUnsignedInt:DMBlockTypeFrozen],
                   nil];
}


+ (NSUInteger)minimumLevel {
    
    return 0;
}


+ (id)randomBlockForLevel:(NSUInteger)level withSize:(CGSize)size {

    id class;
    switch (random() % 50) {
        case 1:
            class = [BombBlockLayer class];
            break;
        case 2:
            class = [MorphBlockLayer class];
            break;
        case 3:
            class = [ZapBlockLayer class];
            break;
        case 4:
            class = [FreezeBlockLayer class];
            break;
        default:
            class = [BlockLayer class];
    }
    
    if (level < [class minimumLevel])
        class = [BlockLayer class];
    
    return [[[class alloc] initWithBlockSize:size] autorelease];
}

+ (ccColor4B)colorForType:(DMBlockType)aType {
    
    return ccc([[blockColors objectForKey:[NSNumber numberWithUnsignedInt:aType]] longValue]);
}

- (id)initWithBlockSize:(CGSize)size {

    if (!(self = [super init]))
        return nil;
    
    self.contentSize    = size;
    self.type           = [[self class] randomType];
    self.destroyed      = NO;
    self.destructible   = YES;
    self.modColor       = cccf(1, 1, 1, 1);

    frames              = 11;
    frame               = 0;
    textures            = malloc(sizeof(Texture2D *) * frames);
    textures[0]         = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.png"] retain];
    for (NSUInteger i = 1; i < 11; ++i)
        textures[i]     = [[[TextureMgr sharedTextureMgr] addImage:[NSString stringWithFormat:@"block.cracked.%d.png", i]] retain];

    /*label               = [[Label alloc] initWithString:[self labelString] dimensions:size
                                              alignment:UITextAlignmentCenter
                                               fontName:[Config get].fixedFontName
                                               fontSize:[[Config get].smallFontSize unsignedIntValue]];
    label.position      = ccp(size.width / 2, size.height / 2);
    [self addChild:label];*/
    
    self.isTouchEnabled      = YES;
    
    [self schedule:@selector(randomEvent:) interval:0.1f];
    
    return self;
}


+ (DMBlockType)randomType {
    
    DMBlockType typeRange = DMBlockTypeCount * [[DMConfig get].level intValue] / kAllBlocksLevel;
    return random() % ((int)fmaxf(fminf(typeRange, DMBlockTypeCount), kMinBlocks));
}


- (NSString *)labelString {
    
    return @"";
}


- (BOOL)needsLinksToDestroy {
    
    return YES;
}


- (NSMutableSet *)findLinkedBlocksInField:(FieldLayer *)field atRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    return [self findAdjecentBlocksInField:field atRow:aRow col:aCol];
}


- (NSMutableSet *)findAdjecentBlocksInField:(FieldLayer *)field atRow:(NSInteger)aRow col:(NSInteger)aCol {

    // Find all neighbouring blocks of the same type.
    NSMutableSet *linkedBlocks = [NSMutableSet setWithCapacity:4];
    for (NSInteger r = aRow - 1; r <= aRow + 1; ++r) {
        BlockLayer *block = [field blockAtRow:r col:aCol];
        if (block == nil || r == aRow)
            // Bad block, ignore.
            continue;
        
        if (block.type == type)
            [linkedBlocks addObject:block];
    }
    for (NSInteger c = aCol - 1; c <= aCol + 1; ++c) {
        BlockLayer *block = [field blockAtRow:aRow col:c];
        if (block == nil || c == aCol)
            // Bad block, ignore.
            continue;
        
        if (block.type == type)
            [linkedBlocks addObject:block];
    }
    
    return linkedBlocks;
}


- (void)getLinksInField:(FieldLayer *)aField toSet:(NSMutableSet *)allLinkedBlocks
                recurse:(BOOL)recurse specialLinks:(BOOL)specialLinks {
    
    if (self.destroyed || !self.destructible)
        // Already destroyed or indestructible.
        return;
    
    // Find the position of the block to destroy.
    NSInteger row, col;
    [aField getPositionOfBlock:self toRow:&row col:&col];

    NSMutableSet *myLinkedBlocks;
    if (specialLinks)
        myLinkedBlocks = [self findLinkedBlocksInField:aField atRow:row col:col];
    else
        myLinkedBlocks = [self findAdjecentBlocksInField:aField atRow:row col:col];
    [myLinkedBlocks minusSet:allLinkedBlocks];
    
    if (![myLinkedBlocks count])
        // No links.
        return;

    [allLinkedBlocks unionSet:myLinkedBlocks];

    if (recurse)
        for (BlockLayer *block in myLinkedBlocks)
            [block getLinksInField:aField toSet:allLinkedBlocks
                           recurse:recurse specialLinks:specialLinks];
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
        [self.parent addChild:dropEmitter];

    dropEmitter.centerOfGravity = ccp(self.position.x + self.contentSize.width / 2, self.position.y);
}


- (void)notifyCollapsed {
    
}


- (void)notifyDestroyed {
    
    [dropEmitter stopSystem];
    [dropEmitter release];
    dropEmitter = nil;
    
    [self.parent removeChild:self cleanup:YES];
}


- (void)setTargetRow:(NSInteger)r {
    
    targetRow = r;
    //[label setString:[NSString stringWithFormat:@"%d,%d", targetRow, targetCol]];
}


- (void)setTargetCol:(NSInteger)c {
    
    targetCol = c;
    //[label setString:[NSString stringWithFormat:@"%d,%d", targetRow, targetCol]];
}


- (GLubyte)r {
    
    return blockColor.r;
}


- (GLubyte)g {
    
    return blockColor.g;
}


- (GLubyte)b {
    
    return blockColor.b;
}


- (GLubyte)opacity {
    
    return blockColor.a;
}


- (void)setRGB:(GLubyte)r :(GLubyte)g :(GLubyte)b {
    
    blockColor.r = r;
    blockColor.g = g;
    blockColor.b = b;
}


- (void)setOpacity:(GLubyte)a {
    
    blockColor.a = a;
}


- (void)setColorMultiplier:(CGFloat)m {
    
    modColor.r = m;
    modColor.g = m;
    modColor.b = m;
}


- (void)setType:(DMBlockType)aType {
    
    type = aType;
    ccColor4B targetColor = [[self class] colorForType:type];
    
    if (self.parent)
        [self runAction:[TintTo actionWithDuration:0.2f red:targetColor.r green:targetColor.g blue:targetColor.b]];
    else
        blockColor = targetColor;
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
    
    PropertyAction *animateColor = [PropertyAction actionWithDuration:0.3f key:@"colorMultiplier"
                                                                   from:[NSNumber numberWithFloat:1.0f]
                                                                     to:[NSNumber numberWithFloat:1.5f]];
    [self runAction:[Sequence actions:animateColor, [animateColor reverse], nil]];
}


- (void)crumble {
    
    PropertyAction *animateFrames      = [PropertyAction actionWithDuration:0.4f key:@"frame"
                                                                   from:[NSNumber numberWithUnsignedInt:0]
                                                                     to:[NSNumber numberWithUnsignedInt:frames - 1]];
    
    ParticleSystem *crumbleEmitter      = [[ParticleSmoke alloc] initWithTotalParticles:1000];
    crumbleEmitter.duration             = animateFrames.duration;
    crumbleEmitter.life                 = 1.0f;
    crumbleEmitter.lifeVar              = 0.3f;
    crumbleEmitter.speed                = 5;
    crumbleEmitter.speedVar             = 5;
    crumbleEmitter.startSize            = 10;
    crumbleEmitter.startSizeVar         = 5;
    crumbleEmitter.endSize              = 20;
    crumbleEmitter.endSizeVar           = 5;
    crumbleEmitter.angle                = 90;
    crumbleEmitter.angleVar             = 10;
    crumbleEmitter.gravity              = ccp(0, -5);
    crumbleEmitter.position             = CGPointZero;
    crumbleEmitter.posVar               = ccp(self.contentSize.width / 2, self.contentSize.height / 3);
    crumbleEmitter.centerOfGravity      = ccp(self.position.x + self.contentSize.width / 2,
                                              self.position.y + self.contentSize.height / 3);
#if TARGET_IPHONE_SIMULATOR
    crumbleEmitter.startColor           = cccf(1, 1, 1, 0.3f);
    crumbleEmitter.endColor             = cccf(1, 1, 1, 0);
#else
    crumbleEmitter.startColor           = cccf(0.3f, 0.3f, 0.3f, 0.3f);
    crumbleEmitter.endColor             = cccf(0, 0, 0, 0);
#endif
    crumbleEmitter.autoRemoveOnFinish   = YES;
    [self.parent addChild:crumbleEmitter];
    [crumbleEmitter release];


    [self runAction:[Sequence actions:
                     animateFrames,
                     [CallFunc actionWithTarget:self selector:@selector(notifyDestroyed)],
                     nil]];
}


- (BOOL)moving {
    
    return moveAction && ![moveAction isDone];
}


- (BOOL)valid {
    
    return !self.moving && !destroyed && destructible;
}


- (void)draw {

    //CGPoint to    = CGPointMake(self.contentSize.width, self.contentSize.height);
    ccColor4B fromC = blockColor;
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
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
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

- (NSString *)description {
    
    // Find the position of the block to destroy.
    NSInteger row, col;
    if (![[DeblockAppDelegate get].gameLayer.fieldLayer findPositionOfBlock:self toRow:&row col:&col])
        row = col = -1;
    
    NSMutableString *properties = [NSMutableString string];
    if (self.destroyed)
        [properties appendFormat:@", destroyed"];
    if (!self.valid)
        [properties appendFormat:@", invalid"];
    if (self.moving)
        [properties appendFormat:@", moving"];
    if (!self.needsLinksToDestroy)
        [properties appendFormat:@", canDestroyUnlinked"];
    if (properties.length)
        [properties deleteCharactersInRange:NSMakeRange(0, 2)];
    
    return [NSString stringWithFormat:@"<%d,%d: %@:%d [%@]>",
            row, col, [self class], self.type, properties];
}

@end
