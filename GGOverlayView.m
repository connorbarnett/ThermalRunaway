//
//  GGOverlayView.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "GGOverlayView.h"

@interface GGOverlayView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation GGOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down"]];
    [self addSubview:self.imageView];
    
    return self;
}

- (void)setMode:(GGOverlayViewMode)mode
{
    if (_mode == mode) return;
    
    _mode = mode;
    if (mode == GGOverlayViewModeLeft) {
        self.imageView.image = [UIImage imageNamed:@"down"];
    } else {
        self.imageView.image = [UIImage imageNamed:@"up"];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(50, 50, 100, 100);
}

@end
