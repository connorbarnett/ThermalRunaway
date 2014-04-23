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
@property(strong, nonatomic) CLLocationManager *manager;
@property(strong, nonatomic) CLGeocoder *geocoder;
@property(strong, nonatomic) CLPlacemark *placemark;

+ (id)sharedHoNManager;

-(CLLocationManager *)manager;
-(CLGeocoder *)geocoder;

- (void)loadCompanyCards;
- (void)loadCompanyVoteCards:(NSString *) companyName;
- (void)clearUserDefaults;
- (void)castVote:(NSString *)vote_type forCompany:(NSString *)company andLocation:(NSString *)loc;
//- (void) getVoteCount:(UITableViewCell *)cell forCompany:(NSString *)company;
@end
