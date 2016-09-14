//
//  UIAlertController+Utilities.h
//  SoundCloud
//
//  Created by Maxim Makhun on 8/25/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import UIKit;

@interface UIAlertController (Utilities)

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title
                                           info:(NSString *)info
                                        handler:(void (^)())handler;

@end