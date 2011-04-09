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
#import "MenuItemSpacer.h"
#import "MenuItemTitle.h"
#import "StrategyLayer.h"
#import "LogLayer.h"
#import "ActivitySprite.h"


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
- (void)moreGames:(id)caller;
- (void)strategy:(id)caller;
- (void)scores:(id)caller;
- (void)log;		


@property (readwrite, retain) GameLayer                       *gameLayer;
@property (readwrite, retain) MenuLayer                       *mainMenu;
@property (readwrite, retain) MenuLayer                       *moreMenu;
@property (readwrite, retain) MenuLayer                       *newGameMenu;
@property (readwrite, retain) MenuLayer                       *pausedMenu;
@property (readwrite, retain) MenuLayer                       *gameOverMenu;
@property (readwrite, retain) ConfigMenuLayer                 *configMenu;

@property (readwrite, retain) CCMenuItem                      *continueGame;

@property (readwrite, retain) UIAlertView                     *alertWelcome;
@property (readwrite, retain) UIAlertView                     *alertCompete;

@end


@implementation DeblockAppDelegate

@synthesize gameLayer = _gameLayer;
@synthesize mainMenu = _mainMenu, moreMenu = _moreMenu, newGameMenu = _newGameMenu, pausedMenu = _pausedMenu, gameOverMenu = _gameOverMenu;
@synthesize configMenu = _configMenu;
@synthesize continueGame = _continueGame;
@synthesize alertWelcome = _alertWelcome, alertCompete = _alertCompete;



#pragma mark ###############################
#pragma mark Lifecycle

+ (void)initialize {
    
    [Logger get].autoprintLevel = LogLevelDebug;
    [DeblockConfig get];
}

- (void)dealloc {
    
    self.pausedMenu = nil;
    self.gameOverMenu = nil;
    self.mainMenu = nil;
    
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    [CCDirector sharedDirector].openGLView.multipleTouchEnabled = YES;
    
    // Game Center setup.
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
        if (error)
            wrn(@"Game Center unavailable: %@", error);
    }]; 

    if ([[Config get].firstRun boolValue]) {
        self.alertWelcome = [[[UIAlertView alloc] initWithTitle:l(@"dialog.title.firsttime")
                                                        message:l(@"dialog.text.firsttime.strategy")
                                                       delegate:self cancelButtonTitle:l(@"common.button.thanks") otherButtonTitles:nil] autorelease];
        [self.alertWelcome show];
    }
    
    self.mainMenu = [MenuLayer menuWithDelegate:self logo:nil
                                          items:
                 self.continueGame =
                     [CCMenuItemFont itemFromString:l(@"menu.continue")
                                             target:self selector:@selector(continueGame:)],
                     [CCMenuItemFont itemFromString:l(@"menu.game.new")
                                             target:self selector:@selector(newGame:)],
                     [MenuItemSpacer spacerSmall],
                     [CCMenuItemFont itemFromString:l(@"menu.strategy")
                                             target:self selector:@selector(strategy:)],
                     /*[CCMenuItemFont itemFromString:@"Shutdown"
                                             target:self selector:@selector(shutdown:)],*/
                     nil];
    [self.mainMenu setNextButtonTarget:self selector:@selector(more)];
    self.mainMenu.offset             = ccp(0, -80);
    self.mainMenu.background         = [CCSprite spriteWithFile:@"back.png"];
    self.mainMenu.outerPadding       = margin(150, -240, 10, -240);
    self.mainMenu.innerRatio         = 0;
    self.mainMenu.opacity            = 0x99;
    self.mainMenu.color              = ccc3(0xcc, 0xcc, 0xff);
    self.mainMenu.colorGradient      = ccc4(0xff, 0xff, 0xff, 0xdd);

    self.moreMenu = [MenuLayer menuWithDelegate:self logo:nil
                                          items:
                     [CCMenuItemFont itemFromString:l(@"menu.scores")
                                             target:self selector:@selector(scores:)],
                     [CCMenuItemFont itemFromString:l(@"menu.moregames")
                                             target:self selector:@selector(moreGames:)],
                     [MenuItemSpacer spacerSmall],
                     [CCMenuItemFont itemFromString:l(@"menu.config")
                                             target:self selector:@selector(configuration:)],
                     nil];
    [(CCMenuItemFont *)self.moreMenu.nextButton setString:@"   ⌕   "];
    [self.moreMenu setNextButtonTarget:self selector:@selector(log)];
    self.moreMenu.offset             = ccp(0, -80);
    self.moreMenu.background         = [CCSprite spriteWithFile:@"back.png"];
    self.moreMenu.outerPadding       = margin(150, -240, 10, -240);
    self.moreMenu.innerRatio         = 0;
    self.moreMenu.opacity            = 0x99;
    self.moreMenu.color              = ccc3(0xcc, 0xcc, 0xff);
    self.moreMenu.colorGradient      = ccc4(0xff, 0xff, 0xff, 0xdd);
    
    self.newGameMenu = [MenuLayer menuWithDelegate:self logo:nil
                                             items:
                        [CCMenuItemFont itemFromString:l(@"menu.game.mode.classic")
                                                target:self selector:@selector(newClassicGame:)],
                        [CCMenuItemFont itemFromString:l(@"menu.game.mode.timed")
                                                target:self selector:@selector(newTimedGame:)],
                        nil];
    self.newGameMenu.offset          = ccp(0, -80);
    self.newGameMenu.background      = [CCSprite spriteWithFile:@"back.png"];
    self.newGameMenu.outerPadding    = margin(150, -240, 10, -240);
    self.newGameMenu.innerRatio      = 0;
    self.newGameMenu.opacity         = 0x99;
    self.newGameMenu.color           = ccc3(0xcc, 0xcc, 0xff);
    self.newGameMenu.colorGradient   = ccc4(0xff, 0xff, 0xff, 0xdd);
    
    self.configMenu = [ConfigMenuLayer menuWithDelegate:self logo:nil
                                               settings:
                       @selector(music),
                       @selector(soundFx),
                       @selector(kidsMode),
                       nil];
    self.configMenu.offset           = ccp(0, -80);
    self.configMenu.background       = [CCSprite spriteWithFile:@"back.png"];
    self.configMenu.outerPadding     = margin(150, -240, 10, -240);
    self.configMenu.innerRatio       = 0;
    self.configMenu.opacity          = 0x99;
    self.configMenu.color            = ccc3(0xcc, 0xcc, 0xff);
    self.configMenu.colorGradient    = ccc4(0xff, 0xff, 0xff, 0xdd);
    self.configMenu.layout           = MenuLayoutColumns;
    
    self.pausedMenu = [MenuLayer menuWithDelegate:self logo:[CCMenuItemImage itemFromNormalImage:@"title.game.paused.png"
                                                                                   selectedImage:@"title.game.paused.png"]
                                            items:
                       [CCMenuItemFont itemFromString:l(@"menu.level.restart")
                                               target:self selector:@selector(levelRedo:)],
                       [MenuItemSpacer spacerSmall],
                       [CCMenuItemFont itemFromString:l(@"menu.main")
                                               target:self selector:@selector(stopGame:)],
                       [CCMenuItemFont itemFromString:l(@"menu.game.end")
                                               target:self selector:@selector(endGame:)],
                       nil];
    [self.pausedMenu setBackButtonTarget:self selector:@selector(resumeGame:)];
    
    self.gameOverMenu = [MenuLayer menuWithDelegate:self logo:[CCMenuItemImage itemFromNormalImage:@"title.game.over.png"
                                                                                     selectedImage:@"title.game.over.png"]
                                              items:
                         [CCMenuItemFont itemFromString:l(@"menu.game.end")
                                                 target:self selector:@selector(endGame:)],
                         [CCMenuItemFont itemFromString:l(@"menu.level.retry")
                                                 target:self selector:@selector(levelRedo:)],
                         nil];
    [self.gameOverMenu setBackButtonTarget:nil selector:nil];
    
    [self.uiLayer addChild:self.gameLayer = [GameLayer node]];

    self.mainMenu.fadeNextEntry  = NO;
    [self pushLayer:self.mainMenu];
    
    CCScene *uiScene = [CCScene node];
    [uiScene addChild:self.uiLayer];
    [[CCDirector sharedDirector] runWithScene:uiScene];
    
    return YES;
}


- (void)didEnter:(MenuLayer *)menuLayer {
    
    if (menuLayer == self.mainMenu) {
        [self.continueGame setIsEnabled:[Player currentPlayer].level > 1 && ![[DeblockConfig get].kidsMode boolValue]];
    }
}

- (void)didUpdateConfigForKey:(SEL)configKey {
    
    [super didUpdateConfigForKey:configKey];
    
    if (configKey == @selector(kidsMode))
        self.hudLayer.visible = ![[DeblockConfig get].kidsMode boolValue];
}


- (NSString *)labelForSetting:(SEL)setting {
    
    if (setting == @selector(music))
        return l(@"menu.config.music");

    else if (setting == @selector(soundFx))
        return l(@"menu.config.sound");
    
    else if (setting == @selector(kidsMode))
        return l(@"dialog.title.kidsMode");
    
    else
        return nil;
}


- (NSArray *)toggleItemsForSetting:(SEL)setting {
    
    return nil;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView == self.alertWelcome)
        self.alertWelcome = nil;
}



-(DbHUDLayer *) hudLayer {
    
    if(!_hudLayer)
        _hudLayer = [[DbHUDLayer alloc] init];
    
    return (DbHUDLayer *)super.hudLayer;
}


- (void)poppedAll {
    
    [super poppedAll];
    
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
    
    // TODO: GameKit
    [self showMainMenu];
    [self scores:nil];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissModalViewControllerAnimated:YES];
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


- (void)moreGames:(id)caller {
    
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:@"http://iphone.lhunath.com"]];
}


- (void)strategy:(id)caller {
    
    [self pushLayer:[StrategyLayer node]];
}


- (void)scores:(id)caller {
    
    GKLeaderboardViewController *leaderboardController = [GKLeaderboardViewController new];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:leaderboardController animated:YES];
        [leaderboardController release];
    }
}


- (void)log {
    
    [self pushLayer:[LogLayer node]];
}


+ (DeblockAppDelegate *)get {
    
    return (DeblockAppDelegate *) [super get];
}


@end
