//
//  HoNAppDelegate.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "HoNAppDelegate.h"
#import "HoNManager.h"
#import "GAIDictionaryBuilder.h"

static NSString *const kTrackingId = @"UA-50962137-1";
static NSString *const kAllowTracking = @"allowTracking";

@implementation HoNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    [GAI sharedInstance].dispatchInterval = 20;
    
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    
    [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    self.tracker = [[GAI sharedInstance] trackerWithName:@"Thermal Runaway"
                                              trackingId:kTrackingId];

    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"status"
                                            action:@"finishLaunch"
                                             label:@"finishLaunch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        UIViewController *rvc = [storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
        self.window.rootViewController = rvc;
        [self.window makeKeyAndVisible];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    HoNManager *myHonManager = [HoNManager sharedHoNManager];
    [myHonManager loadAllCompanyCards];
    [myHonManager startLocationServices];
    [myHonManager resetPageCount];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"status"
                                            action:@"becomingInactive"
                                             label:@"becomingInactive"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"status"
                                            action:@"enteringBackground"
                                             label:@"enteringBackground"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"status"
                                            action:@"enteringForeground"
                                             label:@"enteringForeground"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"status"
                                            action:@"becomingActive"
                                             label:@"becomingActive"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"status"
                                            action:@"terminating"
                                             label:@"terminating"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
