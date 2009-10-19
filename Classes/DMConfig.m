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

#import "DMConfig.h"


@implementation DMConfig

@dynamic level, levelScore, levelPenalty;
@dynamic gameMode;
@dynamic skyColorFrom, skyColorTo;
@dynamic flawlessBonus;
@dynamic userName, userScoreHistory;


- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithLong:0x38343C00],                           cShadeColor,

                                [NSArray arrayWithObjects:
                                 @"Carriage_House_Deblock.mp3",
                                 @"Marimba_Deblock.mp3",
                                 @"Staccato_Deblock.mp3",
                                 @"Mjolnir_Deblock.mp3",
                                 @"random",
                                 @"",
                                 nil],                                                          cTracks,
                                [NSArray arrayWithObjects:
                                 @"Carriage_House_Deblock",
                                 @"Marimba",
                                 @"Staccato",
                                 @"Mjolnir",
                                 NSLocalizedString(@"config.song.random", @"Shuffle"),
                                 NSLocalizedString(@"config.song.off", @"Off"),
                                 nil],                                                          cTrackNames,
                                
                                [NSNumber numberWithLong:0],                                    cLevel,
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
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:4763],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"John",
                                 
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:4961],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"Aeryn",
                                 
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:4689],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"D'Argo",
                                 
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:7386],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"Zhaan",
                                 
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:1497],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"Rygel",
                                 
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:2892],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"Chiana",
                                 
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:16744],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"Pilot",
                                 
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:382],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"Crais",
                                 
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:3790],
                                  [NSString stringWithFormat:@"%f",
                                   [[NSDate dateWithTimeIntervalSinceNow:
                                     random() % 10000]
                                    timeIntervalSince1970]],
                                  nil],
                                 @"Scorpius",

                                 nil],                                                          cUserScoreHistory,

                                nil
                                ]];
    
    return self;
}


+ (DMConfig *)get {

    return (DMConfig *)[super get];
}


#pragma mark ###############################
#pragma mark Behaviors

- (void)recordScore:(NSInteger)score {
    
    if (score < 0)
        score = 0;
    
    [super recordScore:score];
    [self saveScore];
}

- (void)saveScore {

    // Find the user's current scores in the score history.
    NSMutableDictionary *newUserScores = [[self userScoreHistory] mutableCopy];
    NSDictionary *currentUserScores = [newUserScores objectForKey:[self userName]];
    
    // Store the new score on the current date amoungst the user's scores.
    NSMutableDictionary *newCurrentUserScores = nil;
    if (currentUserScores)
        newCurrentUserScores = [currentUserScores mutableCopy];
    else
        newCurrentUserScores = [NSMutableDictionary new];
    [newCurrentUserScores setObject:[self score] forKey:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];

    // Store the user's new scores in the score history.
    [newUserScores setObject:newCurrentUserScores forKey:[self userName]];
    [self setUserScoreHistory:newUserScores];
    NSLog(@"user score history:\n%@", [self userScoreHistory]);

    // Clean up. 
    [newCurrentUserScores release];
    [newUserScores release];
}

@end
