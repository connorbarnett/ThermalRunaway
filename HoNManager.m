//
//  HoNManager.m
//  Thermal
//
//  Created by Robert Dunlevie on 4/22/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#include "AFNetworking.h"
#import "HoNManager.h"

@implementation HoNManager

//Needs to change to ec2 eventually
static NSString * const BaseURLString = @"http://localhost:3000/";

+ (id)sharedHoNManager {
    static HoNManager *sharedHoNManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHoNManager = [[self alloc] init];
    });
    return sharedHoNManager;
}

-(CLLocationManager *)manager
{
    if(!_manager) _manager = [[CLLocationManager alloc] init];
    return _manager;
}

-(CLGeocoder *)geocoder
{
    if(!_geocoder) _geocoder = [[CLGeocoder alloc] init];
    return _geocoder;
}


- (void)loadCompanyCards {
//    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager startUpdatingLocation];
    NSLog(@"loading cards");
    if(![[NSUserDefaults standardUserDefaults] valueForKey:@"companyDeck"]){
        NSLog(@"preparing to make a network call");
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://localhost:3000/companies.json"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] forKey:@"companyDeck"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    [dataTask resume];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"obtainedCompanyInfo" object:nil];
}

-(void)loadCompanyVoteCards:(NSString *) companyName{
    NSString *votesKey = [NSString stringWithFormat:@"votesDeckFor%@",companyName];
    if(![[NSUserDefaults standardUserDefaults] valueForKey:votesKey]){
        NSString *urlString = [NSString stringWithFormat:@"http://localhost:3000/vote/lookup.json/?name=%@",companyName];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] forKey:votesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    [dataTask resume];
    }
}

- (void)castVote:(NSString *)vote_type forCompany:(NSString *)company andLocation:(NSString *)loc{
    
    
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    NSDictionary *parameters = @{@"vote_type": vote_type, @"name" : company, @"vote_location" : loc};
    
    // 2
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"vote.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Made succesful POST Request");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Posting Vote"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

-(void)clearUserDefaults{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init {
    self = [super init];
    return self;
}

#pragma mark - CLLocationManagerDelegate Methods
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location!");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location: %@", newLocation);
    CLLocation * currentLocation = newLocation;
    //    if(currentLocation != nil) {
    //        NSLog(@"Lat: %.8f", currentLocation.coordinate.latitude);
    //        NSLog(@"Long: %.8f", currentLocation.coordinate.longitude);
    //    }
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error == nil && placemarks.count > 0) {
            self.placemark = [placemarks lastObject];
            NSLog(@"placemark %@ %@ \n %@ %@ \n %@ \n %@", self.placemark.subThoroughfare, self.placemark.thoroughfare, self.placemark.postalCode, self.placemark.locality, self.placemark.administrativeArea, self.placemark.country);
        } else {
            NSLog(@"Error %@", error.debugDescription);
        }
    }];
}


@end
