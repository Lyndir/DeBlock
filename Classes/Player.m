//
//  Player.m
//  Deblock
//
//  Created by Maarten Billemont on 06/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Player.h"

#define lockPassNotSet  2<<0
#define lockPassSet     2<<1


@interface UIAlertView (TextField)

- (void)addTextFieldWithValue:(NSString *)value label:(NSString *)label;
- (UITextField *)textFieldAtIndex:(NSUInteger)index;

@end

@interface Player ()

- (void)registerObservers;
- (void)showPasswordDialog;

@property (readwrite, retain) NSConditionLock   *passwordLock;

@end

@implementation Player

@synthesize name = _name, pass = _pass, score = _score, level = _level;
@synthesize passwordLock = _passwordLock;

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
    
    if ([[NSThread currentThread] isMainThread]) {
        [[Logger get] err:@"This method should NOT be called from the MAIN thread!  Disallowing user to set his password."];
        return _pass;
    }
    
    if (!_pass) {
        
        [[Logger get] dbg:@"creating with: lockPassNotSet"];
        self.passwordLock = [[[NSConditionLock alloc] initWithCondition:lockPassNotSet] autorelease];
        
        NSThread *passwordThread = [[NSThread alloc] initWithTarget:self selector:@selector(showPasswordDialog) object:nil];
        [passwordThread start];
        [passwordThread autorelease];
        
        [[Logger get] dbg:@"locking until: lockPassSet"];
        [self.passwordLock lockWhenCondition:lockPassSet];
        [[Logger get] dbg:@"unlocking with: %@", _pass? @"lockPassSet": @"lockPassNotSet"];
        [self.passwordLock unlockWithCondition:_pass? lockPassSet: lockPassNotSet];
    }
    
    return _pass;
}

- (void)showPasswordDialog {
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    passwordAlert = [[UIAlertView alloc] initWithTitle:@"Online Code" message:
                     [NSString stringWithFormat:@"Code for %@:", self.name]
                                              delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [passwordAlert addTextFieldWithValue:@"" label:@""];
    
    passwordField                       = [passwordAlert textFieldAtIndex:0];
    passwordField.keyboardType          = UIKeyboardTypeNumberPad;
    passwordField.keyboardAppearance    = UIKeyboardAppearanceAlert;
    passwordField.autocorrectionType    = UITextAutocorrectionTypeNo;
    [passwordAlert show];
    
    [pool drain];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == [alertView cancelButtonIndex])
        return;
    
    if (alertView == passwordAlert) {
        [[Logger get] dbg:@"locking until: lockPassNotSet"];
        [self.passwordLock lockWhenCondition:lockPassNotSet];
        self.pass = passwordField.text;
        [[Logger get] dbg:@"unlocking with: %@", _pass? @"lockPassSet": @"lockPassNotSet"];
        [self.passwordLock unlockWithCondition:lockPassSet];

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
