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


@interface DeblockAppDelegate ()

- (void)newGame:(id)caller;
- (void)continueGame:(id)caller;
- (void)stopGame:(id)caller;
- (void)levelRedo:(id)caller;
    
@end


@implementation DeblockAppDelegate

@synthesize gameLayer;


#pragma mark ###############################
#pragma mark Lifecycle

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
    
    [uiLayer addChild:gameLayer = [[GameLayer alloc] init]];

    mainMenu = [[MenuLayer menuWithItems:
                 [MenuItemFont itemFromString:@"New Game" target:self selector:@selector(newGame:)],
                 nil] retain];
    MenuItemFont *deblockLogo = [MenuItemLabel itemWithLabel:
                                 [Label labelWithString:@"Deblock"
                                               fontName:NSLocalizedString(@"font.family.fixed", @"American Typewriter")
                                               fontSize:[NSLocalizedString(@"font.size.large", @"48") floatValue]]
                                                      target:nil selector:NULL];
    [deblockLogo setIsEnabled:NO];
    [mainMenu setLogo:deblockLogo];

    pausedMenu = [[MenuLayer menuWithItems:
                   [MenuItemFont itemFromString:@"Continue Game" target:self selector:@selector(continueGame:)],
                   [MenuItemFont itemFromString:@"Stop Game" target:self selector:@selector(stopGame:)],
                   [MenuItemFont itemFromString:@"Restart Level" target:self selector:@selector(levelRedo:)],
                   nil] retain];
    MenuItemFont *pausedLogo = [MenuItemLabel itemWithLabel:
                                 [Label labelWithString:@"Game Paused"
                                               fontName:NSLocalizedString(@"font.family.fixed", @"American Typewriter")
                                               fontSize:[NSLocalizedString(@"font.size.large", @"48") floatValue]]
                                                      target:nil selector:NULL];
    [pausedLogo setIsEnabled:NO];
    [pausedMenu setLogo:pausedLogo];

    gameOverMenu = [[MenuLayer menuWithItems:
                     [MenuItemFont itemFromString:@"Stop Game" target:self selector:@selector(stopGame:)],
                     [MenuItemFont itemFromString:@"Retry Level" target:self selector:@selector(levelRedo:)],
                     nil] retain];
    MenuItemFont *gameOverLogo = [MenuItemLabel itemWithLabel:
                                 [Label labelWithString:@"Game Over"
                                               fontName:NSLocalizedString(@"font.family.fixed", @"American Typewriter")
                                               fontSize:[NSLocalizedString(@"font.size.large", @"48") floatValue]]
                                                      target:nil selector:NULL];
    [gameOverLogo setIsEnabled:NO];
    [gameOverMenu setLogo:gameOverLogo];
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
    
    [gameLayer newGame];
}


- (void)continueGame:(id)caller {

    [[DeblockAppDelegate get] popAllLayers];
}


- (void)stopGame:(id)caller {
    
    [gameLayer stopGame:DbEndReasonEnded];
}


- (void)levelRedo:(id)caller {
    
    [gameLayer levelRedo];
}


+(DeblockAppDelegate *) get {
    
    return (DeblockAppDelegate *) [[UIApplication sharedApplication] delegate];
}


@end
