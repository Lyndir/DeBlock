//
//  Player.m
//  Deblock
//
//  Created by Maarten Billemont on 06/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Player.h"


@interface UIAlertView (TextField)

- (void)addTextFieldWithValue:(NSString *)value label:(NSString *)label;
- (UITextField *)textFieldAtIndex:(NSUInteger)index;

@end

@interface Player ()

- (void)registerObservers;

@end

@implementation Player

@synthesize name = _name, pass = _pass, score = _score, level = _level;

- (id)init {
    
    [self = [super init] registerObservers];

    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    
    if(!(self = [super init]))
        return self;
    
    self.name               = [decoder decodeObjectForKey:@"Player_Name"];
    self.pass               = [decoder decodeObjectForKey:@"Player_Password"];
    self.score              = [decoder decodeIntegerForKey:@"Player_Score"];
    self.level              = [decoder decodeIntegerForKey:@"Player_Level"];
    
    [self registerObservers];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_name     forKey:@"Player_Name"];
    [encoder encodeObject:_pass     forKey:@"Player_Password"];
    [encoder encodeInteger:_score   forKey:@"Player_Score"];
    [encoder encodeInteger:_level   forKey:@"Player_Level"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self)
        [[DeblockConfig get] updatePlayer:self];
}

- (void)registerObservers {
    
    [self addObserver:self forKeyPath:@"name"   options:0 context:NULL];
    [self addObserver:self forKeyPath:@"pass"   options:0 context:NULL];
    [self addObserver:self forKeyPath:@"score"  options:0 context:NULL];
    [self addObserver:self forKeyPath:@"level"  options:0 context:NULL];
}

- (void)unregisterObservers {
    
    [self removeObserver:self forKeyPath:@"name"];
    [self removeObserver:self forKeyPath:@"pass"];
    [self removeObserver:self forKeyPath:@"score"];
    [self removeObserver:self forKeyPath:@"level"];
}

- (NSString *)pass {
    
    if (!_pass) {
        passwordAlert = [[UIAlertView alloc] initWithTitle:@"Submitting Score" message:
                         [NSString stringWithFormat:@"Enter %@'s online code:", self.name]
                                                  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        [passwordAlert addTextFieldWithValue:@"" label:@"Passcode"];
        [passwordAlert show];

        passwordField = [passwordAlert textFieldAtIndex:0];
        passwordField.keyboardType = UIKeyboardTypeNumberPad;
        passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
        passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
        
    }
    
    return _pass;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == [alertView cancelButtonIndex])
        return;
    
    if (alertView == passwordAlert) {
        self.pass = passwordField.text;
        [passwordAlert release];
        passwordAlert = nil;
        passwordField = nil;
    }
}


- (void)dealloc {
    
    [self unregisterObservers];
    
    self.name = nil;
    self.pass = nil;
    
    [super dealloc];
}

@end
