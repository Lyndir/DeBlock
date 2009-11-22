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

#import "SpecialBlocks.h"
#import "FieldLayer.h"
#import "DeblockAppDelegate.h"

#define dFreezeTime 30


@implementation SpecialBlockLayer

- (BOOL)isLinkedToAdjecentBlock:(BlockLayer *)block forReason:(DMScanReason)aReason {
    
    if (aReason == DMScanReasonFreezing)
        // When freezing, never link to special blocks.
        return NO;
    
    return [super isLinkedToAdjecentBlock:block forReason:aReason];
}
    

@end


@implementation BombBlockLayer


+ (NSUInteger)occurancePercentForLevel:(NSUInteger)level type:(DMBlockType)aType {
    
    // Start at 5%.  Every 5 levels, reduce by 1%.  Minimum is 1% (at level 20).
    return max(1, 5 - level / 5);
}

- (id)initWithType:(DMBlockType)aType blockSize:(CGSize)size {
    
    if (!(self = [super initWithType:aType blockSize:size]))
        return nil;
    
    self.type           = DMBlockTypeSpecial;
    
    [textures[0] release];
    textures[0]         = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.bomb.png"] retain];
    
    return self;
}

- (NSMutableSet *)findLinkedBlocksInField:(FieldLayer *)field forReason:(DMScanReason)aReason
                                    atRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    NSMutableSet *linkedBlocks = [NSMutableSet setWithCapacity:8];
    for (NSInteger r = aRow - 1; r <= aRow + 1; ++r) {
        for (NSInteger c = aCol - 1; c <= aCol + 1; ++c) {
            BlockLayer *block = [field blockAtRow:r col:c];
            if (block == nil)
                // No block there.
                continue;
            
            [linkedBlocks addObject:block];
        }
    }
    
    return linkedBlocks;
}

@end


@interface MorphBlockLayer ()

- (void)switchType:(ccTime)dt;

@end

@implementation MorphBlockLayer

+ (NSUInteger)occurancePercentForLevel:(NSUInteger)level type:(DMBlockType)aType {
    
    // Start at 0%.  Every 5 levels, add 1%.  Maximum is 10% (at level 50).
    return min(10, level / 5);
}

- (id)initWithType:(DMBlockType)aType blockSize:(CGSize)size {
    
    if (!(self = [super initWithType:aType blockSize:size]))
        return nil;
    
    [textures[0] release];
    textures[0]         = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.morph.png"] retain];

    return self;
}

- (void)onEnter {
    
    [super onEnter];
    
    [self schedule:@selector(switchType:) interval:1];
}

- (void)switchType:(ccTime)dt {
    
    if (!self.destructible) {
        // Block has become indestructible, stop morphing.
        [self unschedule:@selector(switchType:)];
        return;
    }
    
    self.type = [[self class] randomType];
}

- (BOOL)isLinkedToAdjecentBlock:(BlockLayer *)block forReason:(DMScanReason)aReason {
    
    if (aReason == DMScanReasonCheckState && self.destructible)
        // When checking game state, always considder morphing blocks as linked.
        return YES;
    
    return [super isLinkedToAdjecentBlock:block forReason:aReason];
}


@end


@implementation ZapBlockLayer

+ (NSUInteger)occurancePercentForLevel:(NSUInteger)level type:(DMBlockType)aType {
    
    if ([self getBlocksOfClass:[self class] andType:aType])
        // Don't allow multiple Zap blocks of the same type in the field.
        return 0;
    
    if (level > 40)
        // From level 40 on, no more zappers.
        return 0;
    
    // Start at 0%.  Every 8 levels, add 1%.  Maximum is 5% (at level 40).
    return min(3, level / 8);
}

- (id)initWithType:(DMBlockType)aType blockSize:(CGSize)size {
    
    if (!(self = [super initWithType:aType blockSize:size]))
        return nil;
    
    [textures[0] release];
    textures[0]         = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.zap.png"] retain];
    
    return self;
}

- (BOOL)isLinkedToAdjecentBlock:(BlockLayer *)block forReason:(DMScanReason)aReason {
    
    if (aReason == DMScanReasonDestroying)
        // When destroying blocks, never link to zapper blocks.
        return NO;
    
    return [super isLinkedToAdjecentBlock:block forReason:aReason];
}

- (BOOL)isRecursingLinks {
    
    return NO;
}

- (NSMutableSet *)findLinkedBlocksInField:(FieldLayer *)field forReason:(DMScanReason)aReason
                                    atRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    NSMutableSet *linkedBlocks = [NSMutableSet setWithCapacity:8];
    for (NSInteger r = 0; r < field.blockRows; ++r) {
        for (NSInteger c = 0; c < field.blockColumns; ++c) {
            BlockLayer *block = [field blockAtRow:r col:c];
            if (block == nil)
                // Let's not destroy non-existing blocks.
                continue;
            
            if (block != self) {
                // Allow self either way.
                
                if (![block isLinkedToAdjecentBlock:self forReason:aReason])
                    // Block is not linked to us by standard rules.
                    continue;
                
                if ([block isKindOfClass:[SpecialBlockLayer class]])
                    if (![block isKindOfClass:[FreezeBlockLayer class]])
                        // Don't zap specials (except for freeze blocks, those are allowed to be zapped).
                        continue;
            }
            
            [linkedBlocks addObject:block];
        }
    }
    
    return linkedBlocks;
}

- (BOOL)scoreMultiplier {
    
    return 0;
}

@end

@interface FreezeBlockLayer ()

- (void)cool;
- (void)freeze;

@end

@implementation FreezeBlockLayer

+ (NSUInteger)occurancePercentForLevel:(NSUInteger)level type:(DMBlockType)aType {
    
    // Start at 0%.  Every 10 levels, add 1%.  Maximum is 15% (at level 75).
    return min(15, level / 10);
}

- (id)initWithType:(DMBlockType)aType blockSize:(CGSize)size {
    
    if (!(self = [super initWithType:aType blockSize:size]))
        return nil;
    
    [textures[0] release];
    textures[0]         = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.freeze.png"] retain];
    
    return self;
}

- (void)onEnter {
    
    [super onEnter];
    
    timeLeft = dFreezeTime;
    [label setString:[NSString stringWithFormat:@"%d", max(0, timeLeft)]];
    [self runAction:[Sequence actionOne:[Repeat actionWithAction:[Sequence actionOne:[DelayTime actionWithDuration:1]
                                                                                 two:[CallFunc actionWithTarget:self selector:@selector(cool)]]
                                                           times:timeLeft]
                                    two:[CallFunc actionWithTarget:self selector:@selector(freeze)]]];
}

- (void)cool {
    
    --timeLeft;
    [label setString:[NSString stringWithFormat:@"%d", max(0, timeLeft)]];
}

- (void)freeze {

    [label setString:@""];

    NSInteger row, col;
    FieldLayer *field = [DeblockAppDelegate get].gameLayer.fieldLayer;
    if (![field findPositionOfBlock:self toRow:&row col:&col])
        // Block has already been destroyed.
        return;
    
    NSMutableSet *linkedBlocks = [NSMutableSet new];
    [self getLinksInField:field forReason:DMScanReasonFreezing
                    toSet:linkedBlocks];

    for (BlockLayer *block in linkedBlocks) {
        block.destructible  = NO;
        block.type          = DMBlockTypeFrozen;
    }
    
    self.destructible       = NO;
    self.type               = DMBlockTypeFrozen;
    
    [linkedBlocks release];
    [field checkGameState];
}

@end
