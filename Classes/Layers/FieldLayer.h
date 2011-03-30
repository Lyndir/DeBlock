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
//  CityLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "Resettable.h"
#import "BlockLayer.h"
foo
@interface FieldLayer : CCLayer <Resettable> {

@private
    CCLabelTTF                  *_msgLabel;

    BOOL                        _locked;

    NSInteger                   _blockRows, _blockColumns;
    NSInteger                   _gravityRow, _gravityColumn;
    CGFloat                     _blockPadding;
    BlockLayer                  ***_blockGrid;
}

@property (readonly) BOOL       locked;
@property (readonly) NSInteger  blockRows;
@property (readonly) NSInteger  blockColumns;

- (BlockLayer *)blockAtRow:(NSInteger)aRow col:(NSInteger)aCol;
- (BlockLayer *)blockAtTargetRow:(NSInteger)aRow col:(NSInteger)aCol;
- (NSArray *)blocksInRow:(NSInteger)aRow;
- (NSArray *)blocksInCol:(NSInteger)aCol;
- (NSArray *)blocksInTargetRow:(NSInteger)aRow;
- (NSArray *)blocksInTargetCol:(NSInteger)aCol;
- (BOOL)findPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger *)aRow col:(NSInteger *)aCol;
- (void)getPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger *)aRow col:(NSInteger *)aCol;
- (void)setPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger)aRow col:(NSInteger)aCol;
- (void)destroyBlock:(BlockLayer *)aBlock;

- (void)startGame;
- (void)stopGame;
- (void)checkGameState;

- (void)message: (NSString *)msg on:(CCNode *)node;
- (void)message: (NSString *)msg at:(CGPoint)point;

@end
