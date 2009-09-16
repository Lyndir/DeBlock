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


@implementation SpecialBlockLayer

- (id)initWithBlockSize:(CGSize)size {

    if (!(self = [super initWithBlockSize:size]))
        return nil;
    
    self.type = DMBlockTypeSpecial;
    
    return self;
}

- (void)crumble {
    
    [AudioController vibrate];

    [super crumble];
}

@end


@implementation BombBlockLayer

+ (NSUInteger)minimumLevel {
    
    return 0;
}

- (id)initWithBlockSize:(CGSize)size {
    
    if (!(self = [super initWithBlockSize:size]))
        return nil;
    
    [textures[0] release];
    textures[0]         = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.bomb.png"] retain];
    
    return self;
}

- (NSString *)labelString {
    
    return @"B";
}

- (NSMutableSet *)findLinkedBlocksInField:(FieldLayer *)field atRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    NSMutableSet *linkedBlocks = [NSMutableSet setWithCapacity:8];
    for (NSInteger r = aRow - 1; r <= aRow + 1; ++r) {
        for (NSInteger c = aCol - 1; c <= aCol + 1; ++c) {
            BlockLayer *block = [field blockAtRow:r col:c];
            if (block == nil || block == self)
                // Bad block, ignore.
                continue;
            
            [linkedBlocks addObject:block];
        }
    }
    
    return linkedBlocks;
}

@end


@implementation MorphBlockLayer

+ (NSUInteger)minimumLevel {
    
    return 2;
}

- (id)initWithBlockSize:(CGSize)size {
    
    if (!(self = [super initWithBlockSize:size]))
        return nil;
    
    self.type = [[self class] randomType];
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

- (NSString *)labelString {
    
    return @"M";
}

@end


@implementation ZapBlockLayer

+ (NSUInteger)minimumLevel {
    
    return 5;
}

- (id)initWithBlockSize:(CGSize)size {
    
    if (!(self = [super initWithBlockSize:size]))
        return nil;
    
    self.type = [[self class] randomType];
    [textures[0] release];
    textures[0]         = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.zap.png"] retain];
    
    return self;
}

- (NSString *)labelString {
    
    return @"Z";
}

- (NSMutableSet *)findLinkedBlocksInField:(FieldLayer *)field atRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    NSMutableSet *linkedBlocks = [NSMutableSet setWithCapacity:8];
    for (NSInteger r = 0; r < field.blockRows; ++r) {
        for (NSInteger c = 0; c < field.blockColumns; ++c) {
            BlockLayer *block = [field blockAtRow:r col:c];
            if (block == nil || block == self)
                // Bad block, ignore.
                continue;
            
            if (block.type == self.type && block.destructible)
                [linkedBlocks addObject:block];
        }
    }
    
    return linkedBlocks;
}

@end


@implementation FreezeBlockLayer

+ (NSUInteger)minimumLevel {
    
    return 10;
}

- (id)initWithBlockSize:(CGSize)size {
    
    if (!(self = [super initWithBlockSize:size]))
        return nil;
    
    self.type = [[self class] randomType];
    [textures[0] release];
    textures[0]         = [[[TextureMgr sharedTextureMgr] addImage:@"block.whole.freeze.png"] retain];
    
    return self;
}

- (void)onEnter {
    
    [super onEnter];
    
    ccColor4B targetColor = [[self class] colorForType:DMBlockTypeFrozen];
    [self runAction:[Sequence actionOne:[TintTo actionWithDuration:10 red:targetColor.r green:targetColor.g blue:targetColor.b]
                                    two:[CallFunc actionWithTarget:self selector:@selector(freeze)]]];
}

- (NSString *)labelString {
    
    return @"F";
}

- (void)freeze {

    NSInteger row, col;
    FieldLayer *field = [DeblockAppDelegate get].gameLayer.fieldLayer;
    if (![field findPositionOfBlock:self toRow:&row col:&col])
        // Block has already been destroyed.
        return;
    
    NSMutableSet *linkedBlocks = [NSMutableSet new];
    [self getLinksInField:field toSet:linkedBlocks recurse:YES specialLinks:NO];

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
