//
//  Player.h
//  Deblock
//
//  Created by Maarten Billemont on 06/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Player : NSObject <NSCoding> {

    NSString                            *_name;
    NSInteger                           _score;
    NSUInteger                          _level;
}

@property (readwrite, copy) NSString    *name;
@property (readwrite) NSInteger         score;
@property (readwrite) NSUInteger        level;

@end
