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
} DMBlockType;

@interface BlockLayer : Layer<CocosNodeRGBA> {

@private
    NSDictionary                                *blockColors;
    DMBlockType                                 type;
    BOOL                                        destroyed;
    
    NSInteger                                   targetRow, targetCol;
    NSUInteger                                  frames, frame;
    ccColor4F                                   modColor;
    
    IntervalAction                              *moveAction;
    Texture2D                                   **textures;
    Label                                       *label;
    
    ParticleSystem                              *dropEmitter;
}

@property (readwrite) DMBlockType               type;
@property (readwrite) BOOL                      destroyed;
@property (readonly) BOOL                       valid;
@property (readonly) BOOL                       moving;
@property (readwrite, retain) IntervalAction    *moveAction;

@property (readwrite) NSInteger                 targetRow;
@property (readwrite) NSInteger                 targetCol;

@property (readwrite) NSUInteger                frame;
@property (readonly) NSUInteger                 frames;
@property (readwrite) ccColor4F                 modColor;
@property (readonly) ccColor4B                  blockColor;

- (id)initWithBlockSize:(CGSize)size;

- (void)blink;
- (void)crumble;

- (void)notifyDropped;
- (void)notifyCollapsed;
- (void)notifyDestroyed;

@end
