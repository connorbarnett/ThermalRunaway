//
//  DraggableView.h
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DraggableView : UIView

/**
 *  Company Name
 */
@property(nonatomic, strong) NSString *company;

/**
 *  Bool that helps determine whether or not we need to swap the company out for another company
 */
@property(nonatomic) BOOL changeCompany;

/**
 *  Calls supers init withFrame for the company as provided by second parameter
 *  Also adds gesture recognizers and adds event of card loading, dispatching the event to google analytics
 *
 *  @param frame   frame passed for super class method
 *  @param company name of hte company to have a frame loaded for
 *
 *  @return id of sender
 */
- (id)initWithFrame:(CGRect)frame company:(NSString *)company;

@end
