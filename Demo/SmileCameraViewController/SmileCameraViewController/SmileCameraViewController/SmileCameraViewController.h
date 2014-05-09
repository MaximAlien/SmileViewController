//
//  SmileImageViewController.h
//  SmileCameraViewControllerDemo
//
//  Created by maxim.makhun on 5/9/14.
//  Copyright (c) 2014 MMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CIDetector;

@interface SmileCameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UIDocumentInteractionControllerDelegate>
{
    IBOutlet UIView *previewView;
	AVCaptureVideoPreviewLayer *mPreviewLayer;
	AVCaptureVideoDataOutput *mVideoDataOutput;
	dispatch_queue_t mVideoDataOutputQueue;
	AVCaptureStillImageOutput *mStillImageOutput;
	CIDetector *mFaceDetector;
    UIImage *mTakenPhoto;
}

@property (retain, nonatomic) IBOutlet UIButton *retakePhotoButton;
@property (retain, nonatomic) UIDocumentInteractionController* docController;

- (IBAction)shareViaInstagram:(id)sender;
- (IBAction)shareViaFacebook:(id)sender;
- (IBAction)shareViaTwitter:(id)sender;
- (IBAction)retakeItemPressed:(id)sender;

@end


