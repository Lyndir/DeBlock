//
//  Player.m
//  Deblock
//
//  Created by Maarten Billemont on 06/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Player.h"

@interface Player ()

- (void)registerObservers;

@end


@implementation Player

@synthesize name = _name, score = _score, level = _level;

- (id)init {
    
    [self = [super init] registerObservers];

    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    
    if(!(self = [super init]))
        return self;
    self.name               = [decoder decodeObjectForKey:@"Player_Name"];
    self.score              = [decoder decodeIntegerForKey:@"Player_Score"];
    self.level              = [decoder decodeIntegerForKey:@"Player_Level"];
    
    [self registerObservers];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.name         forKey:@"Player_Name"];
    [encoder encodeInteger:self.score       forKey:@"Player_Score"];
    [encoder encodeInteger:self.level       forKey:@"Player_Level"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self)
        [[DeblockConfig get] updatePlayer:self];
}

- (void)registerObservers {
    
    [self addObserver:self forKeyPath:@"name"   options:0 context:NULL];
    [self addObserver:self forKeyPath:@"score"  options:0 context:NULL];
    [self addObserver:self forKeyPath:@"level"  options:0 context:NULL];
}

- (void)unregisterObservers {
    
    [self removeObserver:self forKeyPath:@"name"];
    [self removeObserver:self forKeyPath:@"score"];
    [self removeObserver:self forKeyPath:@"level"];
}

- (void)dealloc {
    
    [self unregisterObservers];
    
    self.name = nil;
    
    [super dealloc];
}

@end
