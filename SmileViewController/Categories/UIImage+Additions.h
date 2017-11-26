//
//  UIImage+Additions.h
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import UIKit;
@import CoreMedia;

@interface UIImage (Additions)

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
