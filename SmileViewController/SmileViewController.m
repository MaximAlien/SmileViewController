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

@interface SmileViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property(nonatomic, strong) UIImage *takenPhotoImage;
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

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

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
        return;
    }
    
    for (CIFaceFeature *faceFeature in features) {
        if (faceFeature.hasSmile) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                UIImage *image = [[UIImage alloc] initWithCIImage:ciImage];
                self.takenPhotoImage = image;
            });
            
            [[self.captureVideoPreviewLayer session] stopRunning];
        }
    }
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

#pragma mark - Action handlers

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

- (IBAction)retakePhotoButtonPressed:(id)sender {
    if (![self.captureVideoPreviewLayer session].isRunning) {
        self.takenPhotoImage = nil;
        [[self.captureVideoPreviewLayer session] startRunning];
    }
}

@end
