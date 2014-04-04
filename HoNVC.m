//
//  HoNVC.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "HoNVC.h"
#import "GGView.h"
#import "GGDraggableView.h"

@interface HoNVC ()

@end

@implementation HoNVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:[[GGDraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) andCompany:@"nest"]];
    [self.view addSubview:[[GGDraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) andCompany:@"lyft"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
