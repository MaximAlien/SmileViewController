//
//  UIImage+Additions.h
//  SmileCameraViewControllerDemo
//
//  Created by Maxim Makhun on 9/9/16.
//  Copyright © 2016 MMA. All rights reserved.
//

@import UIKit;

@interface UIImage (Additions)

+ (UIImage *)rotateImage:(UIImage *)image byDegrees:(CGFloat)degrees withSize:(CGSize)size;

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

@end
