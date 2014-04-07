//
//  CompanyView.h
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableView.h"

@interface CompanyView : UIView
- (id)initWithCompany:(NSString *)company;
@property(nonatomic, strong) DraggableView *draggableView;

@end
