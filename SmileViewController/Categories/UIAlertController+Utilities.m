//
//  UIAlertController+Utilities.m
//
//  Created by Maxim Makhun on 9/14/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

#import "UIAlertController+Utilities.h"

@implementation UIAlertController (Utilities)

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title
                                           info:(NSString *)info
                                        handler:(void (^)())handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(title, nil)
                                                                             message:NSLocalizedString(info, nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    
    [alertController addAction:okAction];
    
    return alertController;
}

@end
