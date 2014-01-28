//
//  UIViewController+DrawerView.h
//  DrawerFrame
//
//  Created by Johnson Zhang on 14-1-28.
//  Copyright (c) 2014年 Theosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DrawerView)

@property (nonatomic, strong) UIImage *backImage;

- (BOOL)isDrawerView;

@end
