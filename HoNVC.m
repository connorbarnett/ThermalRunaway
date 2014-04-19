//
//  HoNVC.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "HoNVC.h"
#import "CompanyView.h"
#import "DraggableView.h"

@interface HoNVC ()

@end

@implementation HoNVC
- (IBAction)skip:(id)sender {
    UIView *toRemove = [[self.view subviews] lastObject];
    [toRemove removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"nest" andUrl:@"http://www.technewsworld.com/images/rw734591/home-energy-consumption.jpg"]];
    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"Lyft" andUrl:@"http://upload.wikimedia.org/wikipedia/commons/4/48/Lyft_logo.jpg"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"facebook" andUrl:@"http://www.underconsideration.com/brandnew/archives/facebook_logo_detail.gif"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"nextdoor" andUrl:@"https://nextdoor.com/static/nextdoorv2/images/newsroom/logo-white-large.png"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"asana" andUrl:@"http://readwrite.com/files/files/files/enterprise/images/asana_logo_0411.png"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"snapchat" andUrl:@"http://upload.wikimedia.org/wikipedia/en/5/5e/Snapchat_logo.png"]];
//    [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:@"soundcloud" andUrl:@"http://www.bobsima.com/img/Widgets/SoundCloud_Color.png"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
