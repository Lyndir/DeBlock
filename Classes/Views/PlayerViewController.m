//
//  PlayerViewController.m
//  Deblock
//
//  Created by Maarten Billemont on 17/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "PlayerViewController.h"
#import "DeblockAppDelegate.h"
#import "FontManager.h"


@interface PlayerViewController ()

- (void)playerAutocomplete:(NSString *)userText;
- (void)loadPass;

@property (readwrite, retain) UIAlertView   *alertCode;

@end

@implementation PlayerViewController

@synthesize playerTitle, playerField, playerSuggestion, next;
@synthesize alertCode;

- (id)init {
    
    return [self initWithNibName:@"PlayerView" bundle:nil];
}

- (void)viewDidLoad {
    
    self.playerField.text       = [DeblockConfig get].userName;
    self.playerSuggestion.text  = @"";
    
    self.playerTitle.zFont      = [[FontManager sharedManager] zFontWithName:[Config get].fontName
                                                                   pointSize:[[Config get].fontSize intValue]];
    self.playerTitle.text       = l(@"menu.player.name");
    self.next.zFont             = [[FontManager sharedManager] zFontWithName:[Config get].symbolicFontName
                                                                   pointSize:[[Config get].largeFontSize intValue]];
}

- (void)touched {
    
    if (!self.playerField.text.length) {
        [AudioController vibrate];
        return;
    }
    
    [DeblockConfig get].userName = [self playerName];
    if ([[DeblockConfig get].compete unsignedIntValue] != DbCompeteOff && ![[DeblockConfig get] currentPlayer].onlineOk) {
        self.alertCode = [[[UIAlertView alloc] initWithTitle:l(@"dialog.title.compete.code")
                                                     message:l(@"dialog.text.compete.code")
                                                    delegate:self cancelButtonTitle:l(@"button.okay") otherButtonTitles:nil] autorelease];
        [self.alertCode show];
    }
    [[DeblockAppDelegate get] showDirector];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSString *oldText = textField.text;
    NSString *newText = [[oldText stringByReplacingCharactersInRange:range withString:string]
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (textField == self.playerField)
        [self playerAutocomplete:newText];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.playerField)
        [self playerAutocomplete:self.playerField.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.playerField) {
        self.playerField.text       = [self playerName];
        self.playerSuggestion.text  = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (![textField.text length])
        return NO;
    
    [textField resignFirstResponder];
    return YES;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.alertCode) {
        [[[[NSThread alloc] initWithTarget:self selector:@selector(loadPass) object:nil] autorelease] start];
        
        self.alertCode = nil;
    }
}

- (void)loadPass {
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [[DeblockConfig get] saveScore];
    [pool drain];
}


- (void)playerAutocomplete:(NSString *)userText {

    self.playerSuggestion.text  = @"";
    
    NSArray *playerNames = [[[DeblockConfig get] players] allKeys];
    for (NSString *playerName in playerNames)
        if ([playerName hasPrefix:userText]) {
            NSMutableString *paddedSuggestionText = [NSMutableString stringWithCapacity:[playerName length]];
            for (NSUInteger pad = [userText length]; pad > 0; --pad)
                [paddedSuggestionText appendString:@" "];
            [paddedSuggestionText appendString:[playerName stringByReplacingCharactersInRange:NSMakeRange(0, [userText length])
                                                                                   withString:@""]];
            
            self.playerSuggestion.text  = paddedSuggestionText;
            break;
        }
}

- (NSString *)playerName {
    
    NSMutableString *name = [NSMutableString stringWithCapacity:fmaxf([self.playerSuggestion.text length],
                                                                      [self.playerField.text length])];
    [name appendString:self.playerField.text];
    if ([self.playerSuggestion.text length] > [name length])
        [name appendString:[self.playerSuggestion.text stringByReplacingCharactersInRange:NSMakeRange(0, [name length])
                                                                               withString:@""]];
    
    return name;
}

@end
