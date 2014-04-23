//
//  HoNManager.m
//  Thermal
//
//  Created by Robert Dunlevie on 4/22/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#include "AFNetworking.h"
#import "HoNManager.h"

@implementation HoNManager

//Needs to change to ec2 eventually
static NSString * const BaseURLString = @"http://localhost:3000/";

+ (id)sharedHoNManager {
    static HoNManager *sharedHoNManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHoNManager = [[self alloc] init];
    });
    return sharedHoNManager;
}

- (void)loadCompanyCards {
    NSLog(@"loading cards");
    if(![[NSUserDefaults standardUserDefaults] valueForKey:@"companyDeck"]){
        NSLog(@"preparing to make a network call");
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://localhost:3000/companies.json"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] forKey:@"companyDeck"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    [dataTask resume];
    }
}

-(void)loadCompanyVoteCards:(NSString *) companyName{
    NSString *votesKey = [NSString stringWithFormat:@"votesDeckFor%@",companyName];
    if(![[NSUserDefaults standardUserDefaults] valueForKey:votesKey]){
        NSString *urlString = [NSString stringWithFormat:@"http://localhost:3000/vote/lookup.json/?name=%@",companyName];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] forKey:votesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    [dataTask resume];
    }
}

- (void)castVote:(NSString *)vote_type forCompany:(NSString *)company andLocation:(NSString *)loc{
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    NSDictionary *parameters = @{@"vote_type": vote_type, @"name" : company, @"vote_location" : loc};
    
    // 2
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"vote.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Made succesful POST Request");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

-(void)clearUserDefaults{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init {
    self = [super init];
    return self;
}

@end
