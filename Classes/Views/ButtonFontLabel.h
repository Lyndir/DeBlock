//
//  ButtonFontLabel.h
//  Deblock
//
//  Created by Maarten Billemont on 18/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "FontLabel.h"


@protocol ButtonFontLabelDelegate

- (void)touched;

@end

@interface ButtonFontLabel : FontLabel {
    
@private
    id<ButtonFontLabelDelegate>                             _delegate;
}

@property (readwrite, retain) id<ButtonFontLabelDelegate>   delegate;

@end
