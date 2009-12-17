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
//  DeblockAppDelegate.m
//  Deblock
//
//  Created by Maarten Billemont on 16/07/09.
//  Copyright lhunath (Maarten Billemont) 2009. All rights reserved.
//

#import "DeblockAppDelegate.h"
#import "DbHUDLayer.h"
#import "ScoresLayer.h"
#import "MenuItemSpacer.h"
#import "MenuItemTitle.h"
#import "StrategyLayer.h"
#import "DeblockWSController.h"
#import "LogLayer.h"


@interface DeblockAppDelegate ()

- (void)newGame:(id)caller;
- (void)newClassicGame:(id)caller;
- (void)newTimedGame:(id)caller;
- (void)continueGame:(id)caller;
- (void)resumeGame:(id)caller;
- (void)endGame:(id)caller;
- (void)stopGame:(id)caller;
- (void)levelRedo:(id)caller;
- (void)more;
- (void)configuration:(id)caller;
- (void)strategy:(id)caller;
- (void)scores:(id)caller;
- (void)log;


@property (readwrite, retain) SplashViewController            *splashVC;

@property (readwrite, retain) GameLayer                       *gameLayer;
@property (readwrite, retain) MenuLayer                       *mainMenu;
@property (readwrite, retain) MenuLayer                       *moreMenu;
@property (readwrite, retain) MenuLayer                       *newGameMenu;
@property (readwrite, retain) MenuLayer                       *pausedMenu;
@property (readwrite, retain) MenuLayer                       *gameOverMenu;
@property (readwrite, retain) ConfigMenuLayer                 *configMenu;

@property (readwrite, retain) MenuItem                        *continueGame;

@property (readwrite, retain) UIAlertView                     *alertWelcome;
@property (readwrite, retain) UIAlertView                     *alertCompete;

@end


@implementation DeblockAppDelegate

@synthesize splashVC = _splashVC;
@synthesize gameLayer = _gameLayer;
@synthesize mainMenu = _mainMenu, moreMenu = _moreMenu, newGameMenu = _newGameMenu, pausedMenu = _pausedMenu, gameOverMenu = _gameOverMenu;
@synthesize configMenu = _configMenu;
@synthesize continueGame = _continueGame;
@synthesize alertWelcome = _alertWelcome, alertCompete = _alertCompete;



#pragma mark ###############################
#pragma mark Lifecycle

+ (void)initialize {
    
    [DeblockConfig get];
}

- (void)dealloc {
    
    self.pausedMenu = nil;
    self.gameOverMenu = nil;
    self.mainMenu = nil;
    
    self.splashVC = nil;
    self.gameLayer = nil;
    self.moreMenu = nil;
    self.newGameMenu = nil;
    self.configMenu = nil;
    self.continueGame = nil;
    self.alertWelcome = nil;
    self.alertCompete = nil;

    [super dealloc];
}


#pragma mark ###############################
#pragma mark Behaviors

- (void)prepareUi {
    
    if ([[Config get].firstRun boolValue]) {
        self.alertWelcome = [[[UIAlertView alloc] initWithTitle:l(@"dialog.title.firsttime")
                                                        message:l(@"dialog.text.firsttime.strategy")
                                                       delegate:self cancelButtonTitle:l(@"button.thanks") otherButtonTitles:nil] autorelease];
        [self.alertWelcome show];
    }
    
    [[DeblockWSController get] reloadScores];
    
    self.splashVC = [[SplashViewController new] autorelease];
    [self.window addSubview:self.splashVC.view];
    [self.window makeKeyAndVisible];
    
    self.mainMenu = [MenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                          items:
                     [MenuItemSpacer spacerNormal],
                 self.continueGame =
                     [MenuItemFont itemFromString:l(@"menu.continue")
                                           target:self selector:@selector(continueGame:)],
                     [MenuItemFont itemFromString:l(@"menu.game.new")
                                           target:self selector:@selector(newGame:)],
                     [MenuItemSpacer spacerSmall],
                     [MenuItemFont itemFromString:l(@"menu.strategy")
                                           target:self selector:@selector(strategy:)],
                     [MenuItemFont itemFromString:@"Shutdown"
                                           target:self selector:@selector(shutdown:)],
                     nil];
    self.mainMenu.background         = [Sprite spriteWithFile:@"back.png"];
    self.mainMenu.outerPadding       = margin(100, 0, 10, 0);
    self.mainMenu.innerRatio         = 0;
    self.mainMenu.opacity            = 0xcc;
    self.mainMenu.color              = ccc3(0x99, 0x99, 0xff);
    self.mainMenu.colorGradient      = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    [self.mainMenu setNextButtonTarget:self selector:@selector(more)];

    self.moreMenu = [MenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                          items:
                     [MenuItemSpacer spacerNormal],
                     [MenuItemFont itemFromString:l(@"menu.scores")
                                           target:self selector:@selector(scores:)],
                     [MenuItemSpacer spacerSmall],
                     [MenuItemFont itemFromString:l(@"menu.config")
                                           target:self selector:@selector(configuration:)],
                     nil];
    self.moreMenu.background         = [Sprite spriteWithFile:@"back.png"];
    self.moreMenu.outerPadding       = margin(100, 0, 10, 0);
    self.moreMenu.innerRatio         = 0;
    self.moreMenu.opacity            = 0xcc;
    self.moreMenu.color              = ccc3(0x99, 0x99, 0xff);
    self.moreMenu.colorGradient      = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    [self.moreMenu.nextButton setString:@"   ⌕   "];
    [self.moreMenu setNextButtonTarget:self selector:@selector(log)];
    
    self.newGameMenu = [MenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                             items:
                        [MenuItemSpacer spacerNormal],
                        [MenuItemFont itemFromString:l(@"menu.game.mode.classic")
                                              target:self selector:@selector(newClassicGame:)],
                        [MenuItemFont itemFromString:l(@"menu.game.mode.timed")
                                              target:self selector:@selector(newTimedGame:)],
                        nil];
    self.newGameMenu.background      = [Sprite spriteWithFile:@"back.png"];
    self.newGameMenu.outerPadding    = margin(110, 0, 10, 0);
    self.newGameMenu.innerRatio      = 0;
    self.newGameMenu.opacity         = 0xcc;
    self.newGameMenu.color           = ccc3(0x99, 0x99, 0xff);
    self.newGameMenu.colorGradient   = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    
    self.configMenu = [ConfigMenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                               settings:
                       @selector(music),
                       @selector(soundFx),
                       @selector(compete),
                       nil];
    self.configMenu.background       = [Sprite spriteWithFile:@"back.png"];
    self.configMenu.outerPadding     = margin(110, 0, 10, 0);
    self.configMenu.innerRatio       = 0;
    self.configMenu.opacity          = 0xcc;
    self.configMenu.color            = ccc3(0x99, 0x99, 0xff);
    self.configMenu.colorGradient    = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    self.configMenu.layout           = MenuLayoutColumns;
    
    self.pausedMenu = [MenuLayer menuWithDelegate:self logo:[MenuItemImage itemFromNormalImage:@"title.game.paused.png"
                                                                                 selectedImage:@"title.game.paused.png"]
                                            items:
                       [MenuItemFont itemFromString:l(@"menu.level.restart")
                                             target:self selector:@selector(levelRedo:)],
                       [MenuItemSpacer spacerSmall],
                       [MenuItemFont itemFromString:l(@"menu.main")
                                             target:self selector:@selector(stopGame:)],
                       [MenuItemFont itemFromString:l(@"menu.game.end")
                                             target:self selector:@selector(endGame:)],
                       nil];
    [self.pausedMenu setBackButtonTarget:self selector:@selector(resumeGame:)];
    
    self.gameOverMenu = [MenuLayer menuWithDelegate:self logo:[MenuItemImage itemFromNormalImage:@"title.game.over.png"
                                                                                   selectedImage:@"title.game.over.png"]
                                              items:
                         [MenuItemFont itemFromString:l(@"menu.game.end")
                                               target:self selector:@selector(endGame:)],
                         [MenuItemFont itemFromString:l(@"menu.level.retry")
                                               target:self selector:@selector(levelRedo:)],
                         nil];
    
    [self.uiLayer addChild:self.gameLayer = [GameLayer node]];
}

- (void)showDirector {

    [self.splashVC.view removeFromSuperview];
    
    self.mainMenu.fadeNextEntry  = NO;
    [self pushLayer:self.mainMenu];

    Scene *uiScene = [Scene node];
    [uiScene addChild:self.uiLayer];
    [[Director sharedDirector] runWithScene:uiScene];
}


- (void)didEnter:(MenuLayer *)menuLayer {
    
    if (menuLayer == self.mainMenu) {
        [self.continueGame setIsEnabled:[[DeblockConfig get] currentPlayer].level > 1];
    }
}


- (NSString *)labelForSetting:(SEL)setting {
    
    if (setting == @selector(music))
        return l(@"menu.config.music");

    else if (setting == @selector(soundFx))
        return l(@"menu.config.sound");
    
    else if (setting == @selector(compete))
        return l(@"dialog.title.compete");
    
    else
        return nil;
}


- (NSMutableArray *)toggleItemsForSetting:(SEL)setting {
    
    if (setting == @selector(compete))
        return [NSMutableArray arrayWithObjects:
                [MenuItemFont itemFromString:l(@"menu.config.off")],
                [MenuItemFont itemFromString:l(@"menu.config.wifi+carrier")],
                [MenuItemFont itemFromString:l(@"menu.config.wifi")],
                nil];
    
    return nil;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView == self.alertWelcome) {
        self.alertCompete = [[[UIAlertView alloc] initWithTitle:l(@"dialog.title.compete")
                                                        message:l(@"dialog.text.compete")
                                                       delegate:self cancelButtonTitle:l(@"button.no.kind") otherButtonTitles:l(@"button.sure"), nil] autorelease];
        [self.alertCompete show];

        self.alertWelcome = nil;
    }
    else if (alertView == self.alertCompete) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            [DeblockConfig get].compete = [NSNumber numberWithUnsignedInt:DbCompeteOff];
            [[[[UIAlertView alloc] initWithTitle:l(@"dialog.title.compete")
                                         message:l(@"dialog.text.compete.later")
                                        delegate:nil cancelButtonTitle:l(@"button.thanks") otherButtonTitles:nil] autorelease] show];
        }
        else
            [DeblockConfig get].compete = [NSNumber numberWithUnsignedInt:DbCompeteWiFiCarrier];
        
        self.alertCompete = nil;
    }
}



-(HUDLayer *) hudLayer {
    
    if(!super.hudLayer)
        self.hudLayer = [DbHUDLayer node];
    
    return super.hudLayer;
}


- (void)poppedAll {
    
    self.gameLayer.paused = NO;
}


- (void)pushLayer:(ShadeLayer *)layer {
    
    self.gameLayer.paused = YES;
    
    [super pushLayer:layer];
}


- (void)hudMenuPressed {
    
    [self pushLayer:self.mainMenu hidden:YES];
    [self pushLayer:self.pausedMenu];
}


- (void)showMainMenu {

    [self pushLayer:self.mainMenu];
}


- (void)showScores {
    
    [self pushLayer:self.mainMenu hidden:YES];
    [self pushLayer:[ScoresLayer get]];
}


- (void)showGameOverMenu {
    
    [self pushLayer:self.gameOverMenu];
}


- (void)newGame:(id)caller {
    
    [self pushLayer:self.newGameMenu];
}


- (void)newClassicGame:(id)caller {
    
    [self.gameLayer newGameWithMode:DbModeClassic];
}


- (void)newTimedGame:(id)caller {
    
    [self.gameLayer newGameWithMode:DbModeTimed];
}


- (void)continueGame:(id)caller {
    
    [self.gameLayer startGame];
}


- (void)resumeGame:(id)caller {

    [[DeblockAppDelegate get] popAllLayers];
}


- (void)stopGame:(id)caller {
    
    [self.gameLayer stopGame:DbEndReasonStopped];
}


- (void)endGame:(id)caller {
    
    [self.gameLayer stopGame:DbEndReasonEnded];
}


- (void)levelRedo:(id)caller {
    
    [self.gameLayer levelRedo];
}


- (void)more {
    
    [[DeblockAppDelegate get] pushLayer:self.moreMenu];
}


- (void)configuration:(id)caller {
    
    [[DeblockAppDelegate get] pushLayer:self.configMenu];
}


- (void)strategy:(id)caller {
    
    [self pushLayer:[StrategyLayer node]];
}


- (void)scores:(id)caller {
    
    [self pushLayer:[ScoresLayer get]];
}


- (void)log {
    
    [self pushLayer:[LogLayer node]];
}


+ (DeblockAppDelegate *)get {
    
    return (DeblockAppDelegate *) [super get];
}


@end
