//
//  UIViewController+DrawerView.m
//  DrawerFrame
//
//  Created by Johnson Zhang on 14-1-28.
//  Copyright (c) 2014年 Theosoft. All rights reserved.
//

#import "UIViewController+DrawerView.h"
#import <objc/runtime.h>

@implementation UIViewController (DrawerView)

@dynamic backImage;

static char const * const BackImageTag = "BackImageTag";

- (void)setBackImage:(UIImage *)backImage
{
    objc_setAssociatedObject(self, BackImageTag, backImage, OBJC_ASSOCIATION_RETAIN);
}

- (UIImage *)backImage
{
    return objc_getAssociatedObject(self, BackImageTag);
}

- (BOOL)isDrawerView
{
    return YES;     //黑名单制，不需要支持的页面请返回NO；也可以将这里改为NO，成为白名单制
}

@end
