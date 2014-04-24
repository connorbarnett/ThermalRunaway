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

@property(strong, nonatomic) NSMutableArray *companiesFromServer;
@end

@implementation HoNVC

-(void)awakeFromNib{
    HoNManager *myHonManager = [HoNManager sharedHoNManager];
<<<<<<< HEAD
    //    //[myHonManager clearUserDefaults];
//    [myHonManager loadCompanyCards];
=======
    [[NSNotificationCenter defaultCenter] addObserverForName:@"obtainedCompanyInfo"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self setDeck];
                                                  }];

    [myHonManager loadCompanyCards];
>>>>>>> 07f2796224948e11c6329225d88e44edf436cc4a
}

-(NSMutableArray *)companiesFromServer {
    if(!_companiesFromServer) _companiesFromServer = [[NSMutableArray alloc] init];
    return _companiesFromServer;
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
    for (NSDictionary *companyCard in self.companiesFromServer) {
        NSString *companyName = [companyCard objectForKey:@"name"];
        NSString *companyUrl = [companyCard objectForKey:@"img_url"];
        [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:companyName andUrl:companyUrl]];
    }
}

-(void) setDeck {
    self.companiesFromServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"companyDeck"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
