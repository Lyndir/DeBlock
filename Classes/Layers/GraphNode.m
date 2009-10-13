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

- (void)updateWithSortedScores:(NSArray *)sortedScores;
- (void)updateVertices;

@end



@implementation GraphDataNode

@synthesize sortedScores;
@synthesize padding, barHeight;
@synthesize scoreFormat, dateFormatter;

- (id)init {

    if (!(self = [super init]))
        return nil;
    
    self.padding            = 0;
    self.barHeight          = [[Config get].largeFontSize unsignedIntValue];
    self.scoreFormat        = @"%04d - %@";
    self.dateFormatter      = [[NSDateFormatter new] autorelease];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    return self;
}

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

- (void)setScoreFormat:(NSString *)aScoreFormat {
    
    scoreFormat = aScoreFormat;
    [self updateVertices];
}

- (void)setDateFormatter:(NSDateFormatter *)aDateFormatter {
    
    dateFormatter = aDateFormatter;
    [self updateVertices];
}

- (void)updateWithSortedScores:(NSArray *)newSortedScores {

    // Clean up existing score labels.
    for (NSUInteger s = 0; s < scoreCount; ++s) {
        [self removeChild:scoreLabels[s] cleanup:YES];
        [scoreLabels[s] release];
    }
    free(scoreLabels);
    scoreLabels                 = nil;
    
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
    scoreLabels                 = malloc(sizeof(Label *) * scoreCount);
    for (Score *score in sortedScores) {
        scoreLabels[s]          = [[Label alloc] initWithString:[NSString stringWithFormat:scoreFormat,
                                                                 score.score, score.username, [dateFormatter stringFromDate:score.date]]
                                                       fontName:[Config get].fixedFontName fontSize:[[Config get].fontSize intValue]];
        scoreLabels[s].position = ccp(scoreLabels[s].contentSize.width / 2 + padding + 10,
                                      self.contentSize.height - scoreLabels[s].contentSize.height / 2 - barHeight * s);
        [self addChild:scoreLabels[s]];
        
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
        animationTimeLeft = 0;
    }
    
    [self updateVertices];
}

- (void)didUpdateScroll {
    
    [self updateVertices];
}

- (void)updateVertices {

    // Hide all score labels initially; we will reveal the ones that we create vertices for when we do.
    for (NSUInteger s = 0; s < scoreCount; ++s)
        scoreLabels[s].visible = NO;
    
    // Build vertex arrays.
    Vertex *vertices        = malloc(sizeof(Vertex)     /* size of a vertex */
                                     * 6               /* amount of vertices per score box */
                                     * scoreCount       /* amount of scores */);
    
    NSUInteger sv           = 0;
    CGRect visibleRect      = [self visibleRect];
    CGFloat sy              = visibleRect.size.height - padding;
    float scoreMultiplier   = (kAnimationDuration - animationTimeLeft) / (kAnimationDuration * topScore);
    for (NSUInteger s = 0; s < scoreCount; ++s) {
        if (sy - visibleRect.origin.y - barHeight > visibleRect.size.height - padding) {
            sy              -= barHeight;
            continue;
        }
        
        float scoreRatio    = ((Score *)[sortedScores objectAtIndex:s]).score * scoreMultiplier;
        
        vertices[sv + 0].c  = vertices[sv + 1].c    = vertices[sv + 5].c    = ccc4(0xee, 0xee, 0xff, 0xbb); // near (top)
        vertices[sv + 2].c  = vertices[sv + 3].c    = vertices[sv + 4].c    = ccc4(0xee, 0xee, 0xff, 0xee); // half
        //vertices[sv + 6].c  = vertices[sv + 7].c    = vertices[sv + 11].c   = ccc4(0xee, 0xee, 0xff, 0xee); // half
        //vertices[sv + 8].c  = vertices[sv + 9].c    = vertices[sv + 10].c   = ccc4(0xee, 0xee, 0xff, 0xcc); // far (bottom)
        
        CGFloat nearX       = padding;
        CGFloat nearY       = sy;
        CGFloat farX        = nearX + (self.contentSize.width - 2 * padding) * scoreRatio;
        CGFloat farY        = nearY - barHeight;
        //CGFloat halfX     = (nearX + farX) / 2;
        CGFloat halfY       = farY; //= nearY + (farY - nearY) * (1 - 0.618f);
        vertices[sv + 0].p  = ccp(nearX , nearY);
        vertices[sv + 1].p  = ccp(farX  , nearY);
        vertices[sv + 2].p  = ccp(nearX , halfY);
        vertices[sv + 3].p  = ccp(nearX , halfY);
        vertices[sv + 4].p  = ccp(farX  , halfY);
        vertices[sv + 5].p  = ccp(farX  , nearY);
        /*vertices[sv + 6].p  = ccp(nearX , halfY);
        vertices[sv + 7].p  = ccp(farX  , halfY);
        vertices[sv + 8].p  = ccp(nearX , farY);
        vertices[sv + 9].p  = ccp(nearX , farY);
        vertices[sv + 10].p = ccp(farX  , farY);
        vertices[sv + 11].p = ccp(farX  , halfY);*/
        
        sv                  += 6;
        sy                  -= barHeight;
        scoreLabels[s].visible = YES;
        if (sy - visibleRect.origin.y - barHeight <= padding - barHeight)
            break;
    }
    barCount                = sv / 6;
    
    // Push our window data into VBOs.
    glDeleteBuffers(1, &vertexBuffer);
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * barCount * 6, vertices, GL_DYNAMIC_DRAW);
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
    
    glLineWidth(2.0f);
    glDrawArrays(GL_LINES, 0, barCount * 6);
    glDrawArrays(GL_TRIANGLES, 0, barCount * 6);
    glLineWidth(1.0f);
    
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

@synthesize scores, comparator;
@synthesize graphDataNode;


- (id)initWithArray:(NSArray *)newScores {
    
    if (!(self = [super init]))
        return nil;
    
    CGSize winSize          = [Director sharedDirector].winSize;
    self.contentSize        = CGSizeMake(winSize.width * 0.9f, winSize.height * 0.7f);
    self.position           = ccp((winSize.width - self.contentSize.width) / 2,
                                  (winSize.height - self.contentSize.height) / 2);
    
    [self addChild:graphDataNode = [GraphDataNode new]];
    graphDataNode.contentSize = self.contentSize;

    self.comparator         = @selector(compareByTopScore:);
    self.scores             = newScores;

    return self;
}


- (void)setScores:(NSArray *)newScores {
    
    [scores release];
    scores                  = [newScores retain];
    
    [self updateSortedScores];
}

- (void)updateSortedScores {
    
    [sortedScores release];
    sortedScores        = [[scores sortedArrayUsingSelector:comparator] retain];
    
    [graphDataNode updateWithSortedScores:sortedScores];
}

- (void)draw {
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    DrawBoxFrom(CGPointZero, ccp(self.contentSize.width, self.contentSize.height),
                ccc4(0x00, 0x00, 0x00, 0x66), ccc4(0x00, 0x00, 0x00, 0xCC));
    DrawBorderFrom(CGPointZero, ccp(self.contentSize.width, self.contentSize.height),
                   ccc4(0xff, 0xff, 0xff, 0x66), 2);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}

@end
