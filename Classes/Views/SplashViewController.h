//
//  SplashViewController.h
//  Deblock
//
//  Created by Maarten Billemont on 22/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SplashViewController : UIViewController {

    UIImageView                                     *_top, *_bottom;
}

@property (readwrite, retain) IBOutlet UIImageView  *top;
@property (readwrite, retain) IBOutlet UIImageView  *bottom;

@end
