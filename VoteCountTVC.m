//
//  VoteCountTVC.m
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "VoteCountTVC.h"
#import "VotedCompanies.h"
#import "CompanyProfileVC.h"

@interface VoteCountTVC ()
@property(strong, nonatomic) VotedCompanies *votedCompanies;
@end

@implementation VoteCountTVC

- (VotedCompanies *)votedCompanies
{
    if(!_votedCompanies) _votedCompanies = [[VotedCompanies alloc] init];
    return _votedCompanies;
}

-(void)setRankedVotedCompanies:(NSMutableArray *)rankedVotedCompanies
{
    _rankedVotedCompanies = rankedVotedCompanies;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.rankedVotedCompanies = [self.votedCompanies retreiveSortedCompanies];
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
    return self.rankedVotedCompanies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Voted Company Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *company = self.rankedVotedCompanies[indexPath.row];
    NSInteger voteCount = [self.votedCompanies retreiveVoteCount:company];
    cell.textLabel.text = company;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)voteCount];
    return cell;
}

#pragma mark - Navigation

- (void)prepareCompanyProfileVC:(CompanyProfileVC *)cpvc toDisplayName:(NSString *)companyName {
    cpvc.company = companyName;
    cpvc.title = companyName;
    NSLog(@"%@", cpvc.company);
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
                    [self prepareCompanyProfileVC:segue.destinationViewController
                                      toDisplayName:self.rankedVotedCompanies[indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - Networking



@end
