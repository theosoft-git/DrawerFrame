//
//  TSNavigatioController.h
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TSNavigationStyleIOS7,
    TSNavigationStyleDrawer,
    TSNavigationStyleCascade,
    TSNavigationStyleIOS7Pop,
} TSNavigationStyle;

@class TSNavigationController;
@protocol TSDrawerFrameDelegate <NSObject>

@optional
- (void)drawerAnimationWillShow:(TSNavigationController *)navigationController;
- (void)drawerAnimationDidEnd:(TSNavigationController *)navigationController;

@end

@interface TSNavigationController : UINavigationController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) id<TSDrawerFrameDelegate> tsDelegate;

@property (nonatomic, copy) NSArray * (^preAction)();
@property (nonatomic, assign) BOOL  needPop2Root;

- (void)continuePopWithAnimation;
- (void)cancelPopWithAnimation;

@end

@interface UIViewController (NVNavigationController) <TSDrawerFrameDelegate>

@property (nonatomic, strong) UIImage *backImage;

//是否支持抽屉视图。
- (BOOL)isDrawerView;
//是否允许滑动返回。
- (BOOL)canSlideBack;

- (TSNavigationStyle)navigationStyle;

- (UIBarButtonItem *)backBarButtonItem;
- (void)backToPreviousViewController;
- (void)cancelBackToPreviousViewController;
@end
