//
//  CompanyView.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "CompanyView.h"
#import "DraggableView.h"

@interface CompanyView ()
@end

@implementation CompanyView

/**
 *  The actual company views that get swiped for the voting
 *
 *  @param company the name of a company for which the card will be created around
 *
 *  @return CompanyView
 */
- (id)initWithCompany:(NSString *)company
{
    self = [super init];
    if (!self) return nil;
    self.backgroundColor = [UIColor whiteColor];
    [self loadDraggableCustomViewWithCompany:company];
    
    return self;
}

/**
 *  Utility method for making the views draggable when initialized
 *
 *  @param company the name of the company for which the card will be created around
 */

- (void)loadDraggableCustomViewWithCompany:(NSString *)company
{
    self.draggableView = [[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:company];
    [self addSubview:self.draggableView];
    
}

@end

