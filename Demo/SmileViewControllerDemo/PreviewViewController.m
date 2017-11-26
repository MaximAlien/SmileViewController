//
//  PreviewViewController.m
//  SmileViewControllerDemo
//
//  Created by Maxim Makhun on 11/26/17.
//  Copyright © 2017 Maxim Makhun. All rights reserved.
//

#import "PreviewViewController.h"

@implementation PreviewViewController

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Action handlers

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
