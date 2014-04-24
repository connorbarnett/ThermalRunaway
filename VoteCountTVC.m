//
//  VoteCountTVC.m
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#include "AFNetworking.h"
#import "VoteCountTVC.h"
#import "VotedCompanies.h"
#import "CompanyProfileVC.h"
#import "HoNManager.h"

@interface VoteCountTVC ()
@property(strong, nonatomic) VotedCompanies *votedCompanies;
@property(strong, nonatomic) NSArray *companiesFromServer;
@property(strong, nonatomic) NSMutableArray *companyVotesFromServer;
@end

@implementation VoteCountTVC
static NSString * const BaseURLString = @"http://localhost:3000/";
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
    [[NSNotificationCenter defaultCenter] addObserverForName:@"obtainedCompanyInfo"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self setDeck];
                                                  }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    HoNManager *myHonManager = [HoNManager sharedHoNManager];
    [myHonManager loadCompanyCards];
}

-(void) setDeck {
    NSLog(@"Setting deck");
    self.companiesFromServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"companyDeck"];
    HoNManager *myHonManager = [HoNManager sharedHoNManager];
    for(NSDictionary *item in  _companiesFromServer){
        NSString *company = [item valueForKey:@"name"];
        [[NSNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"obtainedVoteInfoFor%@",company]
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          [self addVoteCountforCompany:company];
                                                      }];
        [myHonManager loadCompanyVoteCards:company];
    }
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
    NSDictionary *companyInformation = [self.companiesFromServer objectAtIndex:indexPath.row];
    NSArray *companyVoteInfo = [_companyVotesFromServer objectAtIndex:indexPath.row];
    NSString *company = [companyInformation valueForKey:@"name"];
    cell.textLabel.text = company;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ul",[companyVoteInfo count]];
    return cell;
}

- (void) addVoteCountforCompany:(NSString *)companyName{
    NSLog(@"adding vote count for %@", companyName
          );
    NSString *votesKey = [NSString stringWithFormat:@"votesDeckFor%@",companyName];
    NSArray *votes = [[NSUserDefaults standardUserDefaults] valueForKey:votesKey];
    [_companyVotesFromServer addObject:votes];
    
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

#pragma mark - Networking

//- (void) getVoteCount:(UITableViewCell *)cell forCompany:(NSString *)company {
//    
//    NSString *url = [NSString stringWithFormat:@"%@%@",@"http://localhost:3000/vote/lookup.json/?name=",company];
//    NSLog(@"url is %@", url);
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSArray *voteData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[voteData count]];
//        NSLog(@"%@", voteData);
//    }];
//    [dataTask resume];
//}

@end
