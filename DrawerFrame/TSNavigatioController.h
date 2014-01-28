//
//  TSNavigatioController.h
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSNavigatioController : UINavigationController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imageView;

- (void)popWithAnimation;
- (void)continuePopWithAnimation;
- (void)cancelPopWithAnimation;

@end

@interface UIViewController (NVNavigationController)

@property (nonatomic, strong) UIImage *backImage;

- (BOOL)isDrawerView;

- (UIBarButtonItem *)backBarButtonItem;
- (void)backToPreviousViewController;
- (void)cancelBackToPreviousViewController;
@end
