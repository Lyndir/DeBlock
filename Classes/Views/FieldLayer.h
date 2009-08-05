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

@interface FieldLayer : Layer <Resettable> {

@private
    Label                       *msgLabel, *infoLabel;

    BOOL                        locked;

    NSInteger                   blockRows, blockColumns;
    NSInteger                   gravityRow, gravityColumn;
    CGFloat                     blockPadding;    
    BlockLayer                  ***blockGrid;
}

@property (readonly) BOOL       locked;

- (BlockLayer *)blockAtRow:(NSInteger)aRow col:(NSInteger)aCol;
- (BlockLayer *)blockAtTargetRow:(NSInteger)aRow col:(NSInteger)aCol;
- (NSArray *)blocksInRow:(NSInteger)aRow;
- (NSArray *)blocksInCol:(NSInteger)aCol;
- (NSArray *)blocksInTargetRow:(NSInteger)aRow;
- (NSArray *)blocksInTargetCol:(NSInteger)aCol;
- (NSArray *)findLinkedBlocksOfBlockAtRow:(NSInteger)aRow col:(NSInteger)aCol;
- (BOOL)findPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger *)aRow col:(NSInteger *)aCol;
- (void)getPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger *)aRow col:(NSInteger *)aCol;
- (void)setPositionOfBlock:(BlockLayer *)aBlock toRow:(NSInteger)aRow col:(NSInteger)aCol;
- (void)destroyBlock:(BlockLayer *)aBlock;

-(void) startGame;
-(void) stopGame;

-(void) message: (NSString *)msg on:(CocosNode *)node;
-(void) message: (NSString *)msg at:(CGPoint)point;

@end
