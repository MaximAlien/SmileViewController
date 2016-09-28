//
//  SmileImageViewController.h
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import UIKit;
@import AVFoundation;

@class CIDetector;

@interface SmileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *retakePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *shareViaTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *shareViaFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *shareViaInstagramButton;

@end


