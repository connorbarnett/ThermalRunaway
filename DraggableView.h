//
//  DraggableView.h
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DraggableView : UIView
@property(nonatomic, strong) NSString *company;
@property(nonatomic) BOOL changeCompany;
- (id)initWithFrame:(CGRect)frame andCompany:(NSString *)company;

@end
