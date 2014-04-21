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
@property(strong, nonatomic) NSArray *companiesFromServer;
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

-(void)awakeFromNib
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://ec2-54-224-194-212.compute-1.amazonaws.com:3000/companies.json"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        self.companiesFromServer = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }];
    [dataTask resume];
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
    return self.companiesFromServer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Voted Company Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSLog(@"%@", self.companiesFromServer);
    NSDictionary *companyInformation = [self.companiesFromServer objectAtIndex:indexPath.row];
    NSString *company = [companyInformation valueForKey:@"name"];
    NSInteger voteCount = [self calculateVotes:companyInformation];
    cell.textLabel.text = company;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)voteCount];
    return cell;
}

- (NSInteger)calculateVotes:(NSDictionary *)companyInformation {
    NSString *upVoteCountStr = (NSString *)[companyInformation valueForKey:@"up_votes"];
    NSInteger upVoteCount = [upVoteCountStr integerValue];
    NSString *downVoteCountStr = (NSString *)[companyInformation valueForKey:@"down_votes"];
    NSInteger downVoteCount = [downVoteCountStr integerValue];
    return upVoteCount - downVoteCount;
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
                    [self prepareCompanyProfileVC:segue.destinationViewController
                                      toDisplayName:self.rankedVotedCompanies[indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - Networking



@end
