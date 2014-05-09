//
//  MMAAppDelegate.m
//  SmileCameraViewController
//
//  Created by maxim.makhun on 5/6/14.
//  Copyright (c) 2014 MMA. All rights reserved.
//

#import "MMAAppDelegate.h"

@implementation MMAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.smileCameraViewController = [[SmileCameraViewController alloc] initWithNibName:@"SmileCameraViewController" bundle:nil];
    self.window.rootViewController = self.smileCameraViewController;

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
