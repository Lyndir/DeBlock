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

@interface Score ()

@property (readwrite, copy) NSString                    *username;
@property (readwrite) DbMode                            mode;
@property (readwrite) NSUInteger                        level;
@property (readwrite) NSInteger                         score;
@property (readwrite) NSInteger                         ratio;
@property (readwrite, copy) NSDate                      *date;

@end


@implementation Score

@synthesize username = _username, mode = _mode, level = _level, score = _score, ratio = _ratio, date = _date;

+ (Score *)scoreBy:(NSString *)aUsername
          withMode:(DbMode)aMode
           atLevel:(NSUInteger)aLevel
         withScore:(NSInteger)aScore
            atDate:(NSDate *)aDate {

    return [[[self alloc] initWithScoreBy:aUsername withMode:aMode atLevel:aLevel withScore:aScore atDate:aDate] autorelease];
}

- (id)initWithScoreBy:(NSString *)aUsername
             withMode:(DbMode)aMode
              atLevel:(NSUInteger)aLevel
            withScore:(NSInteger)aScore
               atDate:(NSDate *)aDate; {

    if (!(self = [super init]))
        return nil;
    
    self.username   = aUsername;
    self.mode       = aMode;
    self.level      = aLevel;
    self.score      = aScore;
    self.date       = aDate;
    
    if (self.level)
        self.ratio  = self.score / self.level;
    
    return self;
}

- (NSComparisonResult)compareByTopRatio:(Score *)other {
    
    if (self.ratio == other.ratio)
        return NSOrderedSame;
    
    return self.ratio < other.ratio? NSOrderedDescending: NSOrderedAscending;
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
    
    return [NSString stringWithFormat:@"%@: %@ had %d at level %d (÷%d) in mode %d",
            self.date, self.username, self.score, self.level, self.ratio, self.mode];
}

- (void)dealloc {
    
    self.username = nil;
    self.date = nil;

    [super dealloc];
}

@end


@interface GraphDataNode ()


- (void)updateWithSortedScores:(NSArray *)sortedScores;
- (void)updateVertices;
- (void)animate:(ccTime)dt;

@end


@interface GraphDataNode ()

@property (readwrite, retain) NSArray       *sortedScores;
@property (readwrite, assign) NSInteger     topScore;
@property (readwrite, assign) NSInteger     topRatio;

@property (readwrite, assign) NSUInteger    scoreCount;
@property (readwrite, assign) NSUInteger    barCount;

@property (readwrite, assign) ccTime        animationTimeLeft;
@property (readwrite, assign) GLuint        vertexBuffer;
@property (readwrite, assign) Label         **scoreLabels;
@property (readwrite, assign) Label         **detailLabels;

@end


@implementation GraphDataNode

@synthesize sortedScores = _sortedScores, topScore = _topScore, topRatio = _topRatio;
@synthesize detailFormat = _detailFormat, scoreFormat = _scoreFormat, dateFormatter = _dateFormatter;
@synthesize padding = _padding, barHeight = _barHeight;
@synthesize scoreCount = _scoreCount, barCount = _barCount;
@synthesize animationTimeLeft = _animationTimeLeft, vertexBuffer = _vertexBuffer, scoreLabels = _scoreLabels, detailLabels = _detailLabels;

- (id)init {

    if (!(self = [super initWithContentSize:CGSizeZero direction:ScrollContentDirectionTopToBottom]))
        return nil;
    
    self.padding            = 0;
    self.barHeight          = [[Config get].largeFontSize unsignedIntValue];
    
    // 1-username, 2-ratio
    self.scoreFormat        = @"÷%5$03d - %1$@";
    // 1-score, 2-level, 3-mode, 4-date
    self.detailFormat       = @"score %1$05d\nlevel %2$d";
    
    self.dateFormatter      = [[NSDateFormatter new] autorelease];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    return self;
}

- (void)setBarHeight:(CGFloat)aBarHeight {
    
    _barHeight = aBarHeight;
    
    self.scrollContentSize  = CGSizeMake(self.contentSize.width, self.padding * 2 + self.scoreCount * self.barHeight);
    self.scrollStep         = ccp(0, self.barHeight);
    [self updateVertices];
}

- (void)setPadding:(CGFloat)aPadding {
    
    _padding = aPadding;
    
    self.scrollContentSize  = CGSizeMake(self.contentSize.width, self.padding * 2 + self.scoreCount * self.barHeight);
    [self updateVertices];
}

- (void)setDetailFormat:(NSString *)aDetailFormat {
    
    [_detailFormat release];
    _detailFormat = [aDetailFormat copy];
    
    [self updateVertices];
}

- (void)setScoreFormat:(NSString *)aScoreFormat {
    
    [_scoreFormat release];
    _scoreFormat = [aScoreFormat copy];
    
    [self updateVertices];
}

- (void)setDateFormatter:(NSDateFormatter *)aDateFormatter {
    
    [_dateFormatter release];
    _dateFormatter = [aDateFormatter retain];
    
    [self updateVertices];
}

- (void)updateWithSortedScores:(NSArray *)newSortedScores {

    // Clean up existing score labels.
    for (NSUInteger s = 0; s < self.scoreCount; ++s) {
        [self removeChild:self.scoreLabels[s] cleanup:YES];
        [self.scoreLabels[s] release];
        [self removeChild:self.detailLabels[s] cleanup:YES];
        [self.detailLabels[s] release];
    }
    free(self.scoreLabels);
    self.scoreLabels                 = nil;
    free(self.detailLabels);
    self.detailLabels                 = nil;
    
    self.sortedScores           = newSortedScores;
    self.scoreCount                  = [self.sortedScores count];
    self.scrollContentSize      = CGSizeMake(self.contentSize.width, self.scoreCount * self.barHeight);

    // Find the top score.
    self.topScore               = ((Score *)[self.sortedScores lastObject]).score;
    self.topRatio               = ((Score *)[self.sortedScores lastObject]).ratio;
    for (Score *score in self.sortedScores) {
        if (score.score > self.topScore)
            self.topScore       = score.score;
        if (score.ratio > self.topRatio)
            self.topRatio       = score.ratio;
    }
    

    // Make score labels.
    NSUInteger s = 0;
    self.scoreLabels                    = malloc(sizeof(Label *) * self.scoreCount);
    self.detailLabels                   = malloc(sizeof(Label *) * self.scoreCount);
    for (Score *score in self.sortedScores) {
        self.scoreLabels[s]             = [[Label alloc] initWithString:[NSString stringWithFormat:self.scoreFormat,
                                                                         score.username, score.ratio]
                                                               fontName:[Config get].fixedFontName fontSize:[[Config get].fontSize intValue]];
        self.scoreLabels[s].position    = ccp(self.scoreLabels[s].contentSize.width / 2 + self.padding + 90,
                                              self.contentSize.height - self.scoreLabels[s].contentSize.height / 2 - self.barHeight * s);
        [self addChild:self.scoreLabels[s]];

        self.detailLabels[s]            = [[Label alloc] initWithString:[NSString stringWithFormat:self.detailFormat,
                                                                         score.score, score.level, score.mode, score.date]
                                                             dimensions:CGSizeMake(100, self.barHeight) alignment:UITextAlignmentLeft
                                                               fontName:[Config get].fixedFontName fontSize:[[Config get].smallFontSize intValue]];
        self.detailLabels[s].position   = ccp(self.detailLabels[s].contentSize.width / 2 + self.padding + 10,
                                              self.contentSize.height - self.detailLabels[s].contentSize.height / 2 - 8 - self.barHeight * s);
        [self addChild:self.detailLabels[s]];
        
        ++s;
    }
    
    // (Re)start the score bars animation.
    self.animationTimeLeft           = kAnimationDuration;
    [self schedule:@selector(animate:)];
}

- (void)animate:(ccTime)dt {
    
    // Manage animation lifecycle.
    self.animationTimeLeft -= dt;
    if (self.animationTimeLeft <= 0) {
        [self unschedule:_cmd];
        self.animationTimeLeft = 0;
    }
    
    [self updateVertices];
}

- (void)didUpdateScroll {
    
    [self updateVertices];
}

- (void)updateVertices {

    // Hide all score labels initially; we will reveal the ones that we create vertices for when we do.
    for (NSUInteger s = 0; s < self.scoreCount; ++s) {
        self.scoreLabels[s].visible = NO;
        self.detailLabels[s].visible = NO;
    }
    
    // Build vertex arrays.
    Vertex *vertices        = malloc(sizeof(Vertex)     /* size of a vertex */
                                     * 6               /* amount of vertices per score box */
                                     * self.scoreCount       /* amount of scores */);
    
    NSUInteger sv           = 0;
    CGRect visibleRect      = [self visibleRect];
    CGFloat sy              = visibleRect.size.height - self.padding;
    float ratioMultiplier   = (kAnimationDuration - self.animationTimeLeft) / (kAnimationDuration * self.topRatio);
    for (NSUInteger s = 0; s < self.scoreCount; ++s) {
        if (sy - visibleRect.origin.y - self.barHeight > visibleRect.size.height - self.padding) {
            sy              -= self.barHeight;
            continue;
        }
        
        float ratioRatio    = ((Score *)[self.sortedScores objectAtIndex:s]).ratio * ratioMultiplier;
        
        vertices[sv + 0].c  = vertices[sv + 1].c    = vertices[sv + 5].c    = ccc4(0xee, 0xee, 0xff, 0xbb); // near (top)
        vertices[sv + 2].c  = vertices[sv + 3].c    = vertices[sv + 4].c    = ccc4(0xee, 0xee, 0xff, 0xee); // half
        //vertices[sv + 6].c  = vertices[sv + 7].c    = vertices[sv + 11].c   = ccc4(0xee, 0xee, 0xff, 0xee); // half
        //vertices[sv + 8].c  = vertices[sv + 9].c    = vertices[sv + 10].c   = ccc4(0xee, 0xee, 0xff, 0xcc); // far (bottom)
        
        CGFloat nearX       = self.padding;
        CGFloat nearY       = sy;
        CGFloat farX        = nearX + (self.contentSize.width - 2 * self.padding) * ratioRatio;
        CGFloat farY        = nearY - self.barHeight;
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
        sy                  -= self.barHeight;
        self.scoreLabels[s].visible = YES;
        self.detailLabels[s].visible = YES;
        if (sy - visibleRect.origin.y - self.barHeight <= self.padding - self.barHeight)
            break;
    }
    self.barCount                = sv / 6;
    
    // Push our window data into VBOs.
    glDeleteBuffers(1, &_vertexBuffer);
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * self.barCount * 6, vertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Free the client side data.
    free(vertices);
}

- (void)draw {
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glVertexPointer(2, GL_FLOAT, sizeof(Vertex), 0);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, c));
    
    glLineWidth(2.0f);
    glDrawArrays(GL_LINES, 0, self.barCount * 6);
    glDrawArrays(GL_TRIANGLES, 0, self.barCount * 6);
    glLineWidth(1.0f);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
}


- (void)dealloc {
    
    glDeleteBuffers(1, &_vertexBuffer);
    _vertexBuffer = 0;
    
    for (NSUInteger s = 0; s < self.scoreCount; ++s) {
        [self removeChild:self.scoreLabels[s] cleanup:YES];
        [self.scoreLabels[s] release];
        [self removeChild:self.detailLabels[s] cleanup:YES];
        [self.detailLabels[s] release];
    }
    free(self.scoreLabels);
    self.scoreLabels                 = nil;
    free(self.detailLabels);
    self.detailLabels                 = nil;
    
    self.sortedScores = nil;
    self.scoreFormat = nil;
    self.dateFormatter = nil;
    
    [super dealloc];
}


@end


@interface GraphNode ()

@property (readwrite, retain) NSArray                                     *sortedScores;

@property (readwrite, retain) GraphDataNode                               *graphDataNode;

@end


@implementation GraphNode

@synthesize sortedScores = _sortedScores;
@synthesize comparator = _comparator;
@synthesize graphDataNode = _graphDataNode;



- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    [self addChild:self.graphDataNode = [GraphDataNode node]];

    self.comparator         = @selector(compareByTopRatio:);

    CGSize winSize          = [Director sharedDirector].winSize;
    self.contentSize        = CGSizeMake((int)(winSize.width * 0.9f), (int)(winSize.height * 0.7f));
    self.position           = ccp(((int)(winSize.width - self.contentSize.width) / 2),
                                  ((int)(winSize.height - self.contentSize.height) / 2));
    
    return self;
}


- (void)setScores:(NSArray *)newScores {
    
    [_sortedScores release];
    _sortedScores        = [[newScores sortedArrayUsingSelector:self.comparator] retain];
    
    [self.graphDataNode updateWithSortedScores:self.sortedScores];
}


- (void)setContentSize:(CGSize)newContentSize {
    
    super.contentSize = newContentSize;
    self.graphDataNode.contentSize = self.contentSize;
}


- (void)draw {
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    DrawBoxFrom(CGPointZero, CGPointFromSize(self.contentSize),
                ccc4(0x00, 0x00, 0x00, 0x66), ccc4(0x00, 0x00, 0x00, 0xCC));
    DrawBorderFrom(CGPointZero, CGPointFromSize(self.contentSize),
                   ccc4(0xff, 0xff, 0xff, 0x66), 2);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}

- (void)dealloc {

    self.sortedScores = nil;
    self.graphDataNode = nil;

    [super dealloc];
}

@end
