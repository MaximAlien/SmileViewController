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
	AVCaptureVideoPreviewLayer *previewLayer;
	AVCaptureVideoDataOutput *videoDataOutput;
	dispatch_queue_t videoDataOutputQueue;
	AVCaptureStillImageOutput *stillImageOutput;
	CIDetector *faceDetector;
    UIImage *takenPhotoImage;
}

@property (retain, nonatomic) IBOutlet UIButton *retakePhotoButton;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;

- (IBAction)shareViaInstagram:(id)sender;
- (IBAction)shareViaFacebook:(id)sender;
- (IBAction)shareViaTwitter:(id)sender;
- (IBAction)retakePhotoButtonPressed:(id)sender;

@end


