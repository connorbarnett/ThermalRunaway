//
//  GGView.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "GGView.h"
#import "GGDraggableView.h"

@interface GGView ()
@end

@implementation GGView

- (id)initWithCompany:(NSString *)company
{
    self = [super init];
    if (!self) return nil;
    self.backgroundColor = [UIColor whiteColor];
    [self loadDraggableCustomViewWithCompany:company];
    
    return self;
}

- (void)loadDraggableCustomViewWithCompany:(NSString *)company
{
    self.draggableView = [[GGDraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) andCompany:company];
    [self addSubview:self.draggableView];
    
}

@end

