//
//  CIFaceFeature+Helpers.h
//  SmileViewControllerDemo
//
//  Created by Maxim Makhun on 10/4/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import CoreImage;
@import UIKit;

@interface CIFaceFeature (Helpers)

- (CGPoint)leftEyePositionForImage:(UIImage *)image;
- (CGPoint)rightEyePositionForImage:(UIImage *)image;
- (CGPoint)mouthPositionForImage:(UIImage *)image;
- (CGRect)boundsForImage:(UIImage *)image;

- (CGPoint)normalizedLeftEyePositionForImage:(UIImage *)image;
- (CGPoint)normalizedRightEyePositionForImage:(UIImage *)image;
- (CGPoint)normalizedMouthPositionForImage:(UIImage *)image;
- (CGRect)normalizedBoundsForImage:(UIImage *)image;

- (CGPoint)leftEyePositionForImage:(UIImage *)image size:(CGSize)size;
- (CGPoint)rightEyePositionForImage:(UIImage *)image size:(CGSize)size;
- (CGPoint)mouthPositionForImage:(UIImage *)image size:(CGSize)size;
- (CGRect)boundsForImage:(UIImage *)image size:(CGSize)size;

@end
