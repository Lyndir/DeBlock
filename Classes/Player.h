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
    
    NSConditionLock                     *_passwordLock;
    UIAlertView                         *passwordAlert;
    UITextField                         *passwordField;
}

@property (readwrite, copy) NSString    *name;
@property (readwrite, copy) NSString    *pass;
@property (readwrite) NSInteger         score;
@property (readwrite) NSUInteger        level;

@end
