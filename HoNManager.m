//
//  HoNManager.m
//  Thermal
//
//  Created by Robert Dunlevie on 4/22/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.

#include "AFNetworking.h"
#import "HoNManager.h"
#import "GAI.h"

@interface HoNManager () <CLLocationManagerDelegate>
@property size_t curPage;
@property(strong, nonatomic) CLLocationManager *manager;
@property(strong, nonatomic) CLGeocoder *geocoder;
@property(strong, nonatomic) CLPlacemark *placemark;
@property(strong, nonatomic) NSMutableArray *currentDeck;
@property(strong, atomic)CLLocation *lastLocation;
@property(strong, nonatomic)NSString *deviceId;
@end

@implementation HoNManager 

//static NSString * const BaseURLString = @"http://ec2-54-224-194-212.compute-1.amazonaws.com:3000/";
static NSString * const BaseURLString = @"http://localhost:3000/";

#pragma mark - Singleton creation

+ (id)sharedHoNManager {
    static HoNManager *sharedHoNManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHoNManager = [[self alloc] init];
    });
    return sharedHoNManager;
}

#pragma mark - simple incrementations

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

- (void)incrementPageCount {
    self.curPage++;
}

- (void)resetPageCount{
    self.curPage = 1;
}

#pragma mark - Property Lazy Instantiation

/**
 *  Lazy instantiation for the Location Manager
 *
 *  @return the location manager being instantiated
 */
-(CLLocationManager *)manager
{
    if(!_manager) _manager = [[CLLocationManager alloc] init];
    return _manager;
}

/**
 *  Lazy instantiation for the Geocoder
 *
 *  @return the geocoder being instantiated
 */
-(CLGeocoder *)geocoder
{
    if(!_geocoder) _geocoder = [[CLGeocoder alloc] init];
    return _geocoder;
}

/**
 *  Lazy instantiation of currentDeck array of company cards
 *
 *  @return the company card array being instantiated
 */
-(NSMutableArray *)currentDeck
{
    if(!_currentDeck) _currentDeck = [[NSMutableArray alloc] init];
    return _currentDeck;
}

/**
 *  Unique instantiation of companies unique deviceId.  Uses iOS's built in identifierForVendor method to find a devices UDID
 *
 *  @return the instantiated UDID of the device being used
 */
-(NSString *)deviceId
{
    if(!_deviceId) {
        NSUUID *deviceId = [[UIDevice currentDevice] identifierForVendor];
        _deviceId = [deviceId UUIDString];
    }
    return _deviceId;
}

#pragma mark - GET request methods

- (void)loadAllCompanyCards{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@company/getall.json",BaseURLString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *companyCards = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:companyCards forKey:@"allCompanyInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"allCompanyDataLoaded" object:nil];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error loading company cards"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}

- (void)loadDeck {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@companies.json/?page=%zu",BaseURLString, self.curPage]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *curDeck = (NSDictionary *)responseObject;
            if([curDeck count] > 0){
                [[NSUserDefaults standardUserDefaults] setObject:curDeck forKey:@"curCompanyDeck"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"obtainedCurDeckInfo" object:nil];
            }
            else{
               dispatch_async(dispatch_get_main_queue(), ^{
                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"company deck empty"
                                                                             message:@"sorry, you've already voted on all companies.  vote again on your previous companies!"
                                                                             delegate:nil
                                                                             cancelButtonTitle:@"ok"
                                                                             otherButtonTitles:nil];
                   [alertView show];
                    });
                    [self resetPageCount];
                    [self loadDeck];
            }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loading Company Deck"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
}

- (void)loadComparisonsDeck {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/company/getcomparisons.json",BaseURLString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *curComparisonsDeck = (NSArray *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:curComparisonsDeck forKey:@"curComparisonDeck"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"obtainedCurComparisonDeckInfo" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error loading comparisons deck"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
    
}

- (void)loadVoteTypesForCompany:(NSString *) company {
    NSString *defaultsKey = [NSString stringWithFormat:@"voteInfoFor%@",company];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@company/voteinfo.json/?name=%@",BaseURLString, company]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *companyVoteInfo = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:companyVoteInfo forKey:defaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"obtainedVotesFor%@",company] object:nil];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error loading company information"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}

//- (void)loadComparisonInfoForCompany:(NSString *)company{
//   NSString *defaultsKey = [NSString stringWithFormat:@"compareInfoFor%@",company];
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@company/compareinfo.json/?name=%@",BaseURLString, company]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *companyComparisonInfo = (NSDictionary *)responseObject;
////        [[NSUserDefaults standardUserDefaults] setObject:companyComparisonInfo forKey:defaultsKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"obtainedComparisonsFor%@",company] object:nil];
//    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error loading company comparison information"
//                                                            message:[error localizedDescription]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"ok"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }];
//    
//    [operation start];
//}

- (void)loadComparisonPercentageForCompany:(NSString *)firstCompany andOtherCompany:(NSString *)secondCompany{
    NSString *defaultsKey = @"latestComparePercentage";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@company/comparePercentage.json/?first_company_name=%@&second_company_name=%@",BaseURLString, firstCompany, secondCompany]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *companyComparisonInfo = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:companyComparisonInfo forKey:defaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"obtainedLatestComparisonsPercentage" object:nil];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error loading company comparison percentage"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}


#pragma mark - POST Request methods

- (void)castVote:(NSString *)vote_type forCompany:(NSString *)company{
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];

    NSDictionary *parameters = @{@"vote_type": vote_type, @"name" : company, @"vote_location" : [NSString stringWithFormat:@"%f,%f",self.lastLocation.coordinate.latitude,self.lastLocation.coordinate.longitude], @"device_id" : self.deviceId};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"vote.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Made succesful POST Request");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error posting vote"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)castComparisonForCompany:(NSString *) winningCompany overCompany:(NSString *) losingCompany wasSkip:(BOOL)wasSkip{
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    NSDictionary *parameters = @{@"winningCompany" : winningCompany, @"losingCompany" : losingCompany, @"vote_location" : [NSString stringWithFormat:@"%f,%f",self.lastLocation.coordinate.latitude,self.lastLocation.coordinate.longitude], @"device_id" : self.deviceId, @"was_skip" : [NSNumber numberWithBool:wasSkip]};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"compare.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
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

- (id)init {
    self = [super init];
    return self;
}

#pragma mark - CLLocationManagerDelegate Methods

/**
 *  Begins location services by assigning preferences such as accuracy and then starting to update the location
 */
- (void)startLocationServices{
    self.manager.delegate = self;
    [self.manager setDelegate:self];
    self.manager.distanceFilter = kCLDistanceFilterNone;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager startUpdatingLocation];
}

/**
 *  Logs location based errors to console or log files
 *
 *  @param manager LocationManager that experienced the error
 *  @param error   The error that occured with location services
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location!");
}

/**
 *  Method called in background only when location services are running and a new, unique location has been visited
 *
 *  @param manager   manager that is keeping track of location services
 *  @param locations array containing all unique locations visited during location service's runtime.  Latest location visited by user stored as the last object in the array.
 */
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
