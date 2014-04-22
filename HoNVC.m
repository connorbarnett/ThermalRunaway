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
    NSLog(@"loading the views now");
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://localhost:3000/companies.json"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       self.companiesFromServer = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary *companyCard in self.companiesFromServer) {
                NSString *companyName = [companyCard objectForKey:@"name"];
                NSString *companyUrl = [companyCard objectForKey:@"img_url"];

                [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:companyName andUrl:companyUrl]];
            }
        });
    }];
    [dataTask resume];
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
