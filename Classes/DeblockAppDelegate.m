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
#import "StatsLayer.h"
#import "MenuItemSpacer.h"
#import "MenuItemTitle.h"


@interface DeblockAppDelegate ()

- (void)newClassicGame:(id)caller;
- (void)newTimedGame:(id)caller;
- (void)continueGame:(id)caller;
- (void)resumeGame:(id)caller;
- (void)stopGame:(id)caller;
- (void)levelRedo:(id)caller;
    
@end


@implementation DeblockAppDelegate

@synthesize gameLayer;


#pragma mark ###############################
#pragma mark Lifecycle

+ (void)initialize {
    
    [DMConfig get];
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
    
    playerVC = [PlayerViewController new];
    [window addSubview:playerVC.view];
    [window makeKeyAndVisible];
    
    mainMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                      items:
                 [MenuItemSpacer spacerNormal],
                 continueGame =
                 [[MenuItemFont itemFromString:@"Continue Game" target:self selector:@selector(continueGame:)] retain],
                 [MenuItemFont itemFromString:@"New Game" target:self selector:@selector(newGame:)],
                 [MenuItemSpacer spacerSmall],
                 [MenuItemFont itemFromString:@"Statistics" target:self selector:@selector(statistics:)],
                 nil] retain];
    mainMenu.background         = [Sprite spriteWithFile:@"splash.png"];
    mainMenu.outerPadding       = margin(110, 20, 10, 20);
    mainMenu.innerRatio         = 1/20.0f;
    mainMenu.opacity            = 0xcc;
    mainMenu.color              = ccc3(0x99, 0x99, 0xff);
    mainMenu.colorGradient      = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    
    newGameMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemSpacer spacerLarge]
                                         items:
                    [MenuItemSpacer spacerNormal],
                    [MenuItemFont itemFromString:@"Classic" target:self selector:@selector(newClassicGame:)],
                    [MenuItemFont itemFromString:@"Timed" target:self selector:@selector(newTimedGame:)],
                    nil] retain];
    newGameMenu.background      = [Sprite spriteWithFile:@"splash.png"];
    newGameMenu.outerPadding    = margin(110, 20, 10, 20);
    newGameMenu.innerRatio      = 1/20.0f;
    newGameMenu.opacity         = 0xcc;
    newGameMenu.color           = ccc3(0x99, 0x99, 0xff);
    newGameMenu.colorGradient   = ccc4(0xcc, 0xcc, 0xff, 0xcc);
    
    pausedMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemImage itemFromNormalImage:@"title.paused.png"
                                                                             selectedImage:@"title.paused.png"]
                                        items:
                   [MenuItemFont itemFromString:@"Resume Game" target:self selector:@selector(resumeGame:)],
                   [MenuItemFont itemFromString:@"Restart Level" target:self selector:@selector(levelRedo:)],
                   [MenuItemSpacer spacerSmall],
                   [MenuItemFont itemFromString:@"End Game" target:self selector:@selector(stopGame:)],
                   nil] retain];
    
    gameOverMenu = [[MenuLayer menuWithDelegate:self logo:[MenuItemImage itemFromNormalImage:@"title.gameover.png"
                                                                               selectedImage:@"title.gameover.png"]
                                          items:
                     [MenuItemFont itemFromString:@"Stop Game" target:self selector:@selector(stopGame:)],
                     [MenuItemFont itemFromString:@"Retry Level" target:self selector:@selector(levelRedo:)],
                     nil] retain];
    
    [uiLayer addChild:gameLayer = [[GameLayer alloc] init]];
}

- (void)showDirector {

    [playerVC.view removeFromSuperview];
    
    mainMenu.fadeNextEntry  = NO;
    [self pushLayer:mainMenu];

    Scene *uiScene = [Scene node];
    [uiScene addChild:self.uiLayer];
    [[Director sharedDirector] runWithScene:uiScene];
}

- (void)didEnter:(MenuLayer *)menuLayer {
    
    if (menuLayer == mainMenu) {
        [continueGame setIsEnabled:[[DMConfig get].level intValue] > 1];
    }
}


-(HUDLayer *) hudLayer {
    
    if(!hudLayer)
        hudLayer = [[DbHUDLayer alloc] init];
    
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
    
    [self pushLayer:pausedMenu];
}


- (void)showMainMenu {

    [self pushLayer:mainMenu];
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
    
    [gameLayer stopGame:DbEndReasonEnded];
}


- (void)levelRedo:(id)caller {
    
    [gameLayer levelRedo];
}


- (void)statistics:(id)caller {
    
    [[DeblockAppDelegate get] pushLayer:[StatsLayer get]];
}


+ (DeblockAppDelegate *)get {
    
    return (DeblockAppDelegate *) [super get];
}


@end
