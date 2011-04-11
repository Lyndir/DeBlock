//
//  Player.m
//  Deblock
//
//  Created by Maarten Billemont on 06/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Player.h"
#import <GameKit/GameKit.h>

#define lNotSet 2<<0
#define lSet    2<<1


@interface Player ()

+ (NSString *)localID;

- (void)registerObservers;

@end

@implementation Player

@synthesize playerID = _playerID;
@synthesize score = _score;
//@synthesize level = _level;
@synthesize mode = _mode;


- (id)init {
    
    [self = [super init] registerObservers];
    
    self.playerID = [Player localID];

    return self;
}

+ (NSString *)localID {
    
    return [GKLocalPlayer localPlayer].playerID? [GKLocalPlayer localPlayer].playerID: @"local";
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if(!(self = [super init]))
        return self;
    
    _playerID               = [[decoder decodeObjectForKey: @"playerID"] retain];
    _score                  = [decoder decodeIntegerForKey: @"score"];
    _level                  = [decoder decodeIntegerForKey: @"level"];
    _mode                   = [decoder decodeIntegerForKey: @"mode"];
    
    [self registerObservers];
    
    return self;
}

+ (Player *)currentPlayer {
    
    Player *currentPlayer = [[DeblockConfig get].players objectForKey:[Player localID]];
    if (!currentPlayer)
        currentPlayer = [[Player new] autorelease];

    return currentPlayer;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_playerID                 forKey: @"playerID"];
    [encoder encodeInteger:_score                   forKey: @"score"];
    [encoder encodeInteger:_level                   forKey: @"level"];
    [encoder encodeInteger:_mode                    forKey: @"mode"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self)
        [[DeblockConfig get] updatePlayer:self];
}

- (void)registerObservers {

    [self addObserver:self forKeyPath:@"playerID"   options:0 context:NULL];
    [self addObserver:self forKeyPath:@"score"      options:0 context:NULL];
    [self addObserver:self forKeyPath:@"level"      options:0 context:NULL];
    [self addObserver:self forKeyPath:@"mode"       options:0 context:NULL];
}

- (void)unregisterObservers {

    [self removeObserver:self forKeyPath:@"playerID"];
    [self removeObserver:self forKeyPath:@"score"];
    [self removeObserver:self forKeyPath:@"level"];
    [self removeObserver:self forKeyPath:@"mode"];
}

- (void)reset {
    
    self.score = 0;
    self.level = 0;
    self.mode = 0;
}

- (void)setLevel:(NSUInteger)level {
    
    _level = level;
}

- (NSUInteger)level {
    
    return _level;
}

- (void)dealloc {

    [self unregisterObservers];

    [super dealloc];
}

@end
