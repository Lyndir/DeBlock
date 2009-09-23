//
//  ScrollLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 23/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//


@interface ScrollLayer : Layer {
    
    @private
    CGPoint                                     dragFromPoint;
    CGPoint                                     dragFromPosition;

    CGFloat                                     scrollPerSecond;
    CGPoint                                     scrollRatio;

    CGPoint                                     origin;
    CGPoint                                     scroll;
}

@property (readwrite) CGFloat                   scrollPerSecond;
@property (readwrite) CGPoint                   scrollRatio;

@property (readwrite) CGPoint                   origin;
@property (readwrite) CGPoint                   scroll;

@end
