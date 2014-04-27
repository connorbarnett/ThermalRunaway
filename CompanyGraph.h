//
//  CompanyGraph.h
//  Thermal
//
//  Created by Connor Barnett on 4/27/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyGraph : UIView

@property(strong, nonatomic) NSArray *votes;
- (id)initWithFrame:(CGRect)frame andVotesArray:(NSArray *)votesArray;


@end
