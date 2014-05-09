//
//  ComparisonViewVC.m
//  Thermal
//
//  Created by Connor Barnett on 5/8/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "ComparisonViewVC.h"
#import "HoNManager.h"

@interface ComparisonViewVC ()
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *firstButton;

@property (strong, nonatomic) NSArray* companies;
@property (weak, nonatomic) IBOutlet UILabel *firstCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *topConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomConfirmationLabel;
@property(strong, nonatomic) HoNManager *myHonManager;

@end

@implementation ComparisonViewVC

-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

- (IBAction)touchFirstCompany:(id)sender {
    self.topConfirmationLabel.text = [NSString stringWithFormat:@"voted %@", self.firstCompanyLabel.text];
    self.bottomConfirmationLabel.text = [NSString stringWithFormat:@"over %@", self.secondCompanyLabel.text];
    [self.myHonManager castComparisonForCompany:self.firstCompanyLabel.text overCompany:self.secondCompanyLabel.text];
    [self updateCompanyCards];
}
- (IBAction)touchSecondCard:(id)sender {
    self.topConfirmationLabel.text = [NSString stringWithFormat:@"voted %@", self.secondCompanyLabel.text];
    self.bottomConfirmationLabel.text = [NSString stringWithFormat:@"over %@", self.firstCompanyLabel.text];
    [self.myHonManager castComparisonForCompany:self.secondCompanyLabel.text overCompany:self.firstCompanyLabel.text];
    [self updateCompanyCards];
}

-(void)updateCompanyCards
{
    int firstCompanyIndex = arc4random() % [self.companies count];
    int secondCompanyIndex = arc4random() % [self.companies count];
    while (secondCompanyIndex == firstCompanyIndex) {
        secondCompanyIndex = arc4random() % [self.companies count];
    }
    NSString *firstCompanyStr = [self.companies objectAtIndex:firstCompanyIndex];
    
    NSString *secondCompanyStr = [self.companies objectAtIndex:secondCompanyIndex];
    [self.firstButton setImage:[UIImage imageNamed:firstCompanyStr] forState:UIControlStateNormal];
    self.firstCompanyLabel.text = firstCompanyStr;
    [self.secondButton setImage:[UIImage imageNamed:secondCompanyStr] forState:UIControlStateNormal];
    self.secondCompanyLabel.text = secondCompanyStr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateCompanyCards];
    
}

-(NSArray *)companies
{
    if(!_companies) _companies = [NSArray arrayWithObjects:@"nextdoor", @"facebook", @"soundcloud", @"lyft", @"asana", @"ideo", nil];
    return _companies;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
