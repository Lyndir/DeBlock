//
//  DeblockWSController.h
//  Deblock
//
//  Created by Maarten Billemont on 03/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "Player.h"


@interface DeblockWSController : NSObject<ASIHTTPRequestDelegate, UIAlertViewDelegate> {

    NSMutableDictionary     *_requestsPlayer;
    
    UIAlertView             *_alertPassword, *_alertConnection;
    Player                  *_alertPlayer;
}

/**
 * Get the singleton instance.
 */
+ (DeblockWSController *)get;

/**
 * A dictionary with a structure like this:
 *
 * { username -> { date -> score, ... }, ... }
 *
 * The username is an NSString*.
 * The date is an NSString* of an NSTimeInterval since the UNIX epoch.
 * The score is an NSNumber*.
 */
- (void)reloadScores;
- (void)submitScoreForPlayer:(Player *)player;

@end
