//
//  VotedCompanies.h
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VotedCompanies : NSObject

- (void) addCompanyToVotedCompanies:(NSString *)newCompany;
- (NSMutableDictionary *)retreiveVotedCompanies;
- (NSMutableArray *)retreiveSortedCompanies;
- (NSInteger)retreiveVoteCount:(NSString *)companyName;
- (void)subtractCompanyToVotedCompanies:(NSString *)newCompany;

@end
