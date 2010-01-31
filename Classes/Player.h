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
    NSString                            *_pass;
    NSInteger                           _score;
    NSUInteger                          _level;

    BOOL                                _onlineOk;

    NSConditionLock                     *_nameLock;
    UIAlertView                         *_nameAlert;
    UITextField                         *_nameField;

    UIAlertView                         *_alertCode;
    NSConditionLock                     *_passLock;
    UIAlertView                         *_passAlert;
    UITextField                         *_passField;
}

@property (readwrite, copy) NSString    *name;
@property (readonly, retain) NSString           *onlineName;
@property (readwrite, copy) NSString    *pass;
@property (readwrite) NSInteger         score;
@property (readwrite) NSUInteger        level;
@property (readwrite) BOOL              onlineOk;

@end
