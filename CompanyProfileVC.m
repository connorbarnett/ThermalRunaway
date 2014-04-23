//
//  CompanyProfileVC.m
//  Thermal
//
//  Created by Connor Barnett on 4/6/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "AFNetworking.h"
#import "CompanyProfileVC.h"

#define API_KEY "k9dg4qf3knc3vf36y7s29ch5"

static NSString * const BaseURLString = @"http://localhost:3000/";

@interface CompanyProfileVC ()
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UITextView *unnecessaryJSONText;

@end

@implementation CompanyProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.companyLabel.text = self.company;

    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    NSDictionary *parameters = @{@"name" : self.company};
    
    // 2
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
<<<<<<< HEAD
    // 3
    [manager GET:@"company/lookup.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        self.unnecessaryJSONText.text = [(NSDictionary *)responseObject valueForKey:@"name"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
=======
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:str] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.unnecessaryJSONText.text = [NSString stringWithFormat:@"There are currently %lu votes for %@", (unsigned long)json.count, self.company];
        });
    }];
    [dataTask resume];
>>>>>>> ffa2e26d5d455ed6e09232fa1f04625456c895c7
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
