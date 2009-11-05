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
#import "Logger.h"
#import "CryptUtils.h"

#define dScoreServlet   @"/scores.json"


@interface DeblockWSController ()

- (NSString *)checksumForName:(NSString *)name withScore:(NSNumber *)score;

@end

@implementation DeblockWSController

+ (DeblockWSController *)get {
    
    static DeblockWSController* instance;
    if (!instance)
        instance = [DeblockWSController new];
    
    return instance;
}

- (void)reloadScores {

    [self submitScore:nil forPlayer:nil achievedAt:nil];
}


- (void)submitScore:(NSNumber *)score forPlayer:(NSString *)playerName achievedAt:(NSDate *)achievedDate {

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:dScoreServlet
                                                                            relativeToURL:[NSURL URLWithString:[DMConfig get].wsUrl]]];
    [request setDelegate:self];

    if (score && playerName && achievedDate) {
        [[Logger get] inf:@"Submitting score %@ for %@ at %@", score, playerName, achievedDate];

        NSNumber *timeStamp = [NSNumber numberWithLong:(long)([achievedDate timeIntervalSince1970] * 1000)];
        [request setPostValue:score forKey:@"score"];
        [request setPostValue:playerName forKey:@"name"];
        [request setPostValue:timeStamp forKey:@"date"];
        [request setPostValue:[self checksumForName:playerName withScore:score] forKey:@"check"];
    }
    
    [request startAsynchronous];
}


- (NSString *)checksumForName:(NSString *)name withScore:(NSNumber *)score {
    
    NSDictionary *secrets = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Secret" ofType:@"plist"]];
    return [CryptUtils md5:[NSString stringWithFormat:@"%@:%d:%@", name, [score intValue], [secrets objectForKey:@"Salt"]]];
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSError *error = nil;
    NSDictionary *playersScoreHistory = [NSDictionary dictionaryWithJSONData:[request responseData] error:&error];
    if (error)
        [[Logger get] err:@"Couldn't parse online scores: %@", error];
    else {
        [DMConfig get].userScoreHistory = playersScoreHistory;
        [[Logger get] inf:@"Online scores:\n%@", playersScoreHistory];
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request {

    [[Logger get] err:@"Couldn't fetch online scores: %@", request.error];
}


@end
