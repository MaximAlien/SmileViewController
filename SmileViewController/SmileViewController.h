//
//  SmileImageViewController.h
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import UIKit;

@protocol SmileViewControllerDelegate

- (void)smileDetected:(UIImage *)imageWithSmile;

@end

@interface SmileViewController : UIViewController

@property (nonatomic, assign) id<SmileViewControllerDelegate> delegate;

@end
