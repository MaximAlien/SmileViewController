//
//  SmileImageViewController.m
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import AVFoundation;

@class CIDetector;

#import "SmileViewController.h"

// Categories
#import "UIImage+Additions.h"
#import "UIAlertController+Utilities.h"
#import "CIFaceFeature+Helpers.h"

@interface SmileViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property(nonatomic, strong) UIImage *takenPhotoImage;
@property(nonatomic, strong) CALayer *rightEyeLayer;
@property(nonatomic, strong) CALayer *leftEyeLayer;
@property(nonatomic, strong) CALayer *mouthLayer;
@property(nonatomic, strong) CALayer *faceLayer;
@property(nonatomic, weak) IBOutlet UIView *previewView;
@property(nonatomic, weak) IBOutlet UIButton *retakePhotoButton;
@property(nonatomic, weak) IBOutlet UIButton *showFrontCameraButton;

- (IBAction)retakePhotoButtonPressed:(id)sender;
- (IBAction)showFrontCamera:(id)sender;

@end

@implementation SmileViewController

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCaptureVideoPreviewLayer];
    [self setupCaptureDevice];
    [self setupCaptureVideoDataOutput];
    [self styleButtons];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.captureVideoPreviewLayer setFrame:self.previewView.layer.frame];
}

#pragma mark - Setting up methods

- (void)setupCaptureVideoPreviewLayer {
    AVCaptureSession *captureSession = [AVCaptureSession new];
    captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [self.captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.previewView.layer addSublayer:self.captureVideoPreviewLayer];
    
    [captureSession startRunning];
}

- (void)setupCaptureDevice {
    AVCaptureSession *captureSession = self.captureVideoPreviewLayer.session;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                        mediaType:AVMediaTypeVideo
                                                                         position:AVCaptureDevicePositionBack];
    NSError *error;
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                                                                     error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    [captureSession beginConfiguration];
    
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
    } else {
        NSLog(@"Unable to add new input.");
    }
    
    [captureSession commitConfiguration];
}

- (void)setupCaptureVideoDataOutput {
    AVCaptureVideoDataOutput *captureVideoDataOutput = [AVCaptureVideoDataOutput new];
    
    NSDictionary *videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCMPixelFormat_32BGRA]};
    [captureVideoDataOutput setVideoSettings:videoSettings];
    [captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [captureVideoDataOutput setSampleBufferDelegate:self
                                              queue:dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL)];
    [[captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    if ([self.captureVideoPreviewLayer.session canAddOutput:captureVideoDataOutput]) {
        [self.captureVideoPreviewLayer.session addOutput:captureVideoDataOutput];
    } else {
        NSLog(@"Unable to add video data output.");
    }
}

- (IBAction)showFrontCamera:(id)sender {
    AVCaptureSession *captureSession = self.captureVideoPreviewLayer.session;
    AVCaptureDeviceInput *deviceInput = captureSession.inputs[0];
    AVCaptureDevice *captureDevice;
    
    switch (deviceInput.device.position) {
        case AVCaptureDevicePositionBack:
            captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                               mediaType:AVMediaTypeVideo
                                                                position:AVCaptureDevicePositionFront];
            break;
        case AVCaptureDevicePositionFront:
            captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                               mediaType:AVMediaTypeVideo
                                                                position:AVCaptureDevicePositionBack];
            break;
        case AVCaptureDevicePositionUnspecified:
        default:
            break;
    }
    
    [captureSession beginConfiguration];
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    [captureSession removeInput:deviceInput];
    [captureSession addInput:newInput];
    [captureSession commitConfiguration];
}

#pragma mark - Styling methods

- (void)styleButtons {
    self.retakePhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.retakePhotoButton setImage:[UIImage imageNamed:@"retake_image"] forState:UIControlStateNormal];
    [self.retakePhotoButton setTintColor:[UIColor whiteColor]];
    
    self.showFrontCameraButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.showFrontCameraButton setImage:[UIImage imageNamed:@"switch_camera_image"] forState:UIControlStateNormal];
    [self.showFrontCameraButton setTintColor:[UIColor whiteColor]];
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
    
    if (features.count == 0) {
        NSLog(@"No face features available.");
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.rightEyeLayer removeFromSuperlayer];
            [self.leftEyeLayer removeFromSuperlayer];
            [self.mouthLayer removeFromSuperlayer];
            [self.faceLayer removeFromSuperlayer];
        });
        
        return;
    }
    
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
            
            glassesLayer.contents = (id)[UIImage imageNamed:@"glasses_image"].CGImage;
            glassesLayer.contentsGravity = kCAGravityResizeAspect;
            [self.faceLayer addSublayer:glassesLayer];
            
            [self.previewView.layer addSublayer:self.faceLayer];
        });
    }
}

- (IBAction)retakePhotoButtonPressed:(id)sender {
    if (![self.captureVideoPreviewLayer session].isRunning) {
        self.takenPhotoImage = nil;
        [[self.captureVideoPreviewLayer session] startRunning];
    }
}

@end
