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


@interface DeblockConfig ()

@property (readwrite, retain) NSDictionary                                *playersCached;

@end


@implementation DeblockConfig

@synthesize playersCached = _playersCached;

@dynamic compete;
@dynamic levelScore, levelPenalty;
@dynamic skyColorFrom, skyColorTo;
@dynamic flawlessBonus;


- (id)init {
    
    if (!(self = [super init]))
        return nil;

    NSMutableCharacterSet *delimitors = [NSMutableCharacterSet whitespaceCharacterSet];
    [delimitors formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [self.defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithLong:0x38343C00],                           cShadeColor,

                                [NSNumber numberWithUnsignedInt:DbCompeteOff],                  cCompete,
                                
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

- (void)removePlayer:(Player *)player {
    
    NSMutableDictionary *players = [[[self players] mutableCopy] autorelease];
    [players removeObjectForKey:player.playerID];
    
    NSData *playersArchive = [NSKeyedArchiver archivedDataWithRootObject:players];
    [self.defaults setObject:playersArchive forKey:@"players"];
    [self.defaults synchronize];
    
    [_playersCached release];
    _playersCached = [players retain];
}

- (void)updatePlayer:(Player *)player {
    
    if (!player.playerID)
        return;
    
    NSMutableDictionary *players = [[[self players] mutableCopy] autorelease];
    [players setObject:player forKey:player.playerID];
    
    NSData *playersArchive = [NSKeyedArchiver archivedDataWithRootObject:players];
    [self.defaults setObject:playersArchive forKey:@"players"];
    [self.defaults synchronize];
    
    [_playersCached release];
    _playersCached = [players retain];
}

- (void)addScore:(NSInteger)score {
    
    [Player currentPlayer].score = MAX(0, [Player currentPlayer].score + score);

    [self submitScore];
}

- (void)submitScore {

    // TODO: GameKit
    /*
    NSNumber *mode = [NSNumber numberWithUnsignedInteger:[self currentPlayer].mode];
    NSNumber *level = [NSNumber numberWithUnsignedInteger:[self currentPlayer].level];
    NSNumber *score = [NSNumber numberWithInteger:[self currentPlayer].score];
    NSString *name = self.userName;
    NSDate *achievedDate = [NSDate date];

    // Build a new player score object.
    NSDictionary *newCurrentUserScores = [NSDictionary dictionaryWithObjectsAndKeys:
                                          mode,
                                          @"m",
                                          level,
                                          @"l",
                                          score,
                                          @"s",
                                          [NSString stringWithFormat:@"%f", [achievedDate timeIntervalSince1970]],
                                          @"d",
                                          nil];

    // Store the user's new scores in the player scores.
    NSMutableDictionary *newPlayerScores = [[self playerScores] mutableCopy];
    [newPlayerScores setObject:newCurrentUserScores forKey:name];
    [self setPlayerScores:newPlayerScores];
    [newPlayerScores release];

    // Submit the score online.
    [[DeblockWSController get] submitScoreForPlayer:[self currentPlayer]];*/
}


- (void)dealloc {

    self.playersCached = nil;

    [super dealloc];
}

@end
