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
/**
 *  The label above the company card that states the company's name
 */
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;

/**
 *  An array of companies to be displayed for voting
 */
@property(strong, nonatomic) NSMutableArray *companiesFromServer;

/**
 *  The label below the company card that confirms your vote on the previous company
 */
@property (weak, nonatomic) IBOutlet UILabel *confirmationLabel;

@property (weak, nonatomic) IBOutlet UIButton *haventHeardButton;

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

/**
 *  Singleton for all networking calls
 */
@property(strong, nonatomic) HoNManager *myHonManager;
@end

@implementation HoNVC

/**
 *  static string for url needed to load images of a companies description
 */
static NSString * const ImgsURLString = @"http://www.stanford.edu/~robdun11/cgi-bin/thermalrunaway/images/texts/";

/**
 *  Lazy instantiation of the networking singleton
 *
 *  @return HoNManager
 */
-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

/**
 *  Loads up a deck of company cards to be voted on and displays the first one
 */
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.haventHeardButton setTitle:@"haven't heard of it" forState:UIControlStateNormal];
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

/**
 *  Gets Google Analytics set up for this view
 *
 *  @param animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    [[GAI sharedInstance] dispatch];
}

/**
 *  Makes the share button fuctional, which allows users to text/email the app to their friends
 *
 *  @param sender
 */
- (IBAction)shareButton:(id)sender {
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"UI"
                                            action:@"buttonPress"
                                             label:@"shareButtonPressed"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];

    
    NSString *text = @"check out thermal runaway, the new way to rate your favorite companies!";
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/thermal-runaway/id874776578?mt=8"];
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

/**
 *  Records an actual vote
 *
 *  @param notification The notification contains a vote type that allows us to determine whether it was a yes or a now
 */
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
    long index = self.view.subviews.count -2;
    if([[self.view.subviews objectAtIndex:index] isKindOfClass:[DraggableView class]]) {
        DraggableView *currCompany = (DraggableView *)[[self.view subviews] objectAtIndex:index];
        self.companyLabel.text = currCompany.company;
    } else {
        self.companyLabel.text = @"";
    }
}

/**
 *  Lazy instantion for the company names from the server
 *
 *  @return companiesFromServer
 */
-(NSMutableArray *)companiesFromServer {
    if(!_companiesFromServer) _companiesFromServer = [[NSMutableArray alloc] init];
    return _companiesFromServer;
}

/**
 *  Method called when "haven't heard of it" or "got it"button is clicked by user.  For the two
 *  cases it does the following:
 *  Case 1: The button display's "havent heard of it:" A view that includes a brief description
 *  and current valuation/worth of the top company card is added to the top of the HoNVC.
 *  Also locks the view, removing a user's ability to swipe companies until the "got it" button is pressed.
 *  Case 2:  The button display's "got it:"  Here the top view that displays a company's
 *  description and valuation/worth is removed from the HoNVC, allowing users to once again vote on companies by swiping.
 *
 *  @param sender the id of the button, for super class
 */
- (IBAction)unheardOf:(id)sender {
    if ([self.haventHeardButton.titleLabel.text isEqualToString:@"got it"]) {
        UIView *toRemove = [[self.view subviews] lastObject];
        [toRemove removeFromSuperview];
        [self.haventHeardButton setTitle:@"haven't heard of it" forState:UIControlStateNormal];
        self.skipButton.hidden = NO;
    } else {
        UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(20, 130, 280, 280)];
        [self.haventHeardButton setTitle:@"got it" forState:UIControlStateNormal];
        self.skipButton.hidden = YES;

        if(![[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@imagetext",self.companyLabel.text]]){
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@text.png",ImgsURLString, self.companyLabel.text]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:imageData];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                    [newView addSubview:imageView];
                    [self.view addSubview:newView];
                });
                [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[NSString stringWithFormat:@"%@imagetext",self.companyLabel.text]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
        }
        else{
            NSData *imageData = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@imagetext",self.companyLabel.text]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [newView addSubview:imageView];
                [self.view addSubview:newView];
            });
        }
    }
}

/**
 *  Skip button allows users to skip on a company if they don't have feels for it.
 *
 *  @param sender
 */
- (IBAction)skip:(id)sender {
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
        [self.myHonManager castVote:@"skip_vote" forCompany:toRemoveTmp.company];
        self.confirmationLabel.text = [NSString stringWithFormat:@"skipped %@", toRemoveTmp.company];
        [self.myHonManager removeTopCompanyFromDeck];
        [toRemove removeFromSuperview];
        if([self.myHonManager deckEmpty])
            [self.myHonManager loadNextDeck];
        else
            [self setCompanyLabel];
                    
    }
}
/**
 *  Sets the company label so that the company's name is above its logo in case you don't recognize its logo
 */
-(void)setCompanyLabel
{
    DraggableView *currCompany = (DraggableView *)[[self.view subviews] lastObject];
    self.companyLabel.text = currCompany.company;
}

/**
 *  Sets the deck of actual cards using the companies pulled from the server.
 */
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
@end
