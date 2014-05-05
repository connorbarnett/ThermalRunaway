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
#import "MBProgressHUD.h"

@interface VoteCountTVC ()
@property (strong, nonatomic) IBOutlet UITableView *reloadWheel;
@property(strong, nonatomic) NSArray *companiesFromServer;
@property(strong, nonatomic) NSMutableArray *companyVotesFromServer;
@property(strong, nonatomic) HoNManager *myHonManager;
@property BOOL pageHasAppeared;
@end

@implementation VoteCountTVC

-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.myHonManager loadAllCompanyCards];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) setTableDeck {
    self.companiesFromServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"allCompanyInfo"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView reloadData];
    });
}

- (IBAction)refresh:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.myHonManager loadAllCompanyCards];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.companiesFromServer.count;
}

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

- (void)prepareCompanyProfileVC:(CompanyProfileVC *)cpvc toDisplayName:(NSString *)companyName {
    cpvc.company = companyName;
    cpvc.title = companyName;
}

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
