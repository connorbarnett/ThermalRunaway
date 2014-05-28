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

/**
 *
 */
@interface HoNManager : NSObject


+ (id)sharedHoNManager;

-(CLLocationManager *)manager;
-(CLGeocoder *)geocoder;


/**
 * @return
 */
- (void)startLocationServices;
- (void)loadAllCompanyCards;
- (void)loadDeck;
- (void)loadVoteTypesForCompany:(NSString *) company;
- (void)clearUserDefaults;
- (void)castVote:(NSString *)vote_type forCompany:(NSString *)company;
- (void)castComparisonForCompany:(NSString *) winningCompany overCompany:(NSString *) losingCompany wasSkip:(BOOL)wasSkip;
- (void)loadComparisonsDeck;
- (void)addCompanyToDeck:(NSString *)companyName;
- (void)removeTopCompanyFromDeck;
- (BOOL)deckEmpty;
- (void)loadNextDeck;
- (void)incrementPageCount;
- (void)resetPageCount;
@end
