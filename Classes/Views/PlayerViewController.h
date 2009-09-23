//
//  PlayerViewController.h
//  Deblock
//
//  Created by Maarten Billemont on 17/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ButtonFontLabel.h"


@interface PlayerViewController : UIViewController<UITextFieldDelegate, ButtonFontLabelDelegate> {

@private
    UITextField                 *playerField;
}

@end
