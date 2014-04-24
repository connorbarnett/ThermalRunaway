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

@property(strong, nonatomic) NSArray *companiesFromServer;
@end

@implementation HoNVC

-(void)awakeFromNib{
    HoNManager *myHonManager = [HoNManager sharedHoNManager];
    //    //[myHonManager clearUserDefaults];
//    [myHonManager loadCompanyCards];
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



@end
