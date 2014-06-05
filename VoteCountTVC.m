//
//  VoteCountTVC.m
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#include "AFNetworking.h"
#import "VoteCountTVC.h"
#import "CompanyProfileVC.h"
#import "HoNManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "MBProgressHUD.h"
#import "GAIDictionaryBuilder.h"


@interface VoteCountTVC ()
/**
 *  Provides visual feedback to the user that we are doing a networking call and data is not yet available
 */
@property (strong, nonatomic) IBOutlet UITableView *reloadWheel;

/**
 *  The company names from our server
 */
@property(strong, nonatomic) NSArray *companiesFromServer;

/**
 *  The company's corresponding net vote count from our server
 */
@property(strong, nonatomic) NSMutableArray *companyVotesFromServer;

/**
 *  Singleton for our networking
 */
@property(strong, nonatomic) HoNManager *myHonManager;

/**
 *  Self explanatory bool
 */
@property BOOL pageHasAppeared;
@end

@implementation VoteCountTVC

/**
 *  Lazy instantion for our networking singleton
 *
 *  @return HoNManager
 */
-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

/**
 *  This is done to ensure that we don't try to create the table before our networking has completed
 *  (We need to pull the companies and their rankings from our server first)
 */
-(void)awakeFromNib
{
    self.pageHasAppeared = false;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"allCompanyDataLoaded"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self setTableDeck];
                                                  }];
}

/**
 *  Gets Google Analytics going and uses the singleton to load the company cards
 *
 *  @param animated
 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.myHonManager loadAllCompanyCards];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Table View Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    [[GAI sharedInstance] dispatch];

}

/**
 *  Sets the company deck to contain all the companies
 */
-(void) setTableDeck {
    self.companiesFromServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"allCompanyInfo"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView reloadData];
    });
}

/**
 *  Allows the user to refresh the table view, as it changes all the time
 *
 *  @param sender
 */
- (IBAction)refresh:(id)sender {
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"UI"
                                            action:@"buttonPress"
                                             label:@"dispatchRefresh"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.myHonManager loadAllCompanyCards];
}

#pragma mark - Table view data source
/**
 *  Standard TableView method that says how many sections we will have
 *
 *  @param tableView
 *
 *  @return number of sections
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/**
 *  Standard TableView method that says how many companies we will have in the table
 *
 *  @param tableView
 *  @param section
 *
 *  @return number of companies to go in our table view
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.companiesFromServer.count;
}

/**
 *  Figures out the information to be displayed at an individaul cell
 *
 *  @param tableView
 *  @param indexPath The cell's index in the table
 *
 *  @return A constructed cell for the table
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Voted Company Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont fontWithName:@"DIN Alternate" size:17];

    NSDictionary *companyInformation = [self.companiesFromServer objectAtIndex:indexPath.row];
    NSString *company = [companyInformation valueForKey:@"name"];
    int netTotal = [[companyInformation objectForKey:@"netTotal"] intValue];
    cell.textLabel.text = company;
    if(netTotal > 0){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+%d",netTotal];
        UIColor *color = [UIColor greenColor];
        [cell.detailTextLabel setTextColor:color];
    }
    else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",netTotal];
        if(netTotal < 0){
            UIColor *color = [UIColor redColor];
            [cell.detailTextLabel setTextColor:color];
        }
    }
    return cell;
}

#pragma mark - Navigation
/**
 *  Prepares a CompanyProfileVC, which will display more information about the cell that is touched
 *
 *  @param cpvc        CompanyProfileVC to segue to
 *  @param companyName The company that we will be displaying on the CompanyProfileVC
 */
- (void)prepareCompanyProfileVC:(CompanyProfileVC *)cpvc toDisplayName:(NSString *)companyName {
    cpvc.company = companyName;
    cpvc.title = companyName;
}

/**
 *  Preps us to segue to the CompanyProfileVC
 *
 *  @param segue  StoryboardSegue that will take us to the CompanyProfileVC
 *  @param sender The cell that was touched
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            // found it ... are we doing the Display Photo segue?
            if ([segue.identifier isEqualToString:@"detail"]) {
                // yes ... is the destination an ImageViewController?
                if ([segue.destinationViewController isKindOfClass:[CompanyProfileVC class]]) {
                    // yes ... then we know how to prepare for that segue!
                    NSDictionary *companyInformation = [self.companiesFromServer objectAtIndex:indexPath.row];
                    [self prepareCompanyProfileVC:segue.destinationViewController
                                    toDisplayName:[companyInformation valueForKey:@"name"]
                     ];
                }
            }
        }
    }
}

@end
