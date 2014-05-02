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
#import "MBProgressHUD.h"

@interface HoNVC ()  <CLLocationManagerDelegate>

@property(strong, nonatomic) NSMutableArray *companiesFromServer;
@property(strong, nonatomic) HoNManager *myHonManager;
@end

@implementation HoNVC

-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"obtainedCurDeckInfo"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self setDeck];

                                                  }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(NSMutableArray *)companiesFromServer {
    if(!_companiesFromServer) _companiesFromServer = [[NSMutableArray alloc] init];
    return _companiesFromServer;
}

- (IBAction)skip:(id)sender
{
    UIView *toRemove = [[self.view subviews] lastObject];
    DraggableView *toRemoveTmp = (DraggableView *)toRemove;

    if([self.myHonManager deckEmpty]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Company Deck Empty"
                                                            message:@"Sorry, there are no more companies for you to vote on!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [self.myHonManager castVote:@"unknown_vote" forCompany:toRemoveTmp.company];
        [toRemove removeFromSuperview];
        [self.myHonManager removeTopCompanyFromDeck];
        if([self.myHonManager deckEmpty])
            [self.myHonManager loadNextDeck];
    }
}

-(void) setDeck {
    self.companiesFromServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"curCompanyDeck"];
    NSMutableArray *curDeck = [[NSMutableArray alloc] init];
    for (NSDictionary *companyCard in _companiesFromServer) {
        NSString *companyName = [companyCard objectForKey:@"name"];
        [self.myHonManager addCompanyToDeck:companyName];
        [curDeck addObject:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 300, 300) company:companyName]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for(UIView *view in curDeck){
            [self.view addSubview:view];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
