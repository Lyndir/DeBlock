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
//  GraphLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 03/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//


@interface Score : NSObject {

@private
    NSInteger                                   score;
    NSString                                    *username;
    NSDate                                      *date;
}

@property (readonly) NSInteger                  score;
@property (readonly) NSString                   *username;
@property (readonly) NSDate                     *date;

+ (Score *)scoreWithScore:(NSInteger)aScore by:(NSString *)aUsername at:(NSDate *)aDate;

- (id)initWithScore:(NSInteger)aScore by:(NSString *)aUsername at:(NSDate *)aDate;
    
- (NSComparisonResult)compareByTopScore:(Score *)other;
- (NSComparisonResult)compareByRecency:(Score *)other;
- (NSComparisonResult)compareByUsername:(Score *)other;

@end


@interface GraphNode : Layer {

@private
    NSArray                                     *scores, *sortedScores;
    SEL                                         comparator;
    
    NSDateFormatter                             *dateFormatter;
    NSString                                    *scoreFormat;
    CGFloat                                     padding;
    
    CGPoint                                     dragFromPoint;
    CGFloat                                     verticalOffset;
    CGFloat                                     originalVerticalOffset;
    
    NSUInteger                                  scoreCount, verticeCount;
    
    ccTime                                      animationTimeLeft;
    GLuint                                      vertexBuffer;
}

/** An array of Score objects. */
@property (readwrite, retain) NSArray           *scores;
/** The formatter to use when rendering score dates. */
@property (readwrite, retain) NSDateFormatter   *dateFormatter;
/** The format string to render the score data with.
 *
 * The arguments to the format string are in this order: score, username, formatted date. */
@property (readwrite, retain) NSString          *scoreFormat;
/** The method on the Score object that will determine the order of rendered score appearance. */
@property (readwrite) SEL                       comparator;

/** The amount of pixels of padding to use between the graph border and the graph data. */
@property (readwrite) CGFloat                   padding;

/** @param newData  An array of Score objects. */
- (id)initWithArray:(NSArray *)newData;

@end
