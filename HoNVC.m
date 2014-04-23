//
//  HoNVC.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "HoNVC.h"
#import "CompanyView.h"
#import "DraggableView.h"
#include "HoNManager.h"
#import <CoreLocation/CoreLocation.h>

@interface HoNVC ()  <CLLocationManagerDelegate>
@property(strong, nonatomic) CLLocationManager *manager;
@property(strong, nonatomic) CLGeocoder *geocoder;
@property(strong, nonatomic) CLPlacemark *placemark;
@property(strong, nonatomic) NSArray *companiesFromServer;
@end

@implementation HoNVC

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

-(void)awakeFromNib{
    HoNManager *myHonManager = [HoNManager sharedHoNManager];
    //    //[myHonManager clearUserDefaults];
    [myHonManager loadCompanyCards];
}

- (IBAction)skip:(id)sender
{
    UIView *toRemove = [[self.view subviews] lastObject];
    HoNManager *manager = [HoNManager sharedHoNManager];
    DraggableView *toRemoveTmp = (DraggableView *)toRemove;
    [manager castVote:@"unknown_vote" forCompany:toRemoveTmp.company andLocation:@"TEMPLOC"];
    [toRemove removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    HoNManager *myHonManager = [HoNManager sharedHoNManager];
    [myHonManager loadCompanyCards];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager startUpdatingLocation];

    NSArray *companyDeck = [[NSUserDefaults standardUserDefaults] valueForKey:@"companyDeck"];
    
    for (NSDictionary *companyCard in companyDeck) {
        NSString *companyName = [companyCard objectForKey:@"name"];
        NSString *companyUrl = [companyCard objectForKey:@"img_url"];
        
        [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:companyName andUrl:companyUrl]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
