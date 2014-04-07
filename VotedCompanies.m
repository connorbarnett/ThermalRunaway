//
//  VotedCompanies.m
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "VotedCompanies.h"

@implementation VotedCompanies
- (void)addCompanyToVotedCompanies:(NSString *)newCompany
{
    NSMutableDictionary *votedCompanies = [self retreiveVotedCompanies];
    if (!votedCompanies) {
        NSNumber *count = [NSNumber numberWithInt:1];
        votedCompanies = [[NSMutableDictionary alloc] init];
        [votedCompanies setObject:count forKey:newCompany];
    } else {
        if([votedCompanies objectForKey:newCompany] == nil) {
            [votedCompanies setObject:@1 forKey:newCompany];
        } else {
            NSNumber *currentVoteCountNumber = (NSNumber *)[votedCompanies objectForKey:newCompany];
            NSInteger currentVoteCountNumberInt = [currentVoteCountNumber integerValue];
            currentVoteCountNumberInt++;
            NSNumber *number = [NSNumber numberWithInteger:currentVoteCountNumberInt];
            [votedCompanies setObject:number forKey:newCompany];
        }
    }
    NSArray *sortedCompanies = [votedCompanies keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] < [obj2 integerValue])
            return (NSComparisonResult)NSOrderedDescending;
        if ([obj1 integerValue] > [obj2 integerValue])
            return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
    [[NSUserDefaults standardUserDefaults] setObject:sortedCompanies forKey:@"sortedCompanies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:votedCompanies forKey:@"companiesDictionary"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)subtractCompanyToVotedCompanies:(NSString *)newCompany
{
    NSMutableDictionary *votedCompanies = [self retreiveVotedCompanies];
    if (!votedCompanies) {
        NSNumber *count = [NSNumber numberWithInt:-1];
        votedCompanies = [[NSMutableDictionary alloc] init];
        [votedCompanies setObject:count forKey:newCompany];
    } else {
        if([votedCompanies objectForKey:newCompany] == nil) {
            [votedCompanies setObject:@-1 forKey:newCompany];
        } else {
            NSNumber *currentVoteCountNumber = (NSNumber *)[votedCompanies objectForKey:newCompany];
            NSInteger currentVoteCountNumberInt = [currentVoteCountNumber integerValue];
            currentVoteCountNumberInt--;
            NSNumber *number = [NSNumber numberWithInteger:currentVoteCountNumberInt];
            [votedCompanies setObject:number forKey:newCompany];
        }
    }
    NSArray *sortedCompanies = [votedCompanies keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] < [obj2 integerValue])
            return (NSComparisonResult)NSOrderedDescending;
        if ([obj1 integerValue] > [obj2 integerValue])
            return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
    [[NSUserDefaults standardUserDefaults] setObject:sortedCompanies forKey:@"sortedCompanies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:votedCompanies forKey:@"companiesDictionary"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableDictionary *)retreiveVotedCompanies
{
    NSDictionary *immuatble = [[NSUserDefaults standardUserDefaults] valueForKey:@"companiesDictionary"];
    NSMutableDictionary *mutable = [immuatble mutableCopy];
    return mutable;
}

- (NSMutableArray *)retreiveSortedCompanies
{
    NSMutableArray *immuatble = [[NSUserDefaults standardUserDefaults] valueForKey:@"sortedCompanies"];
    NSMutableArray *mutable = [immuatble mutableCopy];
    return mutable;
}

- (NSInteger)retreiveVoteCount:(NSString *)companyName
{
    NSMutableDictionary *companies = [self retreiveVotedCompanies];
    if([companies valueForKey:companyName] == nil) {
        return 0;
    } else {
        NSNumber *voteCountAsNumber = (NSNumber *)[companies valueForKey:companyName];
        NSInteger voteCountAsInt = [voteCountAsNumber integerValue];
        return voteCountAsInt;
    }
}
@end
