//
//  UIAlertController+Utilities.h
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import UIKit;

@interface UIAlertController (Utilities)

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title
                                           info:(NSString *)info
                                        handler:(void (^)())handler;

@end