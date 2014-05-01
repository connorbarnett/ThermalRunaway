//
//  HoNManager.m
//  Thermal
//
//  Created by Robert Dunlevie on 4/22/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#include "AFNetworking.h"
#import "HoNManager.h"

@interface HoNManager () <CLLocationManagerDelegate>
@property size_t curPage;
@property(strong, nonatomic) CLLocationManager *manager;
@property(strong, nonatomic) CLGeocoder *geocoder;
@property(strong, nonatomic) CLPlacemark *placemark;
@property(strong, nonatomic) NSMutableArray *currentDeck;
@property(strong, atomic)CLLocation *lastLocation;
@property(strong, nonatomic)NSString *deviceId;
@property BOOL hasUpatedDeck;
@end

@implementation HoNManager 

//Needs to change to ec2 eventually
//static NSString * const BaseURLString = @"http://ec2-54-224-194-212.compute-1.amazonaws.com:3000/";
static NSString * const BaseURLString = @"http://localhost:3000/";

+ (id)sharedHoNManager {
    static HoNManager *sharedHoNManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHoNManager = [[self alloc] init];
    });
    return sharedHoNManager;
}

- (void)incrementPageCount {
    self.curPage++;
}

- (void)resetPageCount{
    self.curPage = 1;
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

-(NSMutableArray *)currentDeck
{
    if(!_currentDeck) _currentDeck = [[NSMutableArray alloc] init];
    return _currentDeck;
}

-(NSString *)deviceId
{
    NSLog(@"setting the deviceid");
    if(!_deviceId) {
        NSUUID *deviceId = [[UIDevice currentDevice] identifierForVendor];
        _deviceId = [deviceId UUIDString];
    }
    return _deviceId;
}

- (void)startLocationServices{
//    self.manager.delegate = self;
//    [self.manager setDelegate:self];
    self.manager.distanceFilter = kCLDistanceFilterNone;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager startUpdatingLocation];
}

- (void)loadAllCompanyCards{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@company/getall.json",BaseURLString]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] forKey:@"allCompanyInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"allCompanyDataLoaded" object:nil];
    }];
    [dataTask resume];
}

- (void)loadDeck {
//    if(![[NSUserDefaults standardUserDefaults] valueForKey:@"companyDeck"]){
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@companies.json/?page=%zu",BaseURLString, self.curPage]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if([[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] count] == 0 && self.hasUpatedDeck){//no cards loaded so we start over, for now
                dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Company Deck Empty"
                                                                    message:@"Sorry, you've already voted on all companies.  Vote again on your previous companies!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                });
                self.hasUpatedDeck = false;
                [self resetPageCount];
                [self loadDeck];
            }
            else if([[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] count] == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loading Companies"
                                                                        message:[error localizedDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [alertView show];
                });
            }
            else{
                self.hasUpatedDeck = true;
                [[NSUserDefaults standardUserDefaults] setObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] forKey:@"curCompanyDeck"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"obtainedCurDeckInfo" object:nil];
            }
        }];
    [dataTask resume];
//    }
//    else{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"obtainedCompanyInfo" object:nil];
//    }
}

- (void)loadVoteTypesForCompany:(NSString *) company {
    NSString *defaultsKey = [NSString stringWithFormat:@"voteInfoFor%@",company];
//    if(![[NSUserDefaults standardUserDefaults] valueForKey:defaultsKey]){
        NSURLSession *session = [NSURLSession sharedSession];
        NSString *urlString = [NSString stringWithFormat:@"%@vote/count.json/?name=%@",BaseURLString, company];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] forKey:defaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"obtainedVotesFor%@",company] object:nil];
        }];
        [dataTask resume];
//    }
//    else
//        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"obtainedVotesFor%@",company] object:nil];
}

-(void)addCompanyToDeck:(NSString *)companyName{
    NSDictionary *curCompany = [[NSDictionary alloc] initWithObjectsAndKeys:@"name", companyName, nil];
    [self.currentDeck addObject:curCompany];
}

- (void)removeTopCompanyFromDeck{
    if(!self.currentDeck) return;
    
    [self.currentDeck removeLastObject];
}

- (BOOL)deckEmpty{
    BOOL deckEmpty = [self.currentDeck count] == 0;
    return deckEmpty;
}

- (void)loadNextDeck{
    [self incrementPageCount];
    [self loadDeck];
}

- (void)castVote:(NSString *)vote_type forCompany:(NSString *)company{
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    
    
    NSDictionary *parameters = @{@"vote_type": vote_type, @"name" : company, @"vote_location" : [NSString stringWithFormat:@"%f,%f",self.lastLocation.coordinate.longitude,self.lastLocation.coordinate.latitude], @"device_id" : self.deviceId};
    
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.lastLocation = [locations lastObject];
    NSLog(@"Last Location: %@", self.lastLocation);
        if(self.lastLocation != nil) {
            NSLog(@"Lat: %.8f", self.lastLocation.coordinate.latitude);
            NSLog(@"Long: %.8f", self.lastLocation.coordinate.longitude);
        }
    [self.geocoder reverseGeocodeLocation:self.lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error != nil){
            NSLog(@"Error %@", error.debugDescription);
        }
    }];
}


@end
