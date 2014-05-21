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

@property (strong, nonatomic) NSMutableArray* companies;
@property (weak, nonatomic) IBOutlet UILabel *firstCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *topConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomConfirmationLabel;
@property(strong, nonatomic) HoNManager *myHonManager;

@end

@implementation ComparisonViewVC
static NSString * const ImgsURLString = @"http://www.stanford.edu/~robdun11/cgi-bin/thermalrunaway/images/";

-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

- (IBAction)comparisonSkipped:(id)sender {
    [self updateCompanyCards];
    self.topConfirmationLabel.text = [NSString stringWithFormat:@"skipped %@", self.firstCompanyLabel.text];
    self.bottomConfirmationLabel.text = [NSString stringWithFormat:@"and %@", self.secondCompanyLabel.text];
}

- (IBAction)firstCardTouched:(id)sender{
    self.topConfirmationLabel.text = [NSString stringWithFormat:@"voted %@", self.firstCompanyLabel.text];
    self.bottomConfirmationLabel.text = [NSString stringWithFormat:@"over %@", self.secondCompanyLabel.text];
    [self.myHonManager castComparisonForCompany:self.firstCompanyLabel.text overCompany:self.secondCompanyLabel.text];
    [self updateCompanyCards];
}

- (IBAction)secondCardTouched:(id)sender {
    self.topConfirmationLabel.text = [NSString stringWithFormat:@"voted %@", self.secondCompanyLabel.text];
    self.bottomConfirmationLabel.text = [NSString stringWithFormat:@"over %@", self.firstCompanyLabel.text];
    [self.myHonManager castComparisonForCompany:self.secondCompanyLabel.text overCompany:self.firstCompanyLabel.text];
    [self updateCompanyCards];
}

-(void)updateCompanyCards
{
    if([self.companies count] == 0){
        NSArray *curComparisonDeck = [[NSUserDefaults standardUserDefaults] valueForKey:@"curComparisonDeck"];
        for (NSDictionary *companyCard in curComparisonDeck) {
            NSString *companyName = [companyCard objectForKey:@"name"];
            [self.companies addObject:companyName];
        }
    }

    int firstCompanyIndex = arc4random() % [self.companies count];
    int secondCompanyIndex = arc4random() % [self.companies count];
    while (secondCompanyIndex == firstCompanyIndex) {
        secondCompanyIndex = arc4random() % [self.companies count];
    }
    NSString *firstCompanyStr = [self.companies objectAtIndex:firstCompanyIndex];
    
    NSString *secondCompanyStr = [self.companies objectAtIndex:secondCompanyIndex];

    [self loadImageDataForCompany:firstCompanyStr andSide:YES];
    [self loadImageDataForCompany:secondCompanyStr andSide:NO];
}

- (void)loadImageDataForCompany:(NSString *) company andSide:(BOOL)first{
    if(![[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@compareimage",company]]){
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png",ImgsURLString, company]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                if(first){
                    NSLog(@"logging");
                    [self.firstButton setImage:image forState:UIControlStateNormal];
                    self.firstCompanyLabel.text = company;
                }
                else{
                    [self.secondButton setImage:image forState:UIControlStateNormal];
                    self.secondCompanyLabel.text = company;
                }
            });
            [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[NSString stringWithFormat:@"%@compareimage",company]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *imageData = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@compareimage",company]];
            UIImage *image = [UIImage imageWithData:imageData];
            if(first){
                [self.firstButton setImage:image forState:UIControlStateNormal];
                self.firstCompanyLabel.text = company;
            }
            else{
                [self.secondButton setImage:image forState:UIControlStateNormal];
                self.secondCompanyLabel.text = company;
            }
        });
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"obtainedCurComparisonDeckInfo"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateCompanyCards];
                                                  }];
    [self.myHonManager loadComparisonsDeck];
}

-(NSMutableArray *)companies
{
    if(!_companies) _companies = [[NSMutableArray alloc] init];
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
