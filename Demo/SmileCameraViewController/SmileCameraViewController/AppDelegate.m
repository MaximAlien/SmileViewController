//
//  AppDelegate.m
//  SmileCameraViewController
//
//  Created by Maxim Makhun on 5/6/14.
//  Copyright (c) 2014 MMA. All rights reserved.
//

#import "AppDelegate.h"
#import "SmileCameraViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SmileCameraViewController *smileCameraViewController = [SmileCameraViewController new];
    self.window.rootViewController = smileCameraViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
