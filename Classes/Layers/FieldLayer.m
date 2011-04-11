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
//  CityLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "FieldLayer.h"
#import "DeblockAppDelegate.h"

#define kAllGridLevel   40
#define kMinColumns     5
#define kMaxColumns     10
#define kMinRows        3
#define kMaxRows        8

@interface FieldLayer ()

- (NSInteger)destroyBlock:(BlockLayer *)aBlock forced:(BOOL)forced;
- (void)destroySingleBlock:(BlockLayer *)aBlock;

- (void)startDropping;
- (BOOL)dropBlockAtRow:(NSInteger)row col:(NSInteger)col;
- (void)doneDroppingBlock:(BlockLayer *)block;
- (void)droppingFinished;

- (void)startCollapsing;
- (BOOL)collapseBlocksAtCol:(NSInteger)col;
- (void)doneCollapsingBlock:(BlockLayer *)block;
- (void)collapsingFinished;

- (void)blinkAll;
- (void)destroyAll;

@property (readwrite, retain) CCLabelTTF                  *msgLabel;

@property (readwrite, assign) BOOL                        locked;

@property (readwrite, assign) NSInteger                   blockRows;
@property (readwrite, assign) NSInteger                   blockColumns;
@property (readwrite, assign) NSInteger                   gravityRow;
@property (readwrite, assign) NSInteger                   gravityColumn;
@property (readwrite, assign) CGFloat                     blockPadding;
@property (readwrite, assign) BlockLayer                  ***blockGrid;

@end


@implementation FieldLayer

@synthesize msgLabel = _msgLabel;
@synthesize locked = _locked;
@synthesize blockRows = _blockRows, blockColumns = _blockColumns;
@synthesize gravityRow = _gravityRow, gravityColumn = _gravityColumn;
@synthesize blockPadding = _blockPadding;
@synthesize blockGrid = _blockGrid;



-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    self.blockPadding    = 0;
    self.locked          = YES;
    
    return self;
}


-(void) registerWithTouchDispatcher {
    
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}



-(void) reset {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGFloat hudHeight = [DeblockAppDelegate get].hudLayer.contentSize.height;
    if (![DeblockAppDelegate get].hudLayer.visible)
        hudHeight = 0;
    
    self.contentSize = CGSizeMake(winSize.width * 9/10,
                                  winSize.height * 4/5);
    self.position    = ccp((winSize.width - self.contentSize.width) / 2.0f,
                           (winSize.height - self.contentSize.height - hudHeight) / 2.0f + hudHeight);    

    // Clean up.
    [self stopAllActions];
    
    if (self.blockGrid) {
        for (NSInteger row = 0; row < self.blockRows; ++row) {
            for (NSInteger col = 0; col < self.blockColumns; ++col) {
                BlockLayer *block = self.blockGrid[row][col];
                if (!block)
                    continue;
                
                [self removeChild:block cleanup:YES];
                [self.blockGrid[row][col] release];
                self.blockGrid[row][col] = nil;
            }
            free(self.blockGrid[row]);
        }
        free(self.blockGrid);
    }
    
    // Level-based field parameters.
    self.blockColumns    = fmaxf(fminf(kMaxColumns * [Player currentPlayer].level / kAllGridLevel, kMaxColumns), kMinColumns);
    self.blockRows       = fmaxf(fminf(kMaxColumns * [Player currentPlayer].level / kAllGridLevel, kMaxRows), kMinColumns);
    self.gravityRow      = 0;
    self.gravityColumn   = self.blockColumns / 2;
    self.blockGrid       = malloc(sizeof(BlockLayer **) * self.blockRows);
    for (NSInteger row = 0; row < self.blockRows; ++row) {
        self.blockGrid[row] = malloc(sizeof(BlockLayer *) * self.blockColumns);
        for (NSInteger col = 0; col < self.blockColumns; ++col)
            // Nil the grid so we can iterate through it before it's been completely filled up.
            self.blockGrid[row][col] = nil;
    }
    
    // Build field of blocks.
    CGSize blockSize        = CGSizeMake((self.contentSize.width   - self.blockPadding) / self.blockColumns  - self.blockPadding,
                                         (self.contentSize.height  - self.blockPadding) / self.blockRows     - self.blockPadding);
    
    for (NSInteger row = 0; row < self.blockRows; ++row) {
        for (NSInteger col = 0; col < self.blockColumns; ++col) {
            
            BlockLayer *block = [BlockLayer randomBlockForLevel:[Player currentPlayer].level withSize:blockSize];
            block.position = ccp(col * (blockSize.width     + self.blockPadding) + self.blockPadding,
                                 row * (blockSize.height    + self.blockPadding) + self.blockPadding);
            
            [self addChild:block];
            self.blockGrid[row][col] = [block retain];
        }
    }
}


- (BlockLayer *)blockAtRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    if (aRow < 0 || aCol < 0)
        return nil;
    if (aRow >= self.blockRows || aCol >= self.blockColumns)
        return nil;
    
    return self.blockGrid[aRow][aCol];
}


- (BlockLayer *)blockAtTargetRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    for (NSInteger row = 0; row < self.blockRows; ++row)
        for (NSInteger col = 0; col < self.blockColumns; ++col) {
            BlockLayer *block = self.blockGrid[row][col];
            if (!block)
                continue;
            
            if (block.targetRow == aRow && block.targetCol == aCol)
                return block;
        }
    
    return nil;
}


- (NSArray *)blocksInRow:(NSInteger)aRow {
    
    NSMutableArray *blocks = [NSMutableArray arrayWithCapacity:self.blockColumns];
    for (NSInteger col = 0; col < self.blockColumns; ++col) {
        BlockLayer *block = self.blockGrid[aRow][col];
        if (block)
            [blocks addObject:block];
    }
    
    return blocks;
}


- (NSArray *)blocksInCol:(NSInteger)aCol {
    
    NSMutableArray *blocks = [NSMutableArray arrayWithCapacity:self.blockRows];
    for (NSInteger row = 0; row < self.blockRows; ++row) {
        BlockLayer *block = self.blockGrid[row][aCol];
        if (block)
            [blocks addObject:block];
    }
    
    return blocks;
}


- (NSArray *)blocksInTargetRow:(NSInteger)aRow {
    
    NSMutableArray *blocks = [NSMutableArray arrayWithCapacity:self.blockColumns];
    for (NSInteger col = 0; col < self.blockColumns; ++col) {
        BlockLayer *block = [self blockAtTargetRow:aRow col:col];
        if (block)
            [blocks addObject:block];
    }
    
    return blocks;
}


- (NSArray *)blocksInTargetCol:(NSInteger)aCol {
    
    NSMutableArray *blocks = [NSMutableArray arrayWithCapacity:self.blockRows];
    for (NSInteger row = 0; row < self.blockRows; ++row) {
        BlockLayer *block = [self blockAtTargetRow:row col:aCol];
        if (block)
            [blocks addObject:block];
    }
    
    return blocks;
}


- (BOOL)findPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger *)aRow col:(NSInteger *)aCol {
    
    for (NSInteger row = 0; row < self.blockRows; ++row)
        for (NSInteger col = 0; col < self.blockColumns; ++col)
            if ([self blockAtRow:row col:col] == aBlock) {
                if (aRow)
                    *aRow = row;
                if (aCol)
                    *aCol = col;
                
                return YES;
            }
    
    return NO;
}

- (void)getPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger *)aRow col:(NSInteger *)aCol {
    
    if (![self findPositionOfBlock:aBlock toRow:aRow col:aCol])
        [NSException raise:NSInternalInconsistencyException format:@"Given block is not in the field."];
}


- (void)setPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger)aRow col:(NSInteger)aCol {
    
    // By default, aBlock's old grid location must be unset (no more block there).
    BlockLayer *oldBlock = nil;
    
    BlockLayer *block = [self blockAtRow:aRow col:aCol];
    if (block) {
        if (block == aBlock)
            // Block already at its target destination.
            return;
        
        else if ([block moving])
            // However, if aBlock lands on a spot where another block is still moving from, back the other block up
            // to aBlock's old grid location so that it still remains in the grid and can still be found by any search operation.
            // When this other block is done moving it will unset this position itself (or trigger this behaviour again).
            oldBlock = block;
        else
            [NSException raise:NSInternalInconsistencyException format:@"Tried to set a block to a position that is occupied."];
    }
    
    NSInteger row, col;
    if ([self findPositionOfBlock:aBlock toRow:&row col:&col])
        self.blockGrid[row][col] = oldBlock;
    
    self.blockGrid[aRow][aCol] = aBlock;
}


- (void)destroyBlock:(BlockLayer *)aBlock {
    
    self.locked = YES;
    
    CGPoint blockPoint = aBlock.position;
    blockPoint.x += aBlock.contentSize.width / 2.0f;
    blockPoint.y += aBlock.contentSize.height;
    
    NSInteger destroyedBlocks = [self destroyBlock:aBlock forced:NO];
    NSInteger points = powf(destroyedBlocks, 1.5f);
    if (points) {
        if (![[DeblockConfig get].kidsMode boolValue]) {
            [DeblockConfig get].levelScore = [NSNumber numberWithInt:[[DeblockConfig get].levelScore intValue] + points];
            [[DeblockAppDelegate get].hudLayer updateHudWasGood:points > 0];
        }
        
        [self message:[NSString stringWithFormat:@"%+d", points] at:blockPoint];
    }
    
    [self performSelector:@selector(startDropping) withObject:nil afterDelay:0.5f];
}


- (NSInteger)destroyBlock:(BlockLayer *)aBlock forced:(BOOL)forced {
    
    NSMutableSet *linkedBlocks = [NSMutableSet set];
    [aBlock getLinksInField:self forReason:DMScanReasonDestroying
                      toSet:linkedBlocks];
    
    // No links and not forced, give up.
    if (!forced && ![linkedBlocks count])
        return 0;
    
    // Destroy this block and those linked to it.
    float multiplier = 1;
    [linkedBlocks addObject:aBlock];
    for (BlockLayer *block in linkedBlocks) {
        multiplier *= [block scoreMultiplier];
        [self destroySingleBlock:block];
    }
    
    return ([linkedBlocks count] - 1) * multiplier;
}


- (void)destroySingleBlock:(BlockLayer *)aBlock {
    
    // Find the position of the block to destroy.
    NSInteger row, col;
    [self getPositionOfBlock:aBlock toRow:&row col:&col];
    
    // Destroy the block.
    aBlock.destroyed    = YES;
    [self reorderChild:aBlock z:1];
    [aBlock crumble];
    
    [self.blockGrid[row][col] release];
    self.blockGrid[row][col] = nil;
}


- (void)startDropping {
    
    for (NSInteger row = 0; row < self.blockRows; ++row)
        for (NSInteger col = 0; col < self.blockColumns; ++col) {
            self.blockGrid[row][col].targetRow = row;
            self.blockGrid[row][col].targetCol = col;
        }
    
    BOOL anyBlockDropping = NO;
    for (NSInteger col = 0; col < self.blockColumns; ++col) {
        for (NSInteger row = self.gravityRow + 1; row < self.blockRows; ++row)
            anyBlockDropping |= [self dropBlockAtRow:row col:col];
        for (NSInteger row = self.gravityRow - 1; row >= 0; --row)
            anyBlockDropping |= [self dropBlockAtRow:row col:col];
    }
    
    if (!anyBlockDropping)
        // No blocks are dropping => dropping blocks is done.
        [self droppingFinished];
}


- (BOOL)dropBlockAtRow:(NSInteger)row col:(NSInteger)col {
    
    BlockLayer *block = [self blockAtRow:row col:col];
    if (!block || block.moving)
        // No block here or block already moving.
        return NO;
    
    
    NSInteger gravityRowDirection = self.gravityRow - row;
    if (gravityRowDirection == 0)
        // Hit the gravity "floor", stop dropping.
        return NO;
    gravityRowDirection /= fabsf(gravityRowDirection);
    
    // Row dropping.
    block.targetRow = row;
    while (YES) {
        if (block.targetRow == self.gravityRow)
            // Hit the gravity "floor", stop dropping.
            break;
        
        if ([self blockAtTargetRow:block.targetRow + gravityRowDirection col:block.targetCol])
            // Hit a block, stop dropping.
            break;
        
        block.targetRow += gravityRowDirection;
    }
    if (block.targetRow == row)
        // This block is already at its target, no moving needs to be done.
        return NO;
    
    CGFloat dropHeight = fabsf(row - block.targetRow) * (block.contentSize.height + self.blockPadding) * gravityRowDirection;
    ccTime duration = 0.3f * fabsf(dropHeight) / 100.0f;
    
    [block runAction:block.moveAction = [CCSequence actions:
                                         [CCEaseSineIn actionWithAction:
                                          [CCMoveBy actionWithDuration:duration position:ccp(0, dropHeight)]],
                                         [CCCallFunc actionWithTarget:block selector:@selector(notifyDropped)],
                                         [CCEaseSineIn actionWithAction:
                                          [CCMoveBy actionWithDuration:duration / 3 position:ccp(0, -dropHeight / 20)]],
                                         [CCEaseSineIn actionWithAction:
                                          [CCMoveBy actionWithDuration:duration / 3 position:ccp(0, dropHeight / 20)]],
                                         [CCEaseSineIn actionWithAction:
                                          [CCMoveBy actionWithDuration:duration / 6 position:ccp(0, -dropHeight / 40)]],
                                         [CCEaseSineIn actionWithAction:
                                          [CCMoveBy actionWithDuration:duration / 6 position:ccp(0, dropHeight / 40)]],
                                         [CCCallFuncN actionWithTarget:self selector:@selector(doneDroppingBlock:)],
                                         nil]];
    
    return YES;
}


- (void)doneDroppingBlock:(BlockLayer *)block {
    
    [self setPositionOfBlock:block toRow:block.targetRow col:block.targetCol];
    
    [block stopAction:block.moveAction];
    block.moveAction = nil;
    
    BOOL allDoneDropping = YES;
    for (NSInteger row = 0; row < self.blockRows && allDoneDropping; ++row)
        for (NSInteger col = 0; col < self.blockColumns && allDoneDropping; ++col)
            if ([self blockAtRow:row col:col].moving) {
                allDoneDropping = NO;
            }
    
    if (allDoneDropping)
        [self droppingFinished];
}


- (void)droppingFinished {
    
    [self startCollapsing];
}


- (void)startCollapsing {
    
    BOOL anyBlockCollapsing = NO;
    for (NSInteger col = self.gravityColumn + 1; col < self.blockColumns; ++col)
        anyBlockCollapsing |= [self collapseBlocksAtCol:col];
    for (NSInteger col = self.gravityColumn - 1; col >= 0; --col)
        anyBlockCollapsing |= [self collapseBlocksAtCol:col];
    
    if (!anyBlockCollapsing)
        // No blocks are collapsing => collapsing blocks is done.
        [self collapsingFinished];
}


- (BOOL)collapseBlocksAtCol:(NSInteger)col {
    
    
    NSInteger gravityColDirection = self.gravityColumn - col;
    if (gravityColDirection == 0)
        // Hit the gravity "wall", stop collapsing.
        return NO;
    gravityColDirection /= fabsf(gravityColDirection);
    
    // Column collapsing.
    NSInteger targetCol = col;
    while (YES) {
        if (targetCol == self.gravityColumn)
            // Hit the gravity "wall", stop collapsing.
            break;
        
        if ([[self blocksInTargetCol:targetCol + gravityColDirection] count])
            // Hit a non-empty column, stop collapsing.
            break;
        
        targetCol += gravityColDirection;
    }
    if (targetCol == col)
        // This column is already at its target, no moving needs to be done.
        return NO;
    
    BOOL anyBlockCollapsing = NO;
    for (NSInteger row = 0; row < self.blockRows; ++row) {
        BlockLayer *block = [self blockAtRow:row col:col];
        if (!block || block.moving)
            // No block here or block already moving.
            continue;
        
        
        block.targetCol = targetCol;
        CGFloat dropWidth = fabsf(col - block.targetCol) * (block.contentSize.width + self.blockPadding) * gravityColDirection;
        
        [block runAction:block.moveAction = [CCSequence actionOne:[CCMoveBy actionWithDuration:0.3f position:ccp(dropWidth, 0)]
                                                              two:[CCCallFuncN actionWithTarget:self selector:@selector(doneCollapsingBlock:)]]];
        anyBlockCollapsing = YES;
    }
    
    return anyBlockCollapsing;
}


- (void)doneCollapsingBlock:(BlockLayer *)block {
    
    [self setPositionOfBlock:block toRow:block.targetRow col:block.targetCol];
    
    [block stopAction:block.moveAction];
    block.moveAction = nil;
    [block notifyCollapsed];
    
    BOOL allDoneCollapsing = YES;
    for (NSInteger row = 0; row < self.blockRows && allDoneCollapsing; ++row)
        for (NSInteger col = 0; col < self.blockColumns && allDoneCollapsing; ++col)
            if ([self blockAtRow:row col:col].moving)
                allDoneCollapsing = NO;
    
    if (allDoneCollapsing)
        [self collapsingFinished];
}


- (void)collapsingFinished {
    
    [self checkGameState];
    
    self.locked = NO;
}

- (void)checkGameState {
    
    if (![DeblockAppDelegate get].gameLayer.running)
        return;
    
    NSMutableSet *allLinkedBlocks = [NSMutableSet new];
    NSUInteger blocksLeft = 0;
    for (NSInteger row = 0; row < self.blockRows; ++row)
        for (NSInteger col = 0; col < self.blockColumns; ++col) {
            BlockLayer *block = self.blockGrid[row][col];
            if (!block)
                continue;
            
            ++blocksLeft;
            [block getLinksInField:self forReason:DMScanReasonCheckState toSet:allLinkedBlocks];
        }
    NSUInteger linksLeft = [allLinkedBlocks count];
    [allLinkedBlocks release];
    
    if (!linksLeft) {
        DbEndReason endReason = DbEndReasonNextField;
        NSInteger levelPoints = [[DeblockConfig get].levelScore intValue] + [[DeblockConfig get].levelPenalty intValue];
        NSInteger bonusPoints = 0;
        NSUInteger newLevel = [Player currentPlayer].level;
        
        if (!blocksLeft) {
            // No blocks left -> flawless finish.
            [[DeblockAppDelegate get].uiLayer message:l(@"message.flawless")];
            bonusPoints = [[DeblockConfig get].flawlessBonus intValue] * [Player currentPlayer].level;
            [self message:[NSString stringWithFormat:@"%+d", bonusPoints]
                       at:ccp(self.contentSize.width / 2, self.contentSize.height / 2)];
            
            ++newLevel;
        } else if (blocksLeft <= 8) {
            // Blocks left under minimum block limit -> level up.
            ++newLevel;
        } else {
            // Blocks left over minimum block limit -> game over.
            levelPoints = 0;
            endReason = DbEndReasonGameOver;
        }
        
        levelPoints += bonusPoints;
        if (![[DeblockConfig get].kidsMode boolValue])
            [[DeblockConfig get] addScore:levelPoints];
        [Player currentPlayer].level = newLevel;
        [[DeblockAppDelegate get].hudLayer updateHudWasGood:bonusPoints > 0];
        [[DeblockAppDelegate get].gameLayer stopGame:endReason];
    }
}


-(void) message:(NSString *)msg on:(CCNode *)node {
    
    [self message:msg at:ccp(node.position.x, node.position.y + node.contentSize.height)];
}


-(void) message:(NSString *)msg at:(CGPoint)point {
    
    if(self.msgLabel)
        [self.msgLabel stopAllActions];
    
    else {
        self.msgLabel = [CCLabelTTF labelWithString:@""
                                         dimensions:CGSizeMake(1000, [[Config get].fontSize intValue] + 5)
                                          alignment:UITextAlignmentCenter
                                           fontName:[Config get].fixedFontName
                                           fontSize:[[Config get].fontSize intValue]];
        
        [self addChild:self.msgLabel z:9];
    }
    
    [self.msgLabel setString:msg];
    self.msgLabel.position = point;
    
    // Make sure label remains on screen.
    CGSize winSize = [CCDirector sharedDirector].winSize;
    if([self.msgLabel position].x < [[Config get].fontSize intValue] / 2)                 // Left edge
        [self.msgLabel setPosition:ccp([[Config get].fontSize intValue] / 2, [self.msgLabel position].y)];
    if([self.msgLabel position].x > winSize.width - [[Config get].fontSize intValue] / 2) // Right edge
        [self.msgLabel setPosition:ccp(winSize.width - [[Config get].fontSize intValue] / 2, [self.msgLabel position].y)];
    if([self.msgLabel position].y < [[Config get].fontSize intValue] / 2)                 // Bottom edge
        [self.msgLabel setPosition:ccp([self.msgLabel position].x, [[Config get].fontSize intValue] / 2)];
    if([self.msgLabel position].y > winSize.width - [[Config get].fontSize intValue] * 2) // Top edge
        [self.msgLabel setPosition:ccp([self.msgLabel position].x, winSize.height - [[Config get].fontSize intValue] * 2)];
    
    // Color depending on whether message starts with -, + or neither.
    if([msg hasPrefix:@"+"])
        [self.msgLabel setColor:ccc3(0x66, 0xCC, 0x66)];
    else if([msg hasPrefix:@"-"])
        [self.msgLabel setColor:ccc3(0xCC, 0x66, 0x66)];
    else
        [self.msgLabel setColor:ccc3(0xFF, 0xFF, 0xFF)];
    
    // Animate the label to fade out.
    [self.msgLabel runAction:[CCSpawn actions:
                              [CCFadeOut actionWithDuration:3],
                              [CCSequence actions:
                               [CCDelayTime actionWithDuration:1],
                               [CCMoveBy actionWithDuration:2 position:ccp(0, [[Config get].fontSize intValue] * 2)],
                               nil],
                              nil]];
}


-(void) startGame {
    
    self.locked = NO;
    
    [[DeblockAppDelegate get].hudLayer updateHudWasGood:YES];
    [[DeblockAppDelegate get].gameLayer started];
}


-(void) stopGame {
    
    self.locked = YES;
    
    BOOL isEmpty = YES;
    for (NSInteger row = 0; row < self.blockRows && isEmpty; ++row)
        for (NSInteger col = 0; col < self.blockColumns && isEmpty; ++col)
            if (self.blockGrid[row][col]) {
                isEmpty = NO;
                break;
            }
    
    if (isEmpty)
        [[DeblockAppDelegate get].gameLayer stopped];
    else
        [self runAction:[CCSequence actions:
                         [CCCallFunc actionWithTarget:self selector:@selector(blinkAll)],
                         [CCDelayTime actionWithDuration:0.5f],
                         [CCCallFunc actionWithTarget:self selector:@selector(destroyAll)],
                         [CCDelayTime actionWithDuration:0.5f],
                         [CCCallFunc actionWithTarget:[DeblockAppDelegate get].gameLayer selector:@selector(stopped)],
                         nil]];
}


- (void)blinkAll {
    
    for (NSInteger row = 0; row < self.blockRows; ++row)
        for (NSInteger col = 0; col < self.blockColumns; ++col)
            [[self blockAtRow:row col:col] blink];
}


- (void)destroyAll {
    
    for (NSInteger row = 0; row < self.blockRows; ++row)
        for (NSInteger col = 0; col < self.blockColumns; ++col) {
            BlockLayer *block = self.blockGrid[row][col];
            
            if (block)
                [self destroySingleBlock:block];
        }
}


- (void)draw {
    
    [super draw];
    
    DrawBoxFrom(CGPointMake(-3, -3), CGPointMake(self.contentSize.width + 3, self.contentSize.height + 3),
                ccc4l([[DeblockConfig get].skyColorTo longValue] & 0x0f0f0f33), ccc4l([[DeblockConfig get].skyColorFrom longValue] & 0x0f0f0f33));
}


- (NSString *)description {
    
    NSMutableString *d = [NSMutableString new];
    [d appendString:@"    ||"];
    
    for (NSInteger col = 0; col < self.blockColumns; ++col)
        [d appendFormat:@" %02d  |", col];
    
    for (NSInteger row = self.blockRows - 1; row >= 0; --row) {
        [d appendFormat:@"\n %02d ||", row];
        for (NSInteger col = 0; col < self.blockColumns; ++col) {
            BlockLayer *block = self.blockGrid[row][col];
            if (block) {
                NSMutableString *properties = [NSMutableString stringWithCapacity:2];
                if (block.destroyed)
                    [properties appendString:@"d"];
                if (!block.destructible)
                    [properties appendString:@"i"];
                if (block.moving)
                    [properties appendString:@"m"];
                while ([properties length] < 2)
                    [properties appendString:@" "];
                
                [d appendFormat:@" %C%@ |",
                 [[[block class] description] characterAtIndex:0], properties];
            }
        }
    }
    
    return [d autorelease];
}


- (void)dealloc {
    
    if (self.blockGrid) {
        for (NSInteger row = 0; row < self.blockRows; ++row) {
            for (NSInteger col = 0; col < self.blockColumns; ++col) {
                BlockLayer *block = self.blockGrid[row][col];
                if (!block)
                    continue;
                
                [self removeChild:block cleanup:YES];
                [self.blockGrid[row][col] release];
                self.blockGrid[row][col] = nil;
            }
            free(self.blockGrid[row]);
        }
        free(self.blockGrid);
    }
    self.blockGrid = nil;
    
    self.msgLabel = nil;
    
    [super dealloc];
}


@end
