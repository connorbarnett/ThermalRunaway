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

#define API_KEY "k9dg4qf3knc3vf36y7s29ch5"
static
@interface CompanyProfileVC ()
@property (weak, nonatomic) NSDictionary *companyInfo;
@property (weak, nonatomic) IBOutlet UIImageView *blurredCompanyImage;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *upLabel;
@property (weak, nonatomic) IBOutlet UILabel *downLabel;
@property (weak, nonatomic) IBOutlet UILabel *unknownLabel;
@property(strong, nonatomic) HoNManager *myHonManager;
@end

@implementation CompanyProfileVC
static NSString * const ImgsURLString = @"http://www.stanford.edu/~robdun11/cgi-bin/thermalrunaway/images/";

-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"obtainedVotesFor%@",self.company]
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateInfo];
                                                  }];
    [self.myHonManager loadVoteTypesForCompany:self.company];
}

-(void)updateInfo{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSLog(@"updating info");
    self.companyInfo = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"voteInfoFor%@",self.company]];
    int numUpVotes = [[self.companyInfo objectForKey:@"up_votes"] intValue];
    int numDownVotes = [[self.companyInfo objectForKey:@"down_votes"] intValue];
    int numUnknownVotes = [[self.companyInfo objectForKey:@"unknown_votes"] intValue];
    self.companyLabel.text = self.company;
    
    self.upLabel.text = [NSString stringWithFormat:@"%d", numUpVotes];
    self.downLabel.text = [NSString stringWithFormat:@"%d", numDownVotes];
    self.unknownLabel.text = [NSString stringWithFormat:@"%d haven't heard of it", numUnknownVotes];
    [self.view addSubview:[[CompanyGraph alloc] initWithFrame:CGRectMake(20, 280, 280, 200) andVotesArray:[self.companyInfo objectForKey:@"trendingArray"]]];
    
    if(![[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@blur",self.company]]){
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@blur.png",ImgsURLString, self.company]];

        NSLog(@"networking");
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];

                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                self.blurredCompanyImage.image = [imageView image];
                
            });
            [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[NSString stringWithFormat:@"%@blur",self.company]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
    else{
        NSLog(@"not networking");
        NSData *imageData = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@blur",self.company]];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.blurredCompanyImage.image = [imageView image];
            
        });
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
