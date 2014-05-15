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
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface HoNVC ()  <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property(strong, nonatomic) NSMutableArray *companiesFromServer;
@property (weak, nonatomic) IBOutlet UILabel *confirmationLabel;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingVote:) name:@"votedOnCompany" object:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if([self.myHonManager deckEmpty]){
        [self.myHonManager loadDeck];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:kGAIScreenName value:@"Home Screen"];
    
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    [[GAI sharedInstance] dispatch];

}
- (IBAction)shareButton:(id)sender {
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"UI"
                                            action:@"buttonPress"
                                             label:@"shareButtonPressed"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];

    
    NSString *text = @"check out thermal runaway, the new way to rate your favorite companies!";
    NSURL *url = [NSURL URLWithString:@"http://stanford.edu/~connorb/cgi-bin/home/"];
    UIImage *image = [UIImage imageNamed:@"logo"];

    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url, image]
     applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) incomingVote:(NSNotification *)notification{
    NSDictionary *companyInfo = [notification object];
    NSString *voteType = [companyInfo objectForKey:@"voteType"];
    NSString *voteTypeForConfirmationLabel;
    if([voteType isEqualToString:@"up_vote"]) {
        voteTypeForConfirmationLabel = @"yes";
    } else {
        voteTypeForConfirmationLabel = @"no";
    }
    self.confirmationLabel.text = [NSString stringWithFormat:@"voted %@ on %@", voteTypeForConfirmationLabel, [companyInfo objectForKey:@"company"]];
//    DraggableView *currCompany = (DraggableView *)[[self.view subviews] lastObject];
    long index = self.view.subviews.count -2;
    if([[self.view.subviews objectAtIndex:index] isKindOfClass:[DraggableView class]]) {
        DraggableView *currCompany = (DraggableView *)[[self.view subviews] objectAtIndex:index];
        self.companyLabel.text = currCompany.company;
    } else {
        self.companyLabel.text = @"";
    }
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"company deck empty"
                                                            message:@"sorry, there are no more companies for you to vote on!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [self.myHonManager castVote:@"unknown_vote" forCompany:toRemoveTmp.company];
        self.confirmationLabel.text = [NSString stringWithFormat:@"skipped %@", toRemoveTmp.company];
        [toRemove removeFromSuperview];
        [self.myHonManager removeTopCompanyFromDeck];
        if([self.myHonManager deckEmpty])
            [self.myHonManager loadNextDeck];
        if(![self.myHonManager deckEmpty]) {
            [self setCompanyLabel];
        }
    }
}
-(void)setCompanyLabel
{
    DraggableView *currCompany = (DraggableView *)[[self.view subviews] lastObject];
    self.companyLabel.text = currCompany.company;
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
        [self setCompanyLabel];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
