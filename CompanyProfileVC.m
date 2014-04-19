//
//  CompanyProfileVC.m
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "CompanyProfileVC.h"

#define API_KEY "k9dg4qf3knc3vf36y7s29ch5"

@interface CompanyProfileVC ()
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UITextView *unnecessaryJSONText;

@end

@implementation CompanyProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.companyLabel.text = @"JSON!";
    
    NSString *str = [NSString stringWithFormat: @"%s%@", "http://ec2-54-224-194-212.compute-1.amazonaws.com:3000/company/lookup.json/?name=", self.company];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:str] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", json);
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.unnecessaryJSONText.text = [NSString stringWithFormat:@"%@", json];
        });
    }];
    [dataTask resume];
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
