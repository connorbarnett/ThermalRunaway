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

#define API_KEY "k9dg4qf3knc3vf36y7s29ch5"
static
@interface CompanyProfileVC ()
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UITextView *unnecessaryJSONText;
@property (weak, nonatomic) NSDictionary *companyInfo;
@property(strong, nonatomic) HoNManager *myHonManager;
@end

@implementation CompanyProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    _myHonManager = [HoNManager sharedHoNManager];
    [[NSNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"obtainedVotesFor%@",_company]
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateInfo];
                                                  }];
    [_myHonManager loadVoteTypesForCompany:_company];
}

-(void)updateInfo{
    NSLog(@"updating info");
    _companyInfo = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"voteInfoFor%@",_company]];
    int numUpVotes = [[_companyInfo objectForKey:@"up_votes"] intValue];
    int numDownVotes = [[_companyInfo objectForKey:@"down_votes"] intValue];
    int numUnknownVotes = [[_companyInfo objectForKey:@"unknown_votes"] intValue];
    dispatch_sync(dispatch_get_main_queue(), ^{
        _companyLabel.text = _company;
        _unnecessaryJSONText.text = [NSString stringWithFormat:@"%d Total Votes:\n    %d Up Votes\n    %d Down Votes\n    %d Unknown Votes", numUpVotes + numDownVotes + numUnknownVotes, numUpVotes,numDownVotes,numUnknownVotes];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
