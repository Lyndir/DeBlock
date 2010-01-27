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
//  DMConfig.m
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "DeblockConfig.h"
#import "DeblockWSController.h"


@interface DeblockConfig ()

@property (readwrite, retain) NSDictionary                                *playersCached;

@end


@implementation DeblockConfig

@synthesize playersCached = _playersCached;

@dynamic compete, wsUrl;
@dynamic levelScore, levelPenalty;
@dynamic gameMode;
@dynamic skyColorFrom, skyColorTo;
@dynamic flawlessBonus;
@dynamic userName, userScoreHistory;


- (id)init {
    
    if (!(self = [super init]))
        return nil;

    NSMutableCharacterSet *delimitors = [NSMutableCharacterSet whitespaceCharacterSet];
    [delimitors formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [self.defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithLong:0x38343C00],                           cShadeColor,

                                [NSNumber numberWithUnsignedInt:DbCompeteOff],                  cCompete,
                                @"https://lhunath-deblock.appspot.com",                         cWsUrl,
                                
                                [NSArray arrayWithObjects:
                                 @"title.mp3",
                                 @"pause.mp3",
                                 @"lev1.mp3",
                                 @"lev2.mp3",
                                 @"lev5.mp3",
                                 @"lev6final.mp3",
                                 @"mjolnir.mp3",
                                 
                                 @"sequential",
                                 @"random",
                                 @"",
                                 nil],                                                          cTracks,
                                [NSArray arrayWithObjects:
                                 @"title",
                                 @"pause",
                                 @"lev1",
                                 @"lev2",
                                 @"lev5",
                                 @"lev6final",
                                 @"mjolnir",
                                 
                                 l(@"menu.config.song.sequential"),
                                 l(@"menu.config.song.random"),
                                 l(@"menu.config.song.off"),
                                 nil],                                                          cTrackNames,

                                [NSNumber numberWithLong:0],                                    cLevelScore,
                                [NSNumber numberWithLong:0],                                    cLevelPenalty,

                                [NSNumber numberWithLong:DbModeClassic],                        cGameMode,
                                
                                [NSNumber numberWithLong:0x58748Cff],                           cSkyColorFrom,
                                [NSNumber numberWithLong:0xB3D5F2ff],                           cSkyColorTo,
                                
                                [NSNumber numberWithInt:10],                                    cFlawlessBonus,

                                [[[[UIDevice currentDevice] name]
                                  componentsSeparatedByCharactersInSet:delimitors]
                                 objectAtIndex:0],                                              cUserName,
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:3876] forKey:@"0"],
                                 @"John",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:4012] forKey:@"0"],
                                 @"Aeryn",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:3589] forKey:@"0"],
                                 @"D'Argo",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:5076] forKey:@"0"],
                                 @"Zhaan",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:1319] forKey:@"0"],
                                 @"Rygel",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:2931] forKey:@"0"],
                                 @"Chiana",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:9017] forKey:@"0"],
                                 @"Pilot",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:4017] forKey:@"0"],
                                 @"Stark",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:3875] forKey:@"0"],
                                 @"Crais",
                                 
                                 [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:4180] forKey:@"0"],
                                 @"Scorpius",
                                 
                                 nil],                                                          cUserScoreHistory,

                                nil
                                ]];
    
    return self;
}


+ (DeblockConfig *)get {

    return (DeblockConfig *)[super get];
}


#pragma mark ###############################
#pragma mark Behaviors

- (NSDictionary *)players {
    
    if (!_playersCached) {
        _playersCached = [[NSKeyedUnarchiver unarchiveObjectWithData:[self.defaults dataForKey:@"players"]] retain];
        
        if(_playersCached == nil)
            _playersCached = [NSDictionary new];
    }
    
    return _playersCached;
}


- (Player *)getPlayer:(NSString *)name {
    
    return [[self players] objectForKey:name];
}


- (Player *)currentPlayer {
    
    Player *currentPlayer = [[self players] objectForKey:self.userName];
    if (![currentPlayer.name isEqualToString:self.userName]) {
        [[Logger get] wrn:@"Player name inconsistency detected (key: %@, name: %@).  Fixing by setting name to key.",
         self.userName, currentPlayer.name];
        currentPlayer.name = self.userName;
    }
    
    if (!currentPlayer) {
        currentPlayer = [[Player new] autorelease];
        currentPlayer.name = self.userName;
    }
    
    return currentPlayer;
}


- (void)removePlayer:(Player *)player {
    
    if (!player.name)
        return;
    
    NSMutableDictionary *players = [[[self players] mutableCopy] autorelease];
    [players removeObjectForKey:player.name];
    
    NSData *playersArchive = [NSKeyedArchiver archivedDataWithRootObject:players];
    [self.defaults setObject:playersArchive forKey:@"players"];
    [self.defaults synchronize];
    
    [_playersCached release];
    _playersCached = [players retain];
}

- (void)updatePlayer:(Player *)player {
    
    if (!player.name)
        return;
    
    NSMutableDictionary *players = [[[self players] mutableCopy] autorelease];
    [players setObject:player forKey:player.name];
    
    NSData *playersArchive = [NSKeyedArchiver archivedDataWithRootObject:players];
    [self.defaults setObject:playersArchive forKey:@"players"];
    [self.defaults synchronize];
    
    [_playersCached release];
    _playersCached = [players retain];
}

- (void)addScore:(NSInteger)score {
    
    NSInteger newScore = [self currentPlayer].score + score;
    if (newScore < 0)
        newScore = 0;
    
    [self currentPlayer].score = newScore;
    [self saveScore];
}

- (void)saveScore {

    NSNumber *score = [NSNumber numberWithInteger:[self currentPlayer].score];
    NSString *name = self.userName;
    NSDate *achievedDate = [NSDate date];

    // Find the user's current scores in the score history.
    NSMutableDictionary *newUserScores = [[self userScoreHistory] mutableCopy];
    NSDictionary *currentUserScores = [newUserScores objectForKey:name];
    
    // Store the new score on the current date amoungst the user's scores.
    NSMutableDictionary *newCurrentUserScores = nil;
    if (currentUserScores)
        newCurrentUserScores = [currentUserScores mutableCopy];
    else
        newCurrentUserScores = [NSMutableDictionary new];
    [newCurrentUserScores setObject:score forKey:[NSString stringWithFormat:@"%f", [achievedDate timeIntervalSince1970]]];

    // Store the user's new scores in the score history.
    [newUserScores setObject:newCurrentUserScores forKey:[self userName]];
    [self setUserScoreHistory:newUserScores];

    // Clean up. 
    [newCurrentUserScores release];
    [newUserScores release];
    
    // Submit the score online.
    [[DeblockWSController get] submitScoreForPlayer:[self currentPlayer]];
}


- (void)dealloc {

    self.compete = nil;
    self.wsUrl = nil;
    self.levelScore = nil;
    self.levelPenalty = nil;
    self.gameMode = nil;
    self.skyColorFrom = nil;
    self.skyColorTo = nil;
    self.flawlessBonus = nil;
    self.userName = nil;
    self.userScoreHistory = nil;
    self.playersCached = nil;

    [super dealloc];
}

@end
