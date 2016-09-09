//
//  SmileImageViewController.m
//  SmileCameraViewControllerDemo
//
//  Created by Maxim Makhun on 5/9/14.
//  Copyright (c) 2014 MMA. All rights reserved.
//

@import Social;

#import "SmileCameraViewController.h"
#import "UIImage+Additions.h"

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

@interface SmileCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (strong, nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) CIDetector *faceDetector;
@property (strong, nonatomic) UIImage *takenPhotoImage;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *retakePhotoButton;

- (IBAction)shareViaInstagram:(id)sender;
- (IBAction)shareViaFacebook:(id)sender;
- (IBAction)shareViaTwitter:(id)sender;
- (IBAction)retakePhotoButtonPressed:(id)sender;

- (void)setupAVCapture;

@end

@implementation SmileCameraViewController

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAVCapture];
    
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupAVCapture {
    NSError *error = nil;
    
    AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    self.stillImageOutput = [AVCaptureStillImageOutput new];
    [self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)];
    if ([session canAddOutput:self.stillImageOutput]) {
        [session addOutput:self.stillImageOutput];
    }
    
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    if ([session canAddOutput:self.videoDataOutput]) {
        [session addOutput:self.videoDataOutput];
    }
    
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [self.previewView layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
    [session startRunning];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error: %d", (int)[error code]]
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionFront;
    
    for (AVCaptureDevice *captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([captureDevice position] == desiredPosition) {
            [[self.previewLayer session] beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
            
            for (AVCaptureInput *oldInput in [[self.previewLayer session] inputs]) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            
            [[self.previewLayer session] addInput:input];
            [[self.previewLayer session] commitConfiguration];
            break;
        }
    }
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
    
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6], CIDetectorImageOrientation, [NSNumber numberWithBool:YES], CIDetectorSmile, nil];
    NSArray *features = [self.faceDetector featuresInImage:ciImage options:imageOptions];
    
    for (CIFaceFeature *faceFeature in features) {
        if (faceFeature.hasSmile) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                UIImage *image = [[UIImage alloc] initWithCIImage:ciImage];
                self.takenPhotoImage = image;
            });
            
            [[self.previewLayer session] stopRunning];
            
            break;
        }
    }
}

#pragma mark - Photo sharing methods

- (IBAction)retakePhotoButtonPressed:(id)sender {
    if (![self.previewLayer session].isRunning) {
        self.takenPhotoImage = nil;
        [[self.previewLayer session] startRunning];
    }
}

- (IBAction)shareViaInstagram:(id)sender {
    UIImage *image = [UIImage resizeImage:self.takenPhotoImage toSize:CGSizeMake(640.0f, 480.0f)];
    image = [UIImage rotateImage:image byDegrees:90.0f withSize:image.size];
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/originalImage.ig"];
    [UIImagePNGRepresentation(image) writeToFile:savePath atomically:YES];
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
        self.documentController.UTI = @"com.instagram.exclusivegram";
        self.documentController.delegate = self;
        self.documentController.annotation = [NSDictionary dictionaryWithObject:@"" forKey:@"InstagramCaption"];
        [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
}

- (IBAction)shareViaFacebook:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:@""];
        
        UIImage *image = [UIImage resizeImage:self.takenPhotoImage toSize:CGSizeMake(640.0f, 480.0f)];
        image = [UIImage rotateImage:image byDegrees:90.0f withSize:image.size];
        [composeViewController addImage:image];
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook is not available"
                                                            message:@"Make sure your device has an internet connection and you have at least one Facebook account added"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)shareViaTwitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:@""];
        
        UIImage *image = [UIImage resizeImage:self.takenPhotoImage toSize:CGSizeMake(640.0f, 480.0f)];
        image = [UIImage rotateImage:image byDegrees:90.0f withSize:image.size];
        
        [composeViewController addImage:image];
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter is not available"
                                                            message:@"Make sure your device has an internet connection and you have at least one Twitter account added"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
