//
//  SmileImageViewController.m
//  SmileCameraViewControllerDemo
//
//  Created by maxim.makhun on 5/9/14.
//  Copyright (c) 2014 MMA. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>

#import "SmileCameraViewController.h"

@interface SmileCameraViewController ()

@end

CGFloat degreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

@interface UIImage (Rotate)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end

@implementation UIImage (Rotate)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    CGContextRotateCTM(bitmap, degreesToRadians(degrees));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

@interface SmileCameraViewController (InternalMethods)

- (void)setupAVCapture;
- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;

@end

@implementation SmileCameraViewController

- (void)setupAVCapture
{
	NSError *error = nil;
	
	AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	
	if ([session canAddInput:deviceInput])
    {
        [session addInput:deviceInput];
    }
    
	mStillImageOutput = [AVCaptureStillImageOutput new];
	[mStillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)];
	if ([session canAddOutput:mStillImageOutput])
    {
        [session addOutput:mStillImageOutput];
    }
    
	mVideoDataOutput = [AVCaptureVideoDataOutput new];
	
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[mVideoDataOutput setVideoSettings:rgbOutputSettings];
	[mVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
	mVideoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[mVideoDataOutput setSampleBufferDelegate:self queue:mVideoDataOutputQueue];
	
    if ([session canAddOutput:mVideoDataOutput])
    {
        [session addOutput:mVideoDataOutput];
    }
    
	[[mVideoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	mPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[mPreviewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[mPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	CALayer *rootLayer = [previewView layer];
	[rootLayer setMasksToBounds:YES];
	[mPreviewLayer setFrame:[rootLayer bounds]];
	[rootLayer addSublayer:mPreviewLayer];
	[session startRunning];
    
bail:
    
	if (error)
    {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
	}
    
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
    {
		if ([captureDevice position] == desiredPosition)
        {
			[[mPreviewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
			
            for (AVCaptureInput *oldInput in [[mPreviewLayer session] inputs])
            {
				[[mPreviewLayer session] removeInput:oldInput];
			}
            
			[[mPreviewLayer session] addInput:input];
			[[mPreviewLayer session] commitConfiguration];
			break;
		}
	}
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
    {
        CFRelease(attachments);
    }
    
	NSDictionary *imageOptions = nil;
    
	imageOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6], CIDetectorImageOrientation, [NSNumber numberWithBool:YES], CIDetectorSmile, nil];
    
	NSArray *features = [mFaceDetector featuresInImage:ciImage options:imageOptions];
    
    for (CIFaceFeature* faceFeature in features)
    {
        if (faceFeature.hasSmile)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                UIImage *image = [[UIImage alloc] initWithCIImage:ciImage];
                mTakenPhoto = image;
            });
            
            [[mPreviewLayer session] stopRunning];
            
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupAVCapture];
    
	NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
	mFaceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (IBAction)retakePhotoButtonPressed:(id)sender
{
    if (![[mPreviewLayer session] isRunning])
    {
        [[mPreviewLayer session] startRunning];
    }
}

- (IBAction)shareViaInstagram:(id)sender
{
    UIImage *image = [self resizeImage:mTakenPhoto scaledToSize:CGSizeMake(640, 480)];
    image = [image imageRotatedByDegrees:90.0];
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/originalImage.ig"];
    [UIImagePNGRepresentation(image) writeToFile:savePath atomically:YES];
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
        _documentController.UTI = @"com.instagram.exclusivegram";
        _documentController.delegate = self;
        _documentController.annotation = [NSDictionary dictionaryWithObject:@"Your Caption here" forKey:@"InstagramCaption"];
        [_documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}

- (UIImage *)resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)shareViaFacebook:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:@"Your text here"];
        
        UIImage *image = [self resizeImage:mTakenPhoto scaledToSize:CGSizeMake(640, 480)];
        image = [image imageRotatedByDegrees:90.0];
        [mySLComposerSheet addImage:image];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Facebook is not available"
                                  message:@"Make sure your device has an internet connection and you have at least one Facebook account added"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)shareViaTwitter:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:@"Your text here"];
        
        UIImage *image = [self resizeImage:mTakenPhoto scaledToSize:CGSizeMake(640, 480)];
        image = [image imageRotatedByDegrees:90.0];
        
        [mySLComposerSheet addImage:image];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Twitter is not available"
                                  message:@"Make sure your device has an internet connection and you have at least one Twitter account added"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
