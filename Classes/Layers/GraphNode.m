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

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@: %@: %d", self.username, self.date, self.score];
}

@end


@interface GraphDataNode ()

@property (readwrite, retain) NSArray           *sortedScores;
@property (readwrite) CGFloat                   padding;
@property (readwrite) CGFloat                   barHeight;

- (void)updateWithSortedScores:(NSArray *)sortedScores;
- (void)updateVertices;

@end



@implementation GraphDataNode

@synthesize padding, barHeight, sortedScores;

- (void)setBarHeight:(CGFloat)aBarHeight {
    
    barHeight = aBarHeight;
    self.scrollableContentSize  = CGSizeMake(self.contentSize.width, padding * 2 + scoreCount * barHeight);
    [self updateVertices];
}

- (void)setPadding:(CGFloat)aPadding {
    
    padding = aPadding;
    self.scrollableContentSize  = CGSizeMake(self.contentSize.width, padding * 2 + scoreCount * barHeight);
    [self updateVertices];
}

- (void)updateWithSortedScores:(NSArray *)newSortedScores {

    self.sortedScores           = newSortedScores;
    scoreCount                  = [sortedScores count];
    self.scrollableContentSize  = CGSizeMake(self.contentSize.width, scoreCount * barHeight);

    // Find the top score.
    topScore                    = ((Score *)[sortedScores lastObject]).score;
    for (Score *score in sortedScores)
        if (score.score > topScore)
            topScore            = score.score;

    // Make score labels.
    NSUInteger s = 0;
    for (Score *score in sortedScores) {
        Label *scoreLabel       = [[Label alloc] initWithString:score.username
                                                 fontName:[Config get].fontName fontSize:[[Config get].fontSize intValue]];
        scoreLabel.position     = ccp(scoreLabel.contentSize.width / 2 + padding + 10,
                                      self.contentSize.height - scoreLabel.contentSize.height / 2 - barHeight * s);
        [self addChild:scoreLabel];
        [scoreLabel release];
        
        ++s;
    }
    
    // (Re)start the score bars animation.
    animationTimeLeft           = kAnimationDuration;
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
    
    // Build vertex arrays.
    Vertex *vertices        = malloc(sizeof(Vertex)     /* size of a vertex */
                                     * 12               /* amount of vertices per score box */
                                     * scoreCount       /* amount of scores */);
    
    NSUInteger sv           = 0;
    CGFloat sy              = self.contentSize.height - padding;
    float scoreMultiplier   = (kAnimationDuration - animationTimeLeft) / (kAnimationDuration * topScore);
    for (NSUInteger s = 0; s < scoreCount; ++s) {
        if (sy - barHeight > self.contentSize.height - padding) {
            sy              -= barHeight;
            continue;
        }
        
        float scoreRatio    = ((Score *)[sortedScores objectAtIndex:s]).score * scoreMultiplier;
        
        vertices[sv + 0].c  = vertices[sv + 1].c    = vertices[sv + 5].c    = ccc4(0xbb, 0xcc, 0xff, 0xaa); // near (top)
        vertices[sv + 2].c  = vertices[sv + 3].c    = vertices[sv + 4].c    = ccc4(0xdd, 0xdd, 0xff, 0xdd); // half
        vertices[sv + 6].c  = vertices[sv + 7].c    = vertices[sv + 11].c   = ccc4(0xdd, 0xdd, 0xff, 0xee); // half
        vertices[sv + 8].c  = vertices[sv + 9].c    = vertices[sv + 10].c   = ccc4(0xff, 0xff, 0xff, 0xff); // far (bottom)
        
        CGFloat nearX       = padding;
        CGFloat nearY       = sy;
        CGFloat farX        = padding + (self.contentSize.width - 2 * padding) * scoreRatio;
        CGFloat farY        = sy - barHeight;
        //CGFloat halfX     = (nearX + farX) / 2;
        CGFloat halfY       = nearY + (farY - nearY) * 0.618f;
        vertices[sv + 0].p  = ccp(nearX , nearY);
        vertices[sv + 1].p  = ccp(farX  , nearY);
        vertices[sv + 2].p  = ccp(nearX , halfY);
        vertices[sv + 3].p  = ccp(nearX , halfY);
        vertices[sv + 4].p  = ccp(farX  , halfY);
        vertices[sv + 5].p  = ccp(farX  , nearY);
        vertices[sv + 6].p  = ccp(nearX , halfY);
        vertices[sv + 7].p  = ccp(farX  , halfY);
        vertices[sv + 8].p  = ccp(nearX , farY);
        vertices[sv + 9].p  = ccp(nearX , farY);
        vertices[sv + 10].p = ccp(farX  , farY);
        vertices[sv + 11].p = ccp(farX  , halfY);
        
        sv                  += 12;
        sy                  -= barHeight;
        if (sy - barHeight <= padding - barHeight)
            break;
    }
    verticeCount            = sv / 12;
    
    // Push our window data into VBOs.
    glDeleteBuffers(1, &vertexBuffer);
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * verticeCount * 12, vertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Free the client side data.
    free(vertices);
}

- (void)draw {
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(Vertex), 0);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, c));
    
    glDrawArrays(GL_TRIANGLES, 0, verticeCount * 12);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
}


- (void)dealloc {
    
    glDeleteBuffers(1, &vertexBuffer);
    vertexBuffer = 0;
    
    [super dealloc];
}


@end


@interface GraphNode ()

- (void)updateSortedScores;

@end


@implementation GraphNode

@synthesize scores, dateFormatter, scoreFormat, comparator;


- (id)initWithArray:(NSArray *)newScores {
    
    if (!(self = [super init]))
        return nil;
    
    CGSize winSize          = [Director sharedDirector].winSize;
    self.contentSize        = CGSizeMake(winSize.width * 0.9f, winSize.height * 0.7f);
    self.position           = ccp((winSize.width - self.contentSize.width) / 2,
                                  (winSize.height - self.contentSize.height) / 2);
    
    [self addChild:graphDataNode = [GraphDataNode new]];
    graphDataNode.contentSize = self.contentSize;
    
    self.padding            = 0;
    self.barHeight          = [[Config get].largeFontSize unsignedIntValue];
    self.comparator         = @selector(compareByTopScore:);
    self.scoreFormat        = @"%04d | %s";
    self.dateFormatter      = [NSDateFormatter new];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	self.scores             = newScores;

	return self;
}


- (void)setScores:(NSArray *)newScores {
    
    [scores release];
    scores                  = [newScores retain];
    
    [self updateSortedScores];
}


- (void)setComparator:(SEL)newComparator {
    
    comparator              = newComparator;

    [self updateSortedScores];
}

- (void)updateSortedScores {
    
    [sortedScores release];
    sortedScores        = [[scores sortedArrayUsingSelector:comparator] retain];
    
    [graphDataNode updateWithSortedScores:sortedScores];
}

- (CGFloat)padding {
    
    return graphDataNode.padding;
}

- (void)setPadding:(CGFloat)aPadding {
    
    graphDataNode.padding   = aPadding;
}

- (CGFloat)barHeight {
    
    return graphDataNode.barHeight;
}

- (void)setBarHeight:(CGFloat)aBarHeight {
    
    graphDataNode.barHeight = aBarHeight;
}

- (void)draw {
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    DrawBoxFrom(CGPointZero, ccp(self.contentSize.width, self.contentSize.height),
                ccc4(0x00, 0x00, 0x00, 0x66), ccc4(0x00, 0x00, 0x00, 0x99));
    DrawBorderFrom(CGPointZero, ccp(self.contentSize.width, self.contentSize.height),
                   ccc4(0xff, 0xff, 0xff, 0x66), 1);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}

@end
