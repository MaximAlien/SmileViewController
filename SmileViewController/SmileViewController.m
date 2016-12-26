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
#import "CIFaceFeature+Helpers.h"

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

@interface SmileViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property(nonatomic, strong) UIImage *takenPhotoImage;
@property(nonatomic, strong) CALayer *rightEyeLayer;
@property(nonatomic, strong) CALayer *leftEyeLayer;
@property(nonatomic, strong) CALayer *mouthLayer;
@property(nonatomic, strong) CALayer *faceLayer;
@property(nonatomic, strong) AVCaptureDevice *captureDevice;
@property(nonatomic, weak) IBOutlet UIView *previewView;

- (IBAction)shareViaInstagram:(id)sender;
- (IBAction)shareViaFacebook:(id)sender;
- (IBAction)shareViaTwitter:(id)sender;
- (IBAction)retakePhotoButtonPressed:(id)sender;
- (IBAction)showFrontCamera:(id)sender;

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
        self.captureDevice = device;
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
        if ([captureDevice position] == AVCaptureDevicePositionBack) {
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
    AVCaptureDevice *frontCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
    AVCaptureDevice *backCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
    
    if (self.captureDevice.position == frontCaptureDevice.position) {
        self.captureDevice = backCaptureDevice;
    } else if (self.captureDevice.position == backCaptureDevice.position) {
        self.captureDevice = frontCaptureDevice;
    }
    
    [self switchCaptureDevice];
}

- (void)switchCaptureDevice {
    [[SmileViewController sharedSession] beginConfiguration];
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
    
    for (AVCaptureInput *oldInput in [SmileViewController sharedSession].inputs) {
        [[SmileViewController sharedSession] removeInput:oldInput];
    }
    
    [[SmileViewController sharedSession] addInput:newInput];
    [[SmileViewController sharedSession] commitConfiguration];
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
    UIImage *uiImage = [UIImage imageFromSampleBuffer:sampleBuffer];
    
    if (attachments) {
        CFRelease(attachments);
    }
    
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObjectsAndKeys:@6,
                                  CIDetectorImageOrientation,
                                  [NSNumber numberWithBool:YES],
                                  CIDetectorSmile,
                                  nil];
    
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
    
    for (CIFaceFeature *faceFeature in features) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.rightEyeLayer removeFromSuperlayer];
            
            if (faceFeature.hasRightEyePosition) {
                self.rightEyeLayer = [CALayer layer];
                self.rightEyeLayer.frame = CGRectMake([faceFeature rightEyePositionForImage:uiImage size:self.previewView.frame.size].x,
                                                      [faceFeature rightEyePositionForImage:uiImage size:self.previewView.frame.size].y,
                                                      5.0f,
                                                      5.0f);
                self.rightEyeLayer.backgroundColor = [UIColor greenColor].CGColor;
                self.rightEyeLayer.cornerRadius = CGRectGetWidth(self.leftEyeLayer.frame) / 2.0f;
                
                [self.previewView.layer addSublayer:self.rightEyeLayer];
            }
        });
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.leftEyeLayer removeFromSuperlayer];
            
            if (faceFeature.hasLeftEyePosition) {
                self.leftEyeLayer = [CALayer layer];
                self.leftEyeLayer.frame = CGRectMake([faceFeature leftEyePositionForImage:uiImage size:self.previewView.frame.size].x,
                                                     [faceFeature leftEyePositionForImage:uiImage size:self.previewView.frame.size].y,
                                                     5.0f,
                                                     5.0f);
                self.leftEyeLayer.backgroundColor = [UIColor redColor].CGColor;
                self.leftEyeLayer.cornerRadius = CGRectGetWidth(self.leftEyeLayer.frame) / 2.0f;
                
                [self.previewView.layer addSublayer:self.leftEyeLayer];
            }
        });
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.mouthLayer removeFromSuperlayer];
            
            if (faceFeature.hasMouthPosition) {
                self.mouthLayer = [CALayer layer];
                self.mouthLayer.frame = CGRectMake([faceFeature mouthPositionForImage:uiImage size:self.previewView.frame.size].x,
                                                   [faceFeature mouthPositionForImage:uiImage size:self.previewView.frame.size].y,
                                                   5.0f,
                                                   5.0f);
                self.mouthLayer.backgroundColor = [UIColor blueColor].CGColor;
                self.mouthLayer.cornerRadius = CGRectGetWidth(self.mouthLayer.frame) / 2.0f;
                
                [self.previewView.layer addSublayer:self.mouthLayer];
            }
        });
        
        // in case if user is smiling we stop any updates
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (faceFeature.hasSmile) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    UIImage *image = [[UIImage alloc] initWithCIImage:ciImage];
                    self.takenPhotoImage = image;
                });
                
                [[self.captureVideoPreviewLayer session] stopRunning];
            }
        });
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.faceLayer removeFromSuperlayer];
            
            self.faceLayer = [CALayer layer];
            CGRect bounds = [faceFeature boundsForImage:uiImage size:self.previewView.frame.size];
            self.faceLayer.frame = CGRectMake(bounds.origin.x,
                                              bounds.origin.y,
                                              bounds.size.width,
                                              bounds.size.height);
            self.faceLayer.backgroundColor = [UIColor clearColor].CGColor;
            self.faceLayer.borderColor = [UIColor blackColor].CGColor;
            self.faceLayer.borderWidth = 3.0f;
            self.faceLayer.transform = CATransform3DMakeRotation(faceFeature.faceAngle / 180.0 * M_PI, 0.0, 0.0, 1.0);
            
            CALayer *glassesLayer = [CALayer layer];
            glassesLayer.frame = CGRectMake(0,
                                            [faceFeature leftEyePositionForImage:uiImage size:self.previewView.frame.size].y - bounds.origin.y - 40,
                                            bounds.size.width,
                                            bounds.size.height / 3);
            
            UIImage *glassesImage = [UIImage imageNamed:@"glasses"];
            glassesLayer.contents = (id)glassesImage.CGImage;
            glassesLayer.contentsGravity = kCAGravityResizeAspect;
            [self.faceLayer addSublayer:glassesLayer];
            
            [self.previewView.layer addSublayer:self.faceLayer];
        });
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
