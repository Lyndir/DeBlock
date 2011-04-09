/*
 * This file is part of Deblock.
 *
 *  Deblock is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Deblock is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Deblock in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  DeblockAppDelegate.h
//  Deblock
//
//  Created by Maarten Billemont on 16/07/09.
//  Copyright lhunath (Maarten Billemont) 2009. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "AbstractCocos2DAppDelegate.h"
#import "GameLayer.h"
#import "MenuLayer.h"
#import "ConfigMenuLayer.h"
#import "DbHUDLayer.h"


@interface DeblockAppDelegate : AbstractCocos2DAppDelegate<MenuDelegate, ConfigMenuDelegate, UIAlertViewDelegate, GKLeaderboardViewControllerDelegate> {

@private
    GameLayer                       *_gameLayer;
    MenuLayer                       *_mainMenu, *_moreMenu, *_newGameMenu, *_pausedMenu, *_gameOverMenu;
    ConfigMenuLayer                 *_configMenu;

    CCMenuItem                      *_continueGame;

    UIAlertView                     *_alertWelcome, *_alertCompete;
}

@property (readonly, retain) GameLayer              *gameLayer;
@property (nonatomic, readonly, retain) DbHUDLayer  *hudLayer;

+(DeblockAppDelegate *) get;

- (void)showMainMenu;
- (void)showScores;
- (void)showGameOverMenu;

@end

