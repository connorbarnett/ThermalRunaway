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


#define API_KEY "k9dg4qf3knc3vf36y7s29ch5"
static
@interface CompanyProfileVC ()
@property (weak, nonatomic) NSDictionary *companyInfo;
@property (weak, nonatomic) IBOutlet UILabel *upLabel;
@property (weak, nonatomic) IBOutlet UILabel *downLabel;
@property (weak, nonatomic) IBOutlet UILabel *unknownLabel;
@property (weak, nonatomic) IBOutlet UILabel *graphLabel;
@property(strong, nonatomic) HoNManager *myHonManager;
@property(strong, atomic) NSArray *rankingArray;
@property(strong, atomic) NSArray *votesArray;
@end

@implementation CompanyProfileVC
static NSString * const ImgsURLString = @"http://www.stanford.edu/~robdun11/cgi-bin/thermalrunaway/images/";

-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGraph:) name:@"graphSwipe" object:nil];
}

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
