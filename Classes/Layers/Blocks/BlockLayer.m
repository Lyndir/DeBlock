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
#import "DeblockAppDelegate.h"
#import "SpecialBlocks.h"

#define kAllBlocksLevel 10
#define kMinBlocks      3


@interface BlockLayer ()

- (void)randomEvent:(ccTime)dt;

@property (readwrite, assign) CCTexture2D                                 **textures;
@property (readwrite, retain) CCLabelTTF                                  *label;


@property (readwrite, assign) NSUInteger                                  frames;
@property (readwrite, assign) ccColor4B                                   blockColor;


@property (readwrite, retain) CCParticleSystem                            *dropEmitter;

@end


@implementation BlockLayer

@synthesize textures = _textures;
@synthesize label = _label;
@synthesize destroyed = _destroyed;
@synthesize destructible = _destructible;
@synthesize frames = _frames, frame = _frame;
@synthesize blockColor = _blockColor;
@synthesize modColor = _modColor;
@synthesize moveAction = _moveAction;
@synthesize dropEmitter = _dropEmitter;


static SystemSoundID blockEffect;
static NSDictionary *blockColors;

+ (void)initialize {

    blockEffect = [AudioController loadEffectWithName:@"crumble.caf"];
    
    [blockColors release];
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


+ (id)randomBlockForLevel:(NSUInteger)level withSize:(CGSize)size {

    DMBlockType aType = [self randomType];
    Class specialTypes[] = {
        [BombBlockLayer class],
        [MorphBlockLayer class],
        [ZapBlockLayer class],
        [FreezeBlockLayer class],
        [BlockLayer class]
    };
    NSUInteger specialTypeCount = sizeof(specialTypes) / sizeof(Class) - 1;
    Class *types = malloc(sizeof(Class) * 100);
    NSUInteger specialType = 0, j = 0;
    for (NSUInteger i = 0; i < 100; ++i) {
        if (specialType < specialTypeCount) {
            while (++j > [specialTypes[specialType] occurancePercentForLevel:level type:aType]) {
                j = 0;
                ++specialType;
                
                if (specialType >= specialTypeCount)
                    break;
            }
        }
        
        types[i] = specialTypes[specialType];
    }
    
    Class blockClass = types[random() % 100];
    free(types);
    
    return [[[blockClass alloc] initWithType:aType
                                   blockSize:size] autorelease];
}

+ (NSUInteger)getBlocksOfClass:(Class)blockClass andType:(DMBlockType)aType {

    NSUInteger counter = 0;
    FieldLayer *field = [DeblockAppDelegate get].gameLayer.fieldLayer;

    for (NSInteger row = 0; row < field.blockRows; ++row)
        for (NSInteger col = 0; col < field.blockColumns; ++col) {
            BlockLayer *block = [field blockAtRow:row col:col];
            if ([block class] == blockClass && block.type == aType)
                ++counter;
        }

    return counter;
}

+ (void)resetLevelBlockTypes {
    
    static NSUInteger *levelBlockTypes;
    free(levelBlockTypes);
    levelBlockTypes = malloc(sizeof(NSUInteger) * DMBlockTypeCount);
}

+ (NSUInteger)occurancePercentForLevel:(NSUInteger)level type:(DMBlockType)aType {
    
    return 0;
}

+ (ccColor4B)colorForType:(DMBlockType)aType {
    
    return ccc4l([[blockColors objectForKey:[NSNumber numberWithUnsignedInt:aType]] longValue]);
}

+ (DMBlockType)randomType {
    
    DMBlockType typeRange = DMBlockTypeCount * [Player currentPlayer].level / kAllBlocksLevel;
    return random() % ((int)fmaxf(fminf(typeRange, DMBlockTypeCount), kMinBlocks));
}

- (id)initWithType:(DMBlockType)aType blockSize:(CGSize)size {

    if (!(self = [super init]))
        return nil;
    
    self.type           = aType;
    self.contentSize    = size;
    self.destroyed      = NO;
    self.destructible   = YES;
    self.modColor       = ccc4f(1, 1, 1, 1);

    self.frames              = 11;
    self.frame               = 0;
    self.textures            = malloc(sizeof(CCTexture2D *) * self.frames);
    self.textures[0]         = [[[CCTextureCache sharedTextureCache] addImage:@"block.whole.png"] retain];
    for (NSUInteger i = 1; i < 11; ++i)
        self.textures[i]     = [[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"block.cracked.%d.png", i]] retain];

    self.label               = [CCLabelTTF labelWithString:@"" dimensions:size
                                                 alignment:UITextAlignmentCenter
                                                  fontName:[Config get].fixedFontName
                                                  fontSize:size.height * 3 / 4];
    self.label.position      = ccp(size.width / 2, size.height / 2);
    [self addChild:self.label];
    
    self.isTouchEnabled      = YES;
    
    [self schedule:@selector(randomEvent:) interval:0.1f];
    
    return self;
}


- (BOOL)scoreMultiplier {
    
    return 1;
}


- (BOOL)isLinkedToAdjecentBlock:(BlockLayer *)block forReason:(DMScanReason)aReason {
    
    if (block.type != self.type)
        // Block is not of the same type.
        return NO;
    
    if (!self.destructible)
        // Indestructible block.
        return NO;
    
    return YES;
}

- (BOOL)isRecursingLinks {
    
    return YES;
}

- (NSMutableSet *)findLinkedBlocksInField:(FieldLayer *)field forReason:(DMScanReason)aReason
                                    atRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    // Find all neighbouring blocks of the same type.
    NSMutableSet *linkedBlocks = [NSMutableSet setWithCapacity:4];
    for (NSInteger r = aRow - 1; r <= aRow + 1; r+=2) {
        BlockLayer *block = [field blockAtRow:r col:aCol];
        if ([block isLinkedToAdjecentBlock:self forReason:aReason])
            [linkedBlocks addObject:block];
    }
    for (NSInteger c = aCol - 1; c <= aCol + 1; c+=2) {
        BlockLayer *block = [field blockAtRow:aRow col:c];
        if ([block isLinkedToAdjecentBlock:self forReason:aReason])
            [linkedBlocks addObject:block];
    }
    
    return linkedBlocks;
}


- (void)getLinksInField:(FieldLayer *)aField forReason:(DMScanReason)aReason
                  toSet:(NSMutableSet *)allLinkedBlocks {
    
    if (self.destroyed || !self.destructible)
        // Already destroyed or indestructible.
        return;
    
    // Find the position of the block to destroy.
    NSInteger row, col;
    [aField getPositionOfBlock:self toRow:&row col:&col];

    NSMutableSet *myLinkedBlocks = [self findLinkedBlocksInField:aField forReason:aReason atRow:row col:col];
    [myLinkedBlocks minusSet:allLinkedBlocks];
    
    if (![myLinkedBlocks count])
        // No links.
        return;

    [allLinkedBlocks unionSet:myLinkedBlocks];

    if ([self isRecursingLinks])
        for (BlockLayer *block in myLinkedBlocks)
            [block getLinksInField:aField forReason:aReason
                             toSet:allLinkedBlocks];
}

+ (SystemSoundID)effect {
    
    return blockEffect;
}


- (void)notifyCrumble {

    [AudioController playEffect:[[self class] effect]];
}


- (void)notifyCrumbled {
    
    [self.dropEmitter stopSystem];
    self.dropEmitter = nil;
    
    [self.parent removeChild:self cleanup:YES];
}


- (void)notifyDropped {
    
    if (self.dropEmitter)
        [self.dropEmitter resetSystem];
    
    else {
        self.dropEmitter                     = [[[CCParticleSmoke alloc] initWithTotalParticles:1000] autorelease];
        self.dropEmitter.duration            = 0.2f;
        self.dropEmitter.life                = 0.7f;
        self.dropEmitter.lifeVar             = 0.3f;
        self.dropEmitter.speed               = 15;
        self.dropEmitter.speedVar            = 3;
        self.dropEmitter.startSize           = 3;
        self.dropEmitter.startSizeVar        = 2;
        self.dropEmitter.endSize             = 10;
        self.dropEmitter.endSizeVar          = 3;
        self.dropEmitter.angle               = 90;
        self.dropEmitter.angleVar            = 90;
        self.dropEmitter.gravity             = ccp(0, -5);
        self.dropEmitter.posVar              = ccp(self.contentSize.width / 2, 0);
        self.dropEmitter.position            = CGPointZero;
#if TARGET_IPHONE_SIMULATOR
        self.dropEmitter.startColor          = ccc4f(1, 1, 1, 0.3f);
        self.dropEmitter.endColor            = ccc4f(1, 1, 1, 0);
#else
        self.dropEmitter.startColor          = ccc4f(0.3f, 0.3f, 0.3f, 0.3f);
        self.dropEmitter.endColor            = ccc4f(0, 0, 0, 0);
#endif
        self.dropEmitter.autoRemoveOnFinish  = YES;
    }

    if (!self.dropEmitter.parent)
        [self.parent addChild:self.dropEmitter];

    self.dropEmitter.sourcePosition = ccp(self.position.x + self.contentSize.width / 2, self.position.y);
}


- (void)notifyCollapsed {
    
}


- (NSInteger)targetRow {
    
    return _targetRow;
}


- (void)setTargetRow:(NSInteger)r {
    
    _targetRow = r;
    //[label setString:[NSString stringWithFormat:@"%d,%d", targetRow, targetCol]];
}


- (NSInteger)targetCol {
    
    return _targetCol;
}


- (void)setTargetCol:(NSInteger)c {
    
    _targetCol = c;
    //[label setString:[NSString stringWithFormat:@"%d,%d", targetRow, targetCol]];
}


- (ccColor3B)color {
    
    return ccc3(self.blockColor.r, self.blockColor.g, self.blockColor.b);
}


- (GLubyte)opacity {
    
    return self.blockColor.a;
}


- (void)setColor:(ccColor3B)color {
    
    self.blockColor = ccc4(color.r, color.g, color.b, self.blockColor.a);
}


- (void)setOpacity:(GLubyte)a {
    
    self.blockColor = ccc4(self.blockColor.r, self.blockColor.g, self.blockColor.b, a);
}


- (void)setColorMultiplier:(CGFloat)m {
    
    self.modColor = ccc4f(m, m, m, self.modColor.a);
}


- (DMBlockType)type {
    
    return _type;
}


- (void)setType:(DMBlockType)aType {
    
    _type = aType;
    ccColor4B targetColor = [[self class] colorForType:self.type];
    
    if (self.parent)
        [self runAction:[CCTintTo actionWithDuration:0.2f red:targetColor.r green:targetColor.g blue:targetColor.b]];
    else
        self.blockColor = targetColor;
}


-(void) registerWithTouchDispatcher {
    
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {

    if (!self.valid || [DeblockAppDelegate get].gameLayer.paused || [DeblockAppDelegate get].gameLayer.fieldLayer.locked)
        return NO;

    CGPoint touchPoint  = [self convertTouchToNodeSpace:touch];
    CGRect blockRect;
    blockRect.origin    = CGPointZero;
    blockRect.size      = self.contentSize;
    
    if (CGRectContainsPoint(blockRect, touchPoint)) {
        [[DeblockAppDelegate get].gameLayer.fieldLayer destroyBlock:self];
        return YES;
    }
    
    return NO;
}


- (void)randomEvent:(ccTime)dt {
    
    if (random() % 1000 > 1)
        // 1 chance in 1000 to occur.
        return;

    [self blink];
}


- (void)blink {
    
    CCActionTween *animateColor = [CCActionTween actionWithDuration:0.3f key:@"colorMultiplier"
                                                               from:1.0f to:1.5f];
    [self runAction:[CCSequence actions:animateColor, [animateColor reverse], nil]];
}


- (void)crumble {
    
    [self notifyCrumble];
    
    CCActionTween *animateFrames    = [CCActionTween actionWithDuration:0.4f key:@"frame"
                                                                   from:0 to:self.frames - 1];
    
    CCParticleSystem *crumbleEmitter    = [[CCParticleSmoke alloc] initWithTotalParticles:1000];
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
    crumbleEmitter.sourcePosition       = ccp(self.position.x + self.contentSize.width / 2,
                                              self.position.y + self.contentSize.height / 3);
#if TARGET_IPHONE_SIMULATOR
    crumbleEmitter.startColor           = ccc4f(1, 1, 1, 0.3f);
    crumbleEmitter.endColor             = ccc4f(1, 1, 1, 0);
#else
    crumbleEmitter.startColor           = ccc4f(0.3f, 0.3f, 0.3f, 0.3f);
    crumbleEmitter.endColor             = ccc4f(0, 0, 0, 0);
#endif
    crumbleEmitter.autoRemoveOnFinish   = YES;
    [self.parent addChild:crumbleEmitter];
    [crumbleEmitter release];


    [self runAction:[CCSequence actions:
                     animateFrames,
                     [CCCallFunc actionWithTarget:self selector:@selector(notifyCrumbled)],
                     nil]];
}


- (BOOL)moving {
    
    return self.moveAction && ![self.moveAction isDone];
}


- (BOOL)valid {
    
    return !self.moving && !self.destroyed && self.destructible;
}


- (void)draw {

    [super draw];

    ccColor4B fromC = self.blockColor;
    fromC.r         = fminf(0xff, fmaxf(0x00, fromC.r * self.modColor.r));
    fromC.g         = fminf(0xff, fmaxf(0x00, fromC.g * self.modColor.g));
    fromC.b         = fminf(0xff, fmaxf(0x00, fromC.b * self.modColor.b));
    fromC.a         = fminf(0xff, fmaxf(0x00, fromC.a * self.modColor.a));
    ccColor4B toC   = fromC;
    toC.r           = fmaxf(0x00, toC.r * 0.5f);
    toC.g           = fmaxf(0x00, toC.g * 0.5f);
    toC.b           = fmaxf(0x00, toC.b * 0.5f);
    
    // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
    //glEnableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    //glEnable(GL_TEXTURE_2D);
    
    //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glColor4ub( fromC.r, fromC.g, fromC.b, fromC.a);
    
    CGRect textureRect;
    textureRect.origin = CGPointZero;
    textureRect.size   = self.contentSize;
    [self.textures[self.frame] drawInRect:textureRect];
	
	glColor4ub( 255, 255, 255, 255);
    
    //glDisableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    //glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    //glDisable(GL_TEXTURE_2D);
    
    /*
    CGPoint to    = CGPointMake(self.contentSize.width, self.contentSize.height);
    DrawBoxFrom(CGPointZero, to, fromC, toC);
    DrawBorderFrom(CGPointZero, to, fromC, 1.0f);
     */
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
    if (properties.length)
        [properties deleteCharactersInRange:NSMakeRange(0, 2)];
    
    return [NSString stringWithFormat:@"<%d,%d: %@:%d [%@]>",
            row, col, [self class], self.type, properties];
}

- (void)dealloc {

    free(self.textures);
    self.textures = nil;
    
    self.moveAction = nil;
    self.label = nil;
    self.dropEmitter = nil;

    [super dealloc];
}

@end
