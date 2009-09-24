//
//  ScrollLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 23/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ScrollLayer.h"

#define kDefaultScrollPerSecond     0.1f


@interface ScrollLayer ()

- (CGPoint)limitPoint:(CGPoint)point;

@end


@implementation ScrollLayer

@synthesize scrollPerSecond, scrollRatio, scrollableContentSize;
@synthesize origin, scroll;


- (id)init {

    if (!(self = [super init]))
        return nil;
    
    self.isTouchEnabled     = YES;
    scrollRatio             = ccp(0.0f, 1.0f);
    scrollPerSecond         = kDefaultScrollPerSecond;
    
    [self schedule:@selector(tick:)];

	return self;
}


-(void) registerWithTouchDispatcher {
    
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // Test if touch was on us.
    CGRect graphRect;
    graphRect.origin        = CGPointZero;
    graphRect.size          = self.contentSize;
    if (!CGRectContainsPoint(graphRect, [self.parent convertTouchToNodeSpace:touch]))
        return NO;
    
    // Instantly apply remaining scroll & reset it.
    origin                  = [self limitPoint:ccpAdd(origin, scroll)];
    scroll                  = CGPointZero;

    // Remember where the dragging began.
    dragFromPosition        = self.position;
    dragFromPoint           = [self.parent convertTouchToNodeSpace:touch];
    
    return YES;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint dragToPoint     = [self.parent convertTouchToNodeSpace:touch];
    scroll                  = ccp((dragToPoint.x - dragFromPoint.x) * scrollRatio.x,
                                  (dragToPoint.y - dragFromPoint.y) * scrollRatio.y);
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    scroll              = ccpSub([self limitPoint:ccpAdd(origin, scroll)], origin);
}


- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {

    [self ccTouchEnded:touch withEvent:event];
}


- (CGPoint)limitPoint:(CGPoint)point {

    CGPoint maxScroll       = ccp(fmaxf(scrollableContentSize.width  - self.contentSize.width,  0),
                                  fmaxf(scrollableContentSize.height - self.contentSize.height, 0));
    CGPoint minScroll       = CGPointZero;
    
    CGPoint limitPoint      = ccp(fminf(fmaxf(point.x, minScroll.x), maxScroll.x),
                                  fminf(fmaxf(point.y, minScroll.y), maxScroll.y));
    
    return limitPoint;
}


- (void)tick:(ccTime)dt {
    
    CGPoint scrollTarget    = ccpAdd(origin, scroll);
    CGPoint scrollLeft      = ccpSub(scrollTarget, self.position);
    CGFloat scrollLeftLen   = ccpLength(scrollLeft);

    if (scrollLeftLen == 0)
        return;
    
    if (scrollLeftLen <= 1) {
        // We're really close, short cut.
        self.position       = scrollTarget;
        return;
    }
    
    CGPoint scrollStep      = ccpMult(scrollLeft, (scrollLeftLen + 20) * scrollPerSecond * dt);
    self.position           = ccpAdd(self.position, scrollStep);
}


- (void)visit {

    if (!visible)
        return;
    
    glEnable(GL_SCISSOR_TEST);
    Scissor(self.parent, CGPointZero, CGPointFromSize(self.contentSize));
    
    [super visit];

    glDisable(GL_SCISSOR_TEST);
}


@end
