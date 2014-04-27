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
@property(strong, nonatomic) HoNManager *myHonManager;
@end

@implementation HoNVC

-(void)awakeFromNib{
    _myHonManager = [HoNManager sharedHoNManager];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"obtainedCurDeckInfo"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self setDeck];
                                                  }];
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
        [self.myHonManager removeTopCompanyFromDeck];
        [toRemove removeFromSuperview];
        if([self.myHonManager deckEmpty])
            [self.myHonManager loadNextDeck];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) setDeck {
    NSLog(@"setting deck");
    self.companiesFromServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"curCompanyDeck"];
    for (NSDictionary *companyCard in _companiesFromServer) {
        NSString *companyName = [companyCard objectForKey:@"name"];
        NSString *companyUrl = [companyCard objectForKey:@"img_url"];
        [self.myHonManager addCompanyToDeck:companyName withUrl:companyUrl];
        [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:companyName andUrl:companyUrl]];
        [self.view setNeedsDisplay];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
