//
//  AppDelegate.m
//  SmileViewControllerDemo
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

#import "AppDelegate.h"

// View Controllers
#import "SmileViewController.h"
#import "PreviewViewController.h"

@interface AppDelegate () <SmileViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SmileViewController *smileViewController = [SmileViewController new];
    smileViewController.delegate = self;
    self.window.rootViewController = smileViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)smileDetected:(UIImage *)imageWithSmile {
    PreviewViewController *previewViewController = [PreviewViewController alloc];
    previewViewController.view.backgroundColor = [UIColor blackColor];
    previewViewController.previewImageView.image = imageWithSmile;
    [self.window.rootViewController presentViewController:previewViewController
                                                 animated:YES
                                               completion:nil];
}

@end
