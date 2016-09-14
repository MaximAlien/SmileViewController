//
//  AppDelegate.m
//  SmileViewControllerDemo
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

#import "AppDelegate.h"
#import "SmileViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SmileViewController *smileCameraViewController = [SmileViewController new];
    self.window.rootViewController = smileCameraViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
