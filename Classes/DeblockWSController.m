//
//  DeblockWSController.m
//  Deblock
//
//  Created by Maarten Billemont on 03/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "DeblockWSController.h"
#import "ASIFormDataRequest.h"
#import "NSDictionary_JSONExtensions.h"
#import "CryptUtils.h"

#define dScoreServlet   @"/scores.json"


@interface DeblockWSController ()

- (NSString *)checksumForName:(NSString *)name withScore:(NSInteger)score atTime:(NSNumber *)timeStamp;

@end

@implementation DeblockWSController

+ (DeblockWSController *)get {
    
    static DeblockWSController* instance;
    if (!instance)
        instance = [DeblockWSController new];
    
    return instance;
}

- (void)reloadScores {

    [self submitScoreForPlayer:nil];
}


- (void)submitScoreForPlayer:(Player *)player {
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:dScoreServlet
                                                                            relativeToURL:[NSURL URLWithString:[DeblockConfig get].wsUrl]]];
    [request setDelegate:self];

    if (player) {
        NSDate *achievedDate = [NSDate date];
        NSNumber *timeStamp = [NSNumber numberWithLong:(long)([achievedDate timeIntervalSince1970] * 1000)];
        [[Logger get] inf:@"Submitting score %d for %@ at %@", player.score, player.name, achievedDate];

        [request setPostValue:[NSNumber numberWithInteger:player.score] forKey:@"score"];
        [request setPostValue:player.name forKey:@"name"];
        [request setPostValue:player.pass forKey:@"pass"];
        [request setPostValue:timeStamp forKey:@"date"];
        [request setPostValue:[self checksumForName:player.name withScore:player.score atTime:timeStamp] forKey:@"check"];
    }
    
    [request startAsynchronous];
}


- (NSString *)checksumForName:(NSString *)name withScore:(NSInteger)score atTime:(NSNumber *)timeStamp {
    
    NSDictionary *secrets = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Secret" ofType:@"plist"]];
    return [CryptUtils md5:[NSString stringWithFormat:@"%@:%d:%@:%d", name, score, [secrets objectForKey:@"Salt"], [timeStamp longValue]]];
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [[Logger get] dbg:@"Response Error: %@", [request error]];
    [[Logger get] dbg:@"Response Headers:\n%@", [request responseHeaders]];
    [[Logger get] dbg:@"Response Body:\n%@", [request responseString]];

    NSError *error = nil;
    NSDictionary *playersScoreHistory = [NSDictionary dictionaryWithJSONData:[request responseData] error:&error];
    if (error)
        [[Logger get] err:@"Couldn't parse online scores: %@", error];
    else {
        [[Logger get] dbg:@"Response Scores:\n%@", playersScoreHistory];
        [DeblockConfig get].userScoreHistory = playersScoreHistory;
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request {

    [[Logger get] err:@"Couldn't fetch online scores from %@: %@", request.url, request.error];
}


@end