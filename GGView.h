//
//  GGView.h
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGDraggableView.h"

@interface GGView : UIView
- (id)initWithCompany:(NSString *)company;
@property(nonatomic, strong) GGDraggableView *draggableView;

@end
