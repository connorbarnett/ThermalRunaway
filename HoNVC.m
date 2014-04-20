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
#import <CoreLocation/CoreLocation.h>

@interface HoNVC ()  <CLLocationManagerDelegate>
@property(strong, nonatomic) CLLocationManager *manager;
@property(strong, nonatomic) CLGeocoder *geocoder;
@property(strong, nonatomic) CLPlacemark *placemark;

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

- (IBAction)skip:(id)sender
{
    UIView *toRemove = [[self.view subviews] lastObject];
    [toRemove removeFromSuperview];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager startUpdatingLocation];
    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"nest" andUrl:@"http://www.technewsworld.com/images/rw734591/home-energy-consumption.jpg"]];
    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"Lyft" andUrl:@"http://upload.wikimedia.org/wikipedia/commons/4/48/Lyft_logo.jpg"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"facebook" andUrl:@"http://www.underconsideration.com/brandnew/archives/facebook_logo_detail.gif"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"nextdoor" andUrl:@"https://nextdoor.com/static/nextdoorv2/images/newsroom/logo-white-large.png"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"asana" andUrl:@"http://readwrite.com/files/files/files/enterprise/images/asana_logo_0411.png"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"snapchat" andUrl:@"http://upload.wikimedia.org/wikipedia/en/5/5e/Snapchat_logo.png"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"soundcloud" andUrl:@"http://www.bobsima.com/img/Widgets/SoundCloud_Color.png"]];

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
