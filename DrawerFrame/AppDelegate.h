//
//  AppDelegate.h
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNavigatioController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (strong, nonatomic) TSNavigatioController *navigationController;

+ (AppDelegate *)instance;

@end
