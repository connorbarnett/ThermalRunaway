//
//  HoNManager.h
//  Thermal
//
//  Created by Robert Dunlevie on 4/22/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface HoNManager : NSObject


+ (id)sharedHoNManager;

-(CLLocationManager *)manager;
-(CLGeocoder *)geocoder;

- (void)startLocationServices;
- (void)loadCompanyCards;
- (void)loadVoteTypesForCompany:(NSString *) company;
- (void)clearUserDefaults;
- (void)castVote:(NSString *)vote_type forCompany:(NSString *)company;
- (void)addCompanyToDeck:(NSString *)companyName withUrl:(NSString *)companyUrl;
- (void)removeTopCompanyFromDeck;
- (BOOL)deckEmpty;
- (void)loadNextDeck;
- (void)incrementPageCount;
- (void)resetPageCount;
@end
