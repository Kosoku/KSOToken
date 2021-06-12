//
//  UINavigationItem+DemoExtensions.m
//  KSOToken
//
//  Created by William Towe on 8/29/17.
//  Copyright © 2021 Kosoku Interactive, LLC. All rights reserved.
//

#import "UIBarButtonItem+DemoExtensions.h"

#import <Ditko/Ditko.h>

@implementation UIBarButtonItem (DemoExtensions)

+ (UIBarButtonItem *)iosd_changeTintColorBarButtonItemWithViewController:(UIViewController *)viewController {
    return [UIBarButtonItem KDI_barButtonSystemItem:UIBarButtonSystemItemRefresh block:^(__kindof UIBarButtonItem * _Nonnull barButtonItem) {
        return [viewController.view setTintColor:KDIColorRandomRGB()];
    }];
}

@end
