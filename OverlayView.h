//
//  OverlayView.h
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger , OverlayViewMode) {
    OverlayViewModeLeft,
    OverlayViewModeRight
};

@interface OverlayView : UIView
@property (nonatomic) OverlayViewMode mode;
@end