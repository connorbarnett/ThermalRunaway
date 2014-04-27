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

@interface VoteCountTVC ()
@property(strong, nonatomic) NSArray *companiesFromServer;
@property(strong, nonatomic) NSMutableArray *companyVotesFromServer;
@end

@implementation VoteCountTVC

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"allCompanyDataLoaded"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self setTableDeck];
                                                  }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) setTableDeck {
    NSLog(@"setting table deck");
    self.companiesFromServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"allCompanyInfo"];
    NSLog(@"%lu",(unsigned long)[self.companiesFromServer count]);
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
        cell.detailTextLabel.text = [NSString stringWithFormat:@"-%d",netTotal];
        UIColor *color = [UIColor redColor];
        [cell.detailTextLabel setTextColor:color];
    }
    return cell;
}

#pragma mark - Navigation

- (void)prepareCompanyProfileVC:(CompanyProfileVC *)cpvc toDisplayName:(NSString *)companyName {
    cpvc.company = companyName;
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
