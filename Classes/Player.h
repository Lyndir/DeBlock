//
//  Player.h
//  Deblock
//
//  Created by Maarten Billemont on 06/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Player : NSObject <NSCoding> {

    NSString                            *_playerID;
    NSInteger                           _score;
    NSUInteger                          _level;
    DbMode                              _mode;
}

@property (readwrite, retain) NSString  *playerID;
@property (readwrite) NSInteger         score;
@property (readwrite) NSUInteger        level;
@property (readwrite) DbMode            mode;

+ (Player *)currentPlayer;

@end
