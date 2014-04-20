//
//  HoNVC.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "HoNVC.h"
#import "CompanyView.h"
#import "DraggableView.h"

@interface HoNVC ()
@property(strong, nonatomic) NSArray *companiesFromServer;
@end

@implementation HoNVC
- (IBAction)skip:(id)sender {
    UIView *toRemove = [[self.view subviews] lastObject];
    [toRemove removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self getCompanyDeck:@"http://ec2-54-224-194-212.compute-1.amazonaws.com:3000/companies.json" withResponse:^(NSArray *companiesFromServer){
//        NSLog(@"this runs later, after the post completes");
//        // change the UI to say "The post is done"
//    }];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://ec2-54-224-194-212.compute-1.amazonaws.com:3000/companies.json"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       self.companiesFromServer = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary *companyCard in self.companiesFromServer) {
                NSString *companyName = [companyCard objectForKey:@"name"];
                NSString *companyUrl = [companyCard objectForKey:@"img_url"];

                [self.view addSubview:[[DraggableView alloc] initWithFrame:CGRectMake(20, 130, 200, 260) company:companyName andUrl:companyUrl]];
            }
        });
    }];
    [dataTask resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
