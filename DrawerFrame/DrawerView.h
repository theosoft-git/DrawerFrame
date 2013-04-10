//
//  DrawerView.h
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawerView : UIView
{
    UIImage *lastViewImage;
    BOOL isPanComment;
}
- (id)initWithView:(UIView*)contentView parentView:(UIView*) parentView;

@property (nonatomic, strong) UIView *parentView; //抽屉视图的父视图
@property (nonatomic, strong) UIView *contentView; //抽屉显示内容的视图
@end