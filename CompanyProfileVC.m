//
//  CompanyProfileVC.m
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "AFNetworking.h"
#import "CompanyProfileVC.h"
#import "HoNManager.h"
#import "CompanyGraph.h"
#import "MBProgressHUD.h"
#import "GraphView.h"
#import "DraggableGraphView.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


#define API_KEY "k9dg4qf3knc3vf36y7s29ch5"
static
@interface CompanyProfileVC ()
/**
 *  Company's information including its name, its votes, and its rankings
 */
@property (weak, nonatomic) NSDictionary *companyInfo;

/**
 *  Company's comparisons information, including all compares won and lost
 *  As well as the opposing company
 */
@property (weak, nonatomic) NSDictionary *companyComparisonInfo;

/**
 *  Label displaying number of upvotes
 */
@property (weak, nonatomic) IBOutlet UILabel *upLabel;

/**
 *  Label displaying number of downvotes
 */
@property (weak, nonatomic) IBOutlet UILabel *downLabel;

/**
 *  Label displaying the number of people who haven't heard of the company
 */
@property (weak, nonatomic) IBOutlet UILabel *unknownLabel;

/**
 *  Label displaying whether we are looking at the rankings graph or the voting graph
 */
@property (weak, nonatomic) IBOutlet UILabel *graphLabel;

/**
 *  Singleton for networking
 */
@property(strong, nonatomic) HoNManager *myHonManager;

/**
 *  Array containing rankings over the last six days
 */
@property(strong, atomic) NSArray *rankingArray;

/**
 *  Array containing vote counts over the last six days
 */
@property(strong, atomic) NSArray *votesArray;
@end

@implementation CompanyProfileVC
static NSString * const ImgsURLString = @"http://www.stanford.edu/~robdun11/cgi-bin/thermalrunaway/images/";

/**
 *  Lazy instantiation for the singleton
 *
 *  @return HoNManager
 */
-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

/**
 *  Adds an observer to determine that the graph needs to be swapped out in favor of the other graph
 */
-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGraph:) name:@"graphSwipe" object:nil];
}

/**
 *  Swaps one graph out for another graph based on the notification object
 *
 *  @param notification The object that determines what graph should be displayed
 */
- (void) changeGraph:(NSNotification *)notification{
    NSNumber *graphType = [notification object];
    if([graphType integerValue] == 1) {
        [self.view addSubview:[[DraggableGraphView alloc] initWithFrame:CGRectMake(20, 240, 300, 240) andGraphType:@"rankings" andData:self.rankingArray]];
        self.graphLabel.text = @"rankings graph";
        
    } else {
        [self.view addSubview:[[DraggableGraphView alloc] initWithFrame:CGRectMake(20, 240, 300, 240) andGraphType:@"votes" andData:self.votesArray]];
        self.graphLabel.text = @"votes graph";

        
    }
}

/**
 *  Loads the data for the company and gives them an alert if they've never seen this page before
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"obtainedComparisonsFor%@",self.company]
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateCopmarisonInfo];
                                                  }];
    [self.myHonManager loadComparisonInfoForCompany:self.company];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"obtainedVotesFor%@",self.company]
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateInfo];
                                                  }];
    [self.myHonManager loadVoteTypesForCompany:self.company];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasViewedProfileOnce"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasViewedProfileOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"welcome to company profile page!"
                                                                message:@"here you can view a company's rating over time and swipe long to see their votes across time"
                                                               delegate:nil
                                                      cancelButtonTitle:@"got it"
                                                      otherButtonTitles:nil];
            [alertView show];
        });
    }
}

/**
 *  Google Analtyics code
 *
 *  @param animated
 */
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"Company Screen For %@", self.company]];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    [[GAI sharedInstance] dispatch];
}

/**
 *  Sets all the labels appropriately when the view loads (thus, called in viewDidLoad)
 */
-(void)updateInfo{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    self.companyInfo = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"voteInfoFor%@",self.company]];
    int numUpVotes = [[self.companyInfo objectForKey:@"up_votes"] intValue];
    int numDownVotes = [[self.companyInfo objectForKey:@"down_votes"] intValue];
    int numUnknownVotes = [[self.companyInfo objectForKey:@"unknown_votes"] intValue];
    
    self.upLabel.text = [NSString stringWithFormat:@"%d", numUpVotes];
    self.downLabel.text = [NSString stringWithFormat:@"%d", numDownVotes];
    self.unknownLabel.text = [NSString stringWithFormat:@"%d haven't heard of it", numUnknownVotes];
    
    self.votesArray = [self.companyInfo objectForKey:@"trendingArray"];
    self.rankingArray = [self.companyInfo objectForKey:@"rankingArray"];
    
    [self.view addSubview:[[DraggableGraphView alloc] initWithFrame:CGRectMake(20, 240, 300, 240) andGraphType:@"rankings" andData:self.rankingArray]];
    
    if(![[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@blur",self.company]]){
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@blur.png",ImgsURLString, self.company]];
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            });
            [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[NSString stringWithFormat:@"%@blur",self.company]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
    else{
        NSData *imageData = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@blur",self.company]];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        });
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/**
 *  Sets labels for displaying company's results during comparisons
 */
-(void)updateComparisonInfo{
    self.companyComparisonInfo = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"compareInfoFor%@",self.company]];
    //TODO: Add to comparison info to display
}

@end
