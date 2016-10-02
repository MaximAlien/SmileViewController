//
//  SmileImageViewController.m
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import Social;

#import "SmileViewController.h"

// Categories
#import "UIImage+Additions.h"
#import "UIAlertController+Utilities.h"

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

@interface SmileViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (strong, nonatomic) UIImage *takenPhotoImage;

@property (weak, nonatomic) IBOutlet UIView *previewView;

- (IBAction)shareViaInstagram:(id)sender;
- (IBAction)shareViaFacebook:(id)sender;
- (IBAction)shareViaTwitter:(id)sender;
- (IBAction)retakePhotoButtonPressed:(id)sender;

@end

@implementation SmileViewController

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCaptureDeviceInput];
    [self setupCaptureStillImageOutput];
    [self setupCaptureVideoDataOutput];
    [self setupCaptureVideoPreviewLayer];
    [self setupCaptureDevice];
    [self styleSharingButtons];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.captureVideoPreviewLayer setFrame:self.previewView.layer.frame];
}

#pragma mark - Setting up methods

+ (AVCaptureSession *)sharedSession {
    static AVCaptureSession *sharedSession;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSession = [AVCaptureSession new];
        sharedSession.sessionPreset = AVCaptureSessionPreset640x480;
    });
    
    return sharedSession;
}

- (void)setupCaptureDeviceInput {
    NSError *error = nil;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ([[SmileViewController sharedSession] canAddInput:deviceInput]) {
        [[SmileViewController sharedSession] addInput:deviceInput];
    }
}

- (void)setupCaptureStillImageOutput {
    AVCaptureStillImageOutput *captureStillImageOutput = [AVCaptureStillImageOutput new];
    if ([[SmileViewController sharedSession] canAddOutput:captureStillImageOutput]) {
        [[SmileViewController sharedSession] addOutput:captureStillImageOutput];
    }
}

- (void)setupCaptureVideoDataOutput {
    AVCaptureVideoDataOutput *captureVideoDataOutput = [AVCaptureVideoDataOutput new];
    
    NSDictionary *videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCMPixelFormat_32BGRA]};
    [captureVideoDataOutput setVideoSettings:videoSettings];
    [captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [captureVideoDataOutput setSampleBufferDelegate:self
                                              queue:dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL)];
    [[captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    if ([[SmileViewController sharedSession] canAddOutput:captureVideoDataOutput]) {
        [[SmileViewController sharedSession] addOutput:captureVideoDataOutput];
    }
}

- (void)setupCaptureVideoPreviewLayer {
    NSError *error = nil;
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[SmileViewController sharedSession]];
    [self.captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.previewView.layer addSublayer:self.captureVideoPreviewLayer];
    
    [[SmileViewController sharedSession] startRunning];
    
    if (error) {
        [self presentViewController:[UIAlertController alertControllerWithTitle:@"Initialization error"
                                                                           info:[error localizedDescription]
                                                                        handler:nil]
                           animated:YES
                         completion:nil];
    }
}

- (void)setupCaptureDevice {
    for (AVCaptureDevice *captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([captureDevice position] == AVCaptureDevicePositionFront) {
            [[self.captureVideoPreviewLayer session] beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
            
            for (AVCaptureInput *oldInput in [[self.captureVideoPreviewLayer session] inputs]) {
                [[self.captureVideoPreviewLayer session] removeInput:oldInput];
            }
            
            [[self.captureVideoPreviewLayer session] addInput:input];
            [[self.captureVideoPreviewLayer session] commitConfiguration];
            break;
        }
    }
}

- (IBAction)showFrontCamera:(id)sender {
    
}

#pragma mark - Styling methods

- (void)styleSharingButtons {
    self.retakePhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.retakePhotoButton setTitle:@"Retake" forState:UIControlStateNormal];
    
    self.shareViaTwitterButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.shareViaTwitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
    
    self.shareViaFacebookButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.shareViaFacebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
    
    self.shareViaInstagramButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.shareViaInstagramButton setTitle:@"Instagram" forState:UIControlStateNormal];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    if (attachments) {
        CFRelease(attachments);
    }
    
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6],
                                  CIDetectorImageOrientation,
                                  [NSNumber numberWithBool:YES],
                                  CIDetectorSmile,
                                  nil];
    
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
    
    for (CIFaceFeature *faceFeature in features) {
        if (faceFeature.hasSmile) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                UIImage *image = [[UIImage alloc] initWithCIImage:ciImage];
                self.takenPhotoImage = image;
            });
            
            [[self.captureVideoPreviewLayer session] stopRunning];
            
            break;
        }
    }
}

#pragma mark - Photo sharing methods

- (IBAction)retakePhotoButtonPressed:(id)sender {
    if (![self.captureVideoPreviewLayer session].isRunning) {
        self.takenPhotoImage = nil;
        [[self.captureVideoPreviewLayer session] startRunning];
    }
}

- (IBAction)shareViaInstagram:(id)sender {
    
}

- (IBAction)shareViaFacebook:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        UIImage *image = [UIImage resizeImage:self.takenPhotoImage toSize:CGSizeMake(640.0f, 480.0f)];
        image = [UIImage rotateImage:image byDegrees:90.0f withSize:image.size];
        [composeViewController addImage:image];
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    } else {
        [self presentViewController:[UIAlertController alertControllerWithTitle:@"Facebook is not available"
                                                                           info:@"Make sure your device has an internet connection and you have at least one Facebook account added"
                                                                        handler:nil]
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)shareViaTwitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        UIImage *image = [UIImage resizeImage:self.takenPhotoImage toSize:CGSizeMake(640.0f, 480.0f)];
        image = [UIImage rotateImage:image byDegrees:90.0f withSize:image.size];
        [composeViewController addImage:image];
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    } else {
        [self presentViewController:[UIAlertController alertControllerWithTitle:@"Twitter is not available"
                                                                           info:@"Make sure your device has an internet connection and you have at least one Twitter account added"
                                                                        handler:nil]
                           animated:YES
                         completion:nil];
    }
}

@end
