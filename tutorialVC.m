//
//  tutorialVC.m
//  Thermal
//
//  Created by Connor Barnett on 6/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "tutorialVC.h"
#import "DraggableView.h"

@interface tutorialVC ()

/**
 *  A button that appears when they've finishd the tutorial so that they can play with the app
 */
@property (weak, nonatomic) IBOutlet UIButton *gotitButton;

@end

@implementation tutorialVC

/**
 *  Loads a company card, hides the "got it" button, and adds an observer so that when they swipe
 *  the company card off screen, they can advane to the app itself
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    DraggableView *dv = [[DraggableView alloc] initNetworkFreeWithFrame:CGRectMake(20, 170, 280, 280) company:@"airbnb"];
    [self.view addSubview:dv];
    self.gotitButton.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"votedOnCompany" object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.gotitButton.hidden = NO;

    }];
}
     
     

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
