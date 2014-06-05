//
//  VoteCountTVC.h
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteCountTVC : UITableViewController
/**
 *  ranked list of voted companies in order of vote difference
 */
@property(strong, nonatomic) NSMutableArray *rankedVotedCompanies;
@end
