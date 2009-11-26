//
//  Player.m
//  Deblock
//
//  Created by Maarten Billemont on 06/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Player.h"

#define lNotSet 2<<0
#define lSet    2<<1


@interface UIAlertView (TextField)

- (void)addTextFieldWithValue:(NSString *)value label:(NSString *)label;
- (UITextField *)textFieldAtIndex:(NSUInteger)index;

@end

@interface Player ()

- (void)registerObservers;

- (void)showNameDialog;
- (void)showPassDialog;

@property (readwrite, retain) NSConditionLock   *nameLock;
@property (readwrite, retain) NSConditionLock   *passLock;

@end

@implementation Player

@synthesize name = _name, pass = _pass, score = _score, level = _level, onlineOk = _onlineOk;
@synthesize nameLock = _nameLock, passLock = _passLock;

- (id)init {
    
    [self = [super init] registerObservers];

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if(!(self = [super init]))
        return self;
    
    _name                   = [[decoder decodeObjectForKey: @"Player_Name"] retain];
    _pass                   = [[decoder decodeObjectForKey: @"Player_Password"] retain];
    _score                  = [decoder decodeIntegerForKey: @"Player_Score"];
    _level                  = [decoder decodeIntegerForKey: @"Player_Level"];
    _onlineOk               = [decoder decodeBoolForKey:    @"Player_OnlineOK"];
    
    [self registerObservers];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_name                     forKey: @"Player_Name"];
    [encoder encodeObject:_pass                     forKey: @"Player_Password"];
    [encoder encodeInteger:_score                   forKey: @"Player_Score"];
    [encoder encodeInteger:_level                   forKey: @"Player_Level"];
    [encoder encodeBool:_onlineOk                   forKey: @"Player_OnlineOK"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self)
        [[DeblockConfig get] updatePlayer:self];
}

- (void)registerObservers {

    [self addObserver:self forKeyPath:@"name"       options:0 context:NULL];
    [self addObserver:self forKeyPath:@"pass"       options:0 context:NULL];
    [self addObserver:self forKeyPath:@"score"      options:0 context:NULL];
    [self addObserver:self forKeyPath:@"level"      options:0 context:NULL];
    [self addObserver:self forKeyPath:@"onlineOk"   options:0 context:NULL];
}

- (void)unregisterObservers {

    [self removeObserver:self forKeyPath:@"name"];
    [self removeObserver:self forKeyPath:@"pass"];
    [self removeObserver:self forKeyPath:@"score"];
    [self removeObserver:self forKeyPath:@"level"];
    [self removeObserver:self forKeyPath:@"onlineOk"];
}

- (void)setName:(NSString *)aName {

    [[DeblockConfig get] removePlayer:self];
    
    [_name release];
    _name = [aName copy];
    
    [[DeblockConfig get] updatePlayer:self];
}

- (NSString *)onlineName {

    if ([[NSThread currentThread] isMainThread])
        [[Logger get] err:@"This method should NOT be called from the MAIN thread!"];

    else if (!_name) {

        self.nameLock = [[[NSConditionLock alloc] initWithCondition:lNotSet] autorelease];
        [self performSelectorOnMainThread:@selector(showNameDialog) withObject:nil waitUntilDone:NO];

        [self.nameLock lockWhenCondition:lSet];
        [self.nameLock unlockWithCondition:_name? lSet: lNotSet];
    }

    return _name;
}

- (NSString *)pass {

    if ([[NSThread currentThread] isMainThread])
        [[Logger get] err:@"This method should NOT be called from the MAIN thread!"];

    else if (!_pass) {

        self.passLock = [[[NSConditionLock alloc] initWithCondition:lNotSet] autorelease];
        [self performSelectorOnMainThread:@selector(showPassDialog) withObject:nil waitUntilDone:NO];

        [self.passLock lockWhenCondition:lSet];
        [self.passLock unlockWithCondition:_pass? lSet: lNotSet];
    }

    return _pass;
}

- (void)showNameDialog {

    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    nameAlert = [[UIAlertView alloc] initWithTitle:l(@"dialog.title.name") message:
                 [NSString stringWithFormat:l(@"dialog.text.name.ask"), self.name]
                                          delegate:self cancelButtonTitle:l(@"button.save") otherButtonTitles:nil];
    [nameAlert addTextFieldWithValue:@"" label:@""];

    nameField                       = [nameAlert textFieldAtIndex:0];
    nameField.keyboardType          = UIKeyboardTypeNamePhonePad;
    nameField.keyboardAppearance    = UIKeyboardAppearanceAlert;
    nameField.autocorrectionType    = UITextAutocorrectionTypeNo;
    [nameAlert show];

    [pool drain];
}

- (void)showPassDialog {

    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    passAlert = [[UIAlertView alloc] initWithTitle:l(@"dialog.title.compete.code") message:
                     [NSString stringWithFormat:l(@"dialog.text.compete.code.ask"), self.name]
                                              delegate:self cancelButtonTitle:l(@"button.save") otherButtonTitles:nil];
    [passAlert addTextFieldWithValue:@"" label:@""];

    passField                       = [passAlert textFieldAtIndex:0];
    passField.keyboardType          = UIKeyboardTypeNumberPad;
    passField.keyboardAppearance    = UIKeyboardAppearanceAlert;
    passField.autocorrectionType    = UITextAutocorrectionTypeNo;
    [passAlert show];

    [pool drain];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView == nameAlert) {

        [self.nameLock lockWhenCondition:lNotSet];
        self.name = nameField.text;
        [self.nameLock unlockWithCondition:_name? lSet: lNotSet];

        [nameAlert release];
        nameAlert = nil;
        nameField = nil;
    }

    if (alertView == passAlert) {

        [self.passLock lockWhenCondition:lNotSet];
        self.pass = passField.text;
        [self.passLock unlockWithCondition:_pass? lSet: lNotSet];

        [passAlert release];
        passAlert = nil;
        passField = nil;
    }
}


- (void)dealloc {

    [self unregisterObservers];

    self.name = nil;
    self.pass = nil;

    [super dealloc];
}

@end
