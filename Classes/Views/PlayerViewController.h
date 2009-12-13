//
//  PlayerViewController.h
//  Deblock
//
//  Created by Maarten Billemont on 17/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ButtonFontLabel.h"


@interface PlayerViewController : UIViewController<UITextFieldDelegate, ButtonFontLabelDelegate> {

    FontLabel                   *_playerTitle;

    UITextField                 *_playerField;
    UILabel                     *_playerSuggestion;

    ButtonFontLabel             *_next;

    UIAlertView                 *_alertCode;
}

@property (retain) IBOutlet FontLabel       *playerTitle;
@property (retain) IBOutlet UITextField     *playerField;
@property (retain) IBOutlet UILabel         *playerSuggestion;
@property (retain) IBOutlet ButtonFontLabel *next;

- (NSString *)playerName;

@end
