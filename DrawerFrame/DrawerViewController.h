//
//  DrawerViewController.h
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-29.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawerViewController : UIViewController {
}

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *contentView;

- (void)initDrawerView;

@end
