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
//  BlockLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//


typedef enum DMBlockType {
    DMBlockTypeOne,
    DMBlockTypeTwo,
    DMBlockTypeThree,
    DMBlockTypeFour,
    DMBlockTypeFive,
    DMBlockTypeCount,
    DMBlockTypeSpecial,
    DMBlockTypeFrozen,
} DMBlockType;

typedef enum DMScanReason {
    DMScanReasonDestroying,
    DMScanReasonCheckState,
    DMScanReasonFreezing
} DMScanReason;

@class FieldLayer;

@interface BlockLayer : CCLayer {

@protected
    CCTexture2D                                 **_textures;
    CCLabelTTF                                  *_label;

@private
    DMBlockType                                 _type;
    BOOL                                        _destroyed;
    BOOL                                        _destructible;

    NSInteger                                   _targetRow, _targetCol;
    NSUInteger                                  _frames, _frame;
    ccColor4B                                   _blockColor;
    ccColor4F                                   _modColor;

    CCActionInterval                            *_moveAction;

    CCParticleSystem                            *_dropEmitter;
}

@property (readwrite) DMBlockType               type;
@property (readwrite) BOOL                      destroyed;
/** Indicates whether this block can be destroyed when it is valid. */
@property (readwrite) BOOL                      destructible;
/** Indicates whether the conditions on this block mean algorithms should not considder it for destruction. */
@property (readonly) BOOL                       valid;
@property (readwrite, retain) CCActionInterval  *moveAction;

@property (readwrite) NSInteger                 targetRow;
@property (readwrite) NSInteger                 targetCol;

@property (readwrite) NSUInteger                frame;
@property (readonly) NSUInteger                 frames;
@property (readwrite) ccColor4F                 modColor;

+ (id)randomBlockForLevel:(NSUInteger)level withSize:(CGSize)size;
+ (NSUInteger)occurancePercentForLevel:(NSUInteger)level type:(DMBlockType)aType;
+ (ccColor4B)colorForType:(DMBlockType)aType;
+ (DMBlockType)randomType;
+ (NSUInteger)getBlocksOfClass:(Class)blockClass andType:(DMBlockType)aType;

- (id)initWithType:(DMBlockType)aType blockSize:(CGSize)size;

- (BOOL)moving;
- (BOOL)scoreMultiplier;

- (BOOL)isLinkedToAdjecentBlock:(BlockLayer *)block forReason:(DMScanReason)aReason;
- (NSMutableSet *)findLinkedBlocksInField:(FieldLayer *)field forReason:(DMScanReason)aReason
                                    atRow:(NSInteger)aRow col:(NSInteger)aCol;
- (BOOL)isRecursingLinks;
- (void)getLinksInField:(FieldLayer *)aField forReason:(DMScanReason)aReason
                   toSet:(NSMutableSet *)allLinkedBlocks;

- (void)blink;
- (void)crumble;

- (void)notifyCrumble;
- (void)notifyCrumbled;
- (void)notifyDropped;
- (void)notifyCollapsed;

@end
