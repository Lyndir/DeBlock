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
//  DMConfig.h
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Config.h"
#import "Player.h"

#define cCompete          	NSStringFromSelector(@selector(compete))
#define cWsUrl          	NSStringFromSelector(@selector(wsUrl))

#define cLevelScore         NSStringFromSelector(@selector(levelScore))
#define cLevelPenalty       NSStringFromSelector(@selector(levelPenalty))

#define cGameMode           NSStringFromSelector(@selector(gameMode))

#define cSkyColorFrom       NSStringFromSelector(@selector(skyColorFrom))
#define cSkyColorTo         NSStringFromSelector(@selector(skyColorTo))

#define cFlawlessBonus      NSStringFromSelector(@selector(flawlessBonus))

#define cUserName           NSStringFromSelector(@selector(userName))
#define cUserScoreHistory   NSStringFromSelector(@selector(userScoreHistory))

@interface DeblockConfig : Config {

    NSDictionary                                *_playersCached;
}

+ (DeblockConfig *)get;

- (void)addScore:(NSInteger)score;
- (void)saveScore;

- (NSDictionary *)players;
- (Player *)getPlayer:(NSString *)name;
- (Player *)currentPlayer;
- (void)removePlayer:(Player *)player;
- (void)updatePlayer:(Player *)player;

#pragma mark ###############################
#pragma mark Properties

@property (readwrite, retain) NSNumber          *compete;
@property (readwrite, retain) NSString          *wsUrl;

@property (readwrite, retain) NSNumber          *levelScore;
@property (readwrite, retain) NSNumber          *levelPenalty;

@property (readwrite, retain) NSNumber          *gameMode;

@property (readwrite, retain) NSNumber          *skyColorFrom;
@property (readwrite, retain) NSNumber          *skyColorTo;

@property (readwrite, retain) NSNumber          *flawlessBonus;

@property (readwrite, retain) NSString          *userName;
@property (readwrite, retain) NSDictionary      *userScoreHistory;

@end
