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


@implementation DeblockConfig

@dynamic compete, wsUrl;
@dynamic levelScore, levelPenalty;
@dynamic gameMode;
@dynamic skyColorFrom, skyColorTo;
@dynamic flawlessBonus;
@dynamic userName, userScoreHistory;


- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithLong:0x38343C00],                           cShadeColor,

                                [NSNumber numberWithUnsignedInt:DbCompeteOff],                  cCompete,
                                @"https://lhunath-deblock.appspot.com",                         cWsUrl,
                                
                                [NSArray arrayWithObjects:
                                 @"Carriage_House_Deblock.mp3",
                                 @"Marimba_Deblock.mp3",
                                 @"Staccato_Deblock.mp3",
                                 @"Mjolnir_Deblock.mp3",
                                 @"random",
                                 @"",
                                 nil],                                                          cTracks,
                                [NSArray arrayWithObjects:
                                 l(@"menu.config.song.carriageHouse"),
                                 l(@"menu.config.song.marimba"),
                                 l(@"menu.config.song.staccato"),
                                 l(@"menu.config.song.mjolnir"),
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
                                  componentsSeparatedByCharactersInSet:
                                  [NSCharacterSet whitespaceCharacterSet]]
                                 objectAtIndex:0],                                              cUserName,
                                [NSDictionary dictionary],                                      cUserScoreHistory,

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
        _playersCached = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults dataForKey:@"players"]] retain];
        
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
    
    NSMutableDictionary *players = [[self players] mutableCopy];
    [players removeObjectForKey:player.name];
    
    NSData *playersArchive = [NSKeyedArchiver archivedDataWithRootObject:players];
    [defaults setObject:playersArchive forKey:@"players"];
    [defaults synchronize];
    
    [_playersCached release];
    _playersCached = players;
}

- (void)updatePlayer:(Player *)player {
    
    if (!player.name)
        return;
    
    NSMutableDictionary *players = [[self players] mutableCopy];
    [players setObject:player forKey:player.name];
    
    NSData *playersArchive = [NSKeyedArchiver archivedDataWithRootObject:players];
    [defaults setObject:playersArchive forKey:@"players"];
    [defaults synchronize];
    
    [_playersCached release];
    _playersCached = players;
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


@end
