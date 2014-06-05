//
//  ComparisonViewVC.m
//  Thermal
//
//  Created by Connor Barnett on 5/8/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "ComparisonViewVC.h"
#import "HoNManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "HoNVC.h"

@interface ComparisonViewVC ()

/**
 *  UIButton of first company being compared
 */
@property (weak, nonatomic) IBOutlet UIButton *firstButton;

/**
 *  UIButton of second company being compared
 */
@property (weak, nonatomic) IBOutlet UIButton *secondButton;

/**
 *  Array of all companies eligible for a comparison
 */
@property (strong, nonatomic) NSMutableArray* companies;

/**
 *  UILabel for first company being compared
 */
@property (weak, nonatomic) IBOutlet UILabel *firstCompanyLabel;

/**
 *  UILabel for second company being compared
 */
@property (weak, nonatomic) IBOutlet UILabel *secondCompanyLabel;

/**
 *  First half of label that reminds user of a comparison after casting
 */
@property (weak, nonatomic) IBOutlet UILabel *topConfirmationLabel;

/**
 *  Second half of label that reminds user of a comparison after casting
 */
@property (weak, nonatomic) IBOutlet UILabel *bottomConfirmationLabel;

/**
 *  What percentage of the crowd chose what company over the other
 */
@property (weak, nonatomic) IBOutlet UILabel *crowdResultsLabel;

/**
 *  Singleton instance of HoNManager shared across application for all communication with rails server
 */
@property(strong, nonatomic) HoNManager *myHonManager;

@end

@implementation ComparisonViewVC

/**
 *  static string used for uploading images pictures
 */
static NSString * const ImgsURLString = @"http://www.stanford.edu/~robdun11/cgi-bin/thermalrunaway/images/logos/";

-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

/**
 *  calls viewWillAppear of super class and then records a screen view, dispatching to google analytics
 *
 *  @param animated UNUSED, inherited from super class
 */
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Comparison Screen"];
    
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    [[GAI sharedInstance] dispatch];

}

/**
 *  Method called when user hits skip button.
 *  Updates display to say the two companies were skipped
 *  and tells HoNManager to POST skip to rails server
 *
 *  @param sender id of method caller
 */
- (IBAction)comparisonSkipped:(id)sender {
    [self updateCompanyCards];
    self.topConfirmationLabel.text = [NSString stringWithFormat:@"skipped %@", self.firstCompanyLabel.text];
    self.bottomConfirmationLabel.text = [NSString stringWithFormat:@"and %@", self.secondCompanyLabel.text];
    [self.myHonManager castComparisonForCompany:self.firstCompanyLabel.text overCompany:self.secondCompanyLabel.text wasSkip:YES];
    [self.myHonManager loadComparisonPercentageForCompany:self.firstCompanyLabel.text andOtherCompany:self.secondCompanyLabel.text];
    [self reloadIfNeeded];
}

/**
 *  Method called when user chooses the first (left) company to win a comparison.
 *  Updates the display to show result of comparison and tells HoNManager to POST comparison result to rail server
 *
 *  @param sender id of method caller
 */
- (IBAction)firstCardTouched:(id)sender{
    self.topConfirmationLabel.text = [NSString stringWithFormat:@"voted %@", self.firstCompanyLabel.text];
    self.bottomConfirmationLabel.text = [NSString stringWithFormat:@"over %@", self.secondCompanyLabel.text];
    [self.myHonManager castComparisonForCompany:self.firstCompanyLabel.text overCompany:self.secondCompanyLabel.text wasSkip:false];
    [self.myHonManager loadComparisonPercentageForCompany:self.firstCompanyLabel.text andOtherCompany:self.secondCompanyLabel.text];
    [self reloadIfNeeded];

}

/**
 *  Method called when user chooses the second (right) company to win a comparison.
 *  Updates the display to show result of comparison and tells HoNManager to POST comparison result to rail server
 *
 *  @param sender id of method caller
 */
- (IBAction)secondCardTouched:(id)sender {
    self.topConfirmationLabel.text = [NSString stringWithFormat:@"voted %@", self.secondCompanyLabel.text];
    self.bottomConfirmationLabel.text = [NSString stringWithFormat:@"over %@", self.firstCompanyLabel.text];
    [self.myHonManager castComparisonForCompany:self.secondCompanyLabel.text overCompany:self.firstCompanyLabel.text wasSkip:false];
    [self.myHonManager loadComparisonPercentageForCompany:self.firstCompanyLabel.text andOtherCompany:self.secondCompanyLabel.text];
    [self reloadIfNeeded];
}

/**
 *  Method called when the a comparison is made by user.  If not enough companies are left to be compared, 
 *  a notification saying so is posted, and all companies are reloaded for comparisons through the HoNManager.
 *  Otherwise, the display is updated with a new pair of companies to be compared.
 */
- (void) reloadIfNeeded{
    
    if([self.companies count] <= 1){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"comparisons deck empty"
                                                                message:@"sorry, you've compared all available companies, please make comparisons again!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        });
        [self.companies removeAllObjects];
        [self.myHonManager loadComparisonsDeck];
    }
    else
        [self updateCompanyCards];
}

/**
 *  Updates the current set of two company cards being displayed for comparison.  Display update is made by
 *  taking the first two companies in the current array of companies, ie the NSMutableArray companies.
 *  If a user needs to vote on more companies before being allowed to compare, a notification is thrown.
 */
-(void)updateCompanyCards
{
    if([self.companies count] == 0){
        NSArray *curComparisonDeck = [[NSUserDefaults standardUserDefaults] valueForKey:@"curComparisonDeck"];
        if(curComparisonDeck == NULL || [curComparisonDeck count] < 2){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"comparisons deck empty"
                                                                    message:@"sorry, you need to vote on more companies before you can compare! come back after you've compared more companies"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                return;
            });
        }
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

/**
 *  Loads a companies image from the company name param and BaseURLImage listed above.
 *  Pushes that image onto the view in the proper location as determined by the first param.
 *
 *  @param company the name of the company whose image is being loaded
 *  @param first  boolean flag saying whether the company is the first (leftmost) company in the view.  Used only for updating display properly
 */
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

-(void) updatePercentageDisplay{
    NSDictionary *comparisonInformation = [[NSUserDefaults standardUserDefaults] valueForKey:@"latestComparePercentage"];
    
    NSString *winningCompany = [comparisonInformation valueForKey:@"winning_company_name"];
    NSString *losingCompany = [comparisonInformation valueForKey:@"losing_company_name"];
    
    NSNumber *winPercentage = [comparisonInformation valueForKey:@"winPercentage"];

    if([winPercentage.stringValue isEqual: @"-1"])
            self.crowdResultsLabel.text = [NSString stringWithFormat:@"these companies don't have comparisons yet"];
    else if([winPercentage.stringValue isEqual: @"-2"]){
            self.crowdResultsLabel.text = [NSString stringWithFormat:@"50%% of the crowd chose both %@ and %@", winningCompany, losingCompany];
    }
    else{
        winPercentage = [NSNumber numberWithFloat:[winPercentage floatValue] * 100];
        if([[winPercentage stringValue] length] >=4)
            self.crowdResultsLabel.text = [NSString stringWithFormat:@"%@%% of the crowd chose %@ over %@", [[winPercentage stringValue] substringToIndex:4], winningCompany, losingCompany];
        else
            self.crowdResultsLabel.text = [NSString stringWithFormat:@"%@%% of the crowd chose %@ over %@", [winPercentage stringValue], winningCompany, losingCompany];
    }
}

/**
 *  Calls super class's viewDidLoad and sets a notification listener to load comparisonDeckInfo from NSUserDefaults
 *  after the HoNManager has received the proper information from rails server and stored it in NSUserDefaults.
 *  Also sets a notification listener that will update the display with the proper percentage of comparisons won
 *  between two companies after a user compares two companies
 *  Lastly calls the HoNManager's method for loading the proper information into NSUserDefaults.  Used because of 
 * networking calls working off of main thread.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"obtainedCurComparisonDeckInfo"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateCompanyCards];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"obtainedLatestComparisonsPercentage"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updatePercentageDisplay];
                                                  }];

    [self.myHonManager loadComparisonsDeck];
}

/**
 *  Lazy instantation of companies array
 *
 *  @return the instantiated array
 */
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
@end
