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

@property (readwrite, retain) UIAlertView *alertWelcome;
@property (readwrite, retain) UIAlertView *alertCompete;

@end


@implementation DeblockAppDelegate

@synthesize gameLayer;
@synthesize alertWelcome, alertCompete;


#pragma mark ###############################
#pragma mark Lifecycle

+ (void)initialize {
    
    [DeblockConfig get];
}

- (void)dealloc {
    
    [pausedMenu release];
    pausedMenu = nil;
    
    [gameOverMenu release];
    gameOverMenu = nil;
    
    [mainMenu release];
    mainMenu = nil;
    
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
    
    splashVC = [SplashViewController new];
    [window addSubview:splashVC.view];
    [window makeKeyAndVisible];
    
    mainMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                      items:
                 [MenuItemSpacer spacerNormal],
                 continueGame =
                 [[MenuItemFont itemFromString:l(@"menu.continue")
                                        target:self selector:@selector(continueGame:)] retain],
                 [MenuItemFont itemFromString:l(@"menu.game.new")
                                       target:self selector:@selector(newGame:)],
                 [MenuItemSpacer spacerSmall],
                 [MenuItemFont itemFromString:l(@"menu.strategy")
                                       target:self selector:@selector(strategy:)],
                 nil] retain];
    mainMenu.background         = [Sprite spriteWithFile:@"back.png"];
    mainMenu.outerPadding       = margin(100, 20, 10, 20);
    mainMenu.innerRatio         = 1/20.0f;
    mainMenu.opacity            = 0xcc;
    mainMenu.color              = ccc3(0x99, 0x99, 0xff);
    mainMenu.colorGradient      = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    [mainMenu setNextButtonTarget:self selector:@selector(more)];
    
    moreMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                      items:
                 [MenuItemSpacer spacerNormal],
                 [MenuItemFont itemFromString:l(@"menu.scores")
                                       target:self selector:@selector(scores:)],
                 [MenuItemSpacer spacerSmall],
                 [MenuItemFont itemFromString:l(@"menu.config")
                                       target:self selector:@selector(configuration:)],
                 nil] retain];
    moreMenu.background         = [Sprite spriteWithFile:@"back.png"];
    moreMenu.outerPadding       = margin(100, 20, 10, 20);
    moreMenu.innerRatio         = 1/20.0f;
    moreMenu.opacity            = 0xcc;
    moreMenu.color              = ccc3(0x99, 0x99, 0xff);
    moreMenu.colorGradient      = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    [moreMenu.nextButton setString:@"   ⌕   "];
    [moreMenu setNextButtonTarget:self selector:@selector(log)];
    
    newGameMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                         items:
                    [MenuItemSpacer spacerNormal],
                    [MenuItemFont itemFromString:l(@"menu.game.mode.classic")
                                          target:self selector:@selector(newClassicGame:)],
                    [MenuItemFont itemFromString:l(@"menu.game.mode.timed")
                                          target:self selector:@selector(newTimedGame:)],
                    nil] retain];
    newGameMenu.background      = [Sprite spriteWithFile:@"back.png"];
    newGameMenu.outerPadding    = margin(110, 20, 10, 20);
    newGameMenu.innerRatio      = 1/20.0f;
    newGameMenu.opacity         = 0xcc;
    newGameMenu.color           = ccc3(0x99, 0x99, 0xff);
    newGameMenu.colorGradient   = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    
    configMenu = [[ConfigMenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                           settings:
                   @selector(music),
                   @selector(soundFx),
                   @selector(compete),
                   nil] retain];
    configMenu.background       = [Sprite spriteWithFile:@"back.png"];
    configMenu.outerPadding     = margin(110, 20, 10, 20);
    configMenu.innerRatio       = 1/20.0f;
    configMenu.opacity          = 0xcc;
    configMenu.color            = ccc3(0x99, 0x99, 0xff);
    configMenu.colorGradient    = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    configMenu.layout           = MenuLayoutColumns;
    
    pausedMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemImage itemFromNormalImage:@"title.paused.png"
                                                                             selectedImage:@"title.paused.png"]
                                        items:
                   [MenuItemFont itemFromString:l(@"menu.level.restart")
                                         target:self selector:@selector(levelRedo:)],
                   [MenuItemSpacer spacerSmall],
                   [MenuItemFont itemFromString:l(@"menu.main")
                                         target:self selector:@selector(stopGame:)],
                   [MenuItemFont itemFromString:l(@"menu.game.end")
                                         target:self selector:@selector(endGame:)],
                   nil] retain];
    [pausedMenu setBackButtonTarget:self selector:@selector(resumeGame:)];
    
    gameOverMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemImage itemFromNormalImage:@"title.gameover.png"
                                                                               selectedImage:@"title.gameover.png"]
                                          items:
                     [MenuItemFont itemFromString:l(@"menu.game.end")
                                           target:self selector:@selector(endGame:)],
                     [MenuItemFont itemFromString:l(@"menu.level.retry")
                                           target:self selector:@selector(levelRedo:)],
                     nil] retain];
    
    [uiLayer addChild:gameLayer = [[GameLayer alloc] init]];
}

- (void)showDirector {

    [splashVC.view removeFromSuperview];
    
    mainMenu.fadeNextEntry  = NO;
    [self pushLayer:mainMenu];

    Scene *uiScene = [Scene node];
    [uiScene addChild:self.uiLayer];
    [[Director sharedDirector] runWithScene:uiScene];
}


- (void)didEnter:(MenuLayer *)menuLayer {
    
    if (menuLayer == mainMenu) {
        [continueGame setIsEnabled:[[DeblockConfig get] currentPlayer].level > 1];
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
    
    if(!hudLayer)
        hudLayer = [DbHUDLayer new];
    
    return hudLayer;
}


- (void)poppedAll {
    
    self.gameLayer.paused = NO;
}


- (void)pushLayer:(ShadeLayer *)layer {
    
    self.gameLayer.paused = YES;
    
    [super pushLayer:layer];
}


- (void)hudMenuPressed {
    
    [self pushLayer:mainMenu hidden:YES];
    [self pushLayer:pausedMenu];
}


- (void)showMainMenu {

    [self pushLayer:mainMenu];
}


- (void)showScores {
    
    [self pushLayer:mainMenu hidden:YES];
    [self pushLayer:[ScoresLayer get]];
}


- (void)showGameOverMenu {
    
    [self pushLayer:gameOverMenu];
}


- (void)newGame:(id)caller {
    
    [self pushLayer:newGameMenu];
}


- (void)newClassicGame:(id)caller {
    
    [gameLayer newGameWithMode:DbModeClassic];
}


- (void)newTimedGame:(id)caller {
    
    [gameLayer newGameWithMode:DbModeTimed];
}


- (void)continueGame:(id)caller {
    
    [gameLayer startGame];
}


- (void)resumeGame:(id)caller {

    [[DeblockAppDelegate get] popAllLayers];
}


- (void)stopGame:(id)caller {
    
    [gameLayer stopGame:DbEndReasonStopped];
}


- (void)endGame:(id)caller {
    
    [gameLayer stopGame:DbEndReasonEnded];
}


- (void)levelRedo:(id)caller {
    
    [gameLayer levelRedo];
}


- (void)more {
    
    [[DeblockAppDelegate get] pushLayer:moreMenu];
}


- (void)configuration:(id)caller {
    
    [[DeblockAppDelegate get] pushLayer:configMenu];
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
