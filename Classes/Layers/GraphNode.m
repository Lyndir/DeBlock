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
//  GraphLayer.m
//  Deblock
//
//  Created by Maarten Billemont on 03/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "GraphNode.h"

#define kAnimationDuration  2.0f


@implementation Score

@synthesize score, username, date;

+ (Score *)scoreWithScore:(NSInteger)aScore by:(NSString *)aUsername at:(NSDate *)aDate {

    return [[[self alloc] initWithScore:aScore by:aUsername at:aDate] autorelease];
}

- (id)initWithScore:(NSInteger)aScore by:(NSString *)aUsername at:(NSDate *)aDate {

    if (!(self = [super init]))
        return nil;
    
    score       = aScore;
    username    = aUsername;
    date        = aDate;
    
    return self;
}

- (NSComparisonResult)compareByTopScore:(Score *)other {
    
    if (self.score == other.score)
        return NSOrderedSame;
    
    return self.score < other.score? NSOrderedDescending: NSOrderedAscending;
}

- (NSComparisonResult)compareByRecency:(Score *)other {

    return [self.date compare:other.date];
}

- (NSComparisonResult)compareByUsername:(Score *)other {
    
    return [self.username compare:other.username];
}

@end

@interface GraphNode ()

- (void)updateSortedScores;
- (void)updateVertices;

@end


@implementation GraphNode

@synthesize scores, dateFormatter, scoreFormat, comparator, padding;


- (id)initWithArray:(NSArray *)newScores {
    
    if (!(self = [super init]))
        return nil;
    
    CGSize winSize      = [Director sharedDirector].winSize;
    self.contentSize    = CGSizeMake(winSize.width * 0.9f, winSize.height * 0.7f);
    self.position       = ccp((winSize.width - self.contentSize.width) / 2,
                              (winSize.height - self.contentSize.height) / 2);
    
    self.padding        = 10;
    self.comparator     = @selector(compareByTopScore:);
    self.scoreFormat    = @"%04d | %s";
    self.dateFormatter  = [NSDateFormatter new];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	self.scores         = newScores;
    
    self.isTouchEnabled = YES;

	return self;
}


-(void) registerWithTouchDispatcher {
    
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    originalVerticalOffset  = verticalOffset;
    dragFromPoint           = [self convertTouchToNodeSpace:touch];

    CGRect graphRect;
    graphRect.origin        = CGPointZero;
    graphRect.size          = self.contentSize;
    
    return CGRectContainsPoint(graphRect, dragFromPoint);
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {

    CGPoint dragToPoint     = [self convertTouchToNodeSpace:touch];
    verticalOffset          = originalVerticalOffset + (dragToPoint.y - dragFromPoint.y);
    
    [self updateVertices];
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    originalVerticalOffset  = verticalOffset;
}


- (void)setScores:(NSArray *)newScores {
    
    [scores release];
    scores              = [newScores retain];
    
    [self updateSortedScores];
}


- (void)setComparator:(SEL)newComparator {
    
    comparator          = newComparator;

    [self updateSortedScores];
}

- (void)updateSortedScores {
    
    [sortedScores release];
    sortedScores        = [[scores sortedArrayUsingSelector:comparator] retain];
    
    animationTimeLeft   = kAnimationDuration;
    [self schedule:@selector(animate:)];
}

- (void)animate:(ccTime)dt {
    
    // Manage animation lifecycle.
    animationTimeLeft -= dt;
    if (animationTimeLeft <= 0) {
        [self unschedule:_cmd];
        dt += animationTimeLeft;
        if (!dt)
            return;
    }
    
    [self updateVertices];
}

- (void)updateVertices {
    
    // Find the top score.
    NSInteger topScore      = ((Score *)[sortedScores lastObject]).score;
    for (Score *score in sortedScores)
        if (score.score > topScore)
            topScore = score.score;

    
    // Build vertex arrays.
    scoreCount              = [sortedScores count];
    Vertex *vertices        = malloc(sizeof(Vertex)     /* size of a vertex */
                                     * 6                /* amount of vertices per score box */
                                     * scoreCount       /* amount of scores */);
    
    NSUInteger sv           = 0;
    CGFloat sy              = self.contentSize.height - padding + verticalOffset;
    CGFloat height          = (CGFloat)[[Config get].largeFontSize unsignedIntValue];
    float scoreMultiplier   = (kAnimationDuration - animationTimeLeft) / (kAnimationDuration * topScore);
    for (NSUInteger s = 0; s < scoreCount; ++s) {
        if (sy - height > self.contentSize.height - padding) {
            sy              -= height;
            continue;
        }
        
        float scoreRatio    = ((Score *)[sortedScores objectAtIndex:s]).score * scoreMultiplier;
        
        vertices[sv + 0].c  = vertices[sv + 1].c    = vertices[sv + 5].c    = ccc4(0xcc, 0xff, 0xcc, 0x66);
        vertices[sv + 2].c  = vertices[sv + 3].c    = vertices[sv + 4].c    = ccc4(0xcc, 0xff, 0xcc, 0xff);
        
        CGFloat nearX       = padding;
        CGFloat nearY       = sy;
        CGFloat farX        = padding + (self.contentSize.width - 2 * padding) * scoreRatio;
        CGFloat farY        = sy - height;
        vertices[sv + 0].p  = ccp(nearX , nearY);
        vertices[sv + 1].p  = ccp(farX  , nearY);
        vertices[sv + 2].p  = ccp(nearX , farY);
        vertices[sv + 3].p  = ccp(nearX , farY);
        vertices[sv + 4].p  = ccp(farX  , farY);
        vertices[sv + 5].p  = ccp(farX  , nearY);
        
        sv                  += 6;
        sy                  -= height;
        if (sy - height <= padding - height)
            break;
    }
    verticeCount            = sv / 6;

    // Push our window data into VBOs.
    glDeleteBuffers(1, &vertexBuffer);
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * verticeCount * 6, vertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Free the client side data.
    free(vertices);
}

-(void) draw {
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    DrawBoxFrom(CGPointZero, ccp(self.contentSize.width + 1, self.contentSize.height + 1),
                ccc4(0x00, 0x00, 0x00, 0x00), ccc4(0x00, 0x00, 0x00, 0x66));
    DrawBorderFrom(CGPointZero, ccp(self.contentSize.width + 1, self.contentSize.height + 1),
                ccc4(0xff, 0xff, 0xff, 0x33), 1);

    glEnable(GL_SCISSOR_TEST);
    Scissor(self, ccp(padding, padding), ccp(self.contentSize.width - padding, self.contentSize.height - padding));

    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(Vertex), 0);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, c));
    
    glDrawArrays(GL_TRIANGLES, 0, verticeCount * 6);
    
    glDisable(GL_SCISSOR_TEST);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
}

-(void) dealloc {
    
    glDeleteBuffers(1, &vertexBuffer);
    vertexBuffer = 0;
    
    [super dealloc];
}

@end
