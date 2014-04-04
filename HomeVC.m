//
//  HomeVC.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "HomeVC.h"

@interface HomeVC ()
@property (nonatomic) CGFloat startingHeightValue;
@property (nonatomic) CGRect originalFrame;
@property (weak, nonatomic) IBOutlet UIButton *signinbutton;
@end

@implementation HomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(theKeyboardAppeared:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(theKeyboardHid:)
                                                 name:UIKeyboardDidHideNotification
                                               object:self.view.window];
    
}

- (void)viewDidLayoutSubviews {
    self.originalFrame = self.view.frame;
}

-(void)theKeyboardAppeared:(NSNotification *)notification {
    self.startingHeightValue = self.view.frame.origin.y;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat newBoundsY = self.view.frame.origin.y - keyboardSize.height + self.tabBarController.tabBar.frame.size.height;
    CGPoint newPoint;
    newPoint.x = self.originalFrame.origin.x;
    newPoint.y = newBoundsY;
    CGRect frame = self.view.frame;
    frame.origin = newPoint;
    [UIView animateWithDuration:0.2 animations:^{self.view.frame = frame;}];
}

- (void) theKeyboardHid:(NSNotification *)notification {
    [UIView animateWithDuration:0.05 animations:^{
        self.view.frame = CGRectMake(0, self.startingHeightValue, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
