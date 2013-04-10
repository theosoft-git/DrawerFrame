//
//  DrawerViewController.m
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-29.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import "DrawerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface DrawerViewController ()

@end

@implementation DrawerViewController

- (id)init
{
	if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDrawerView
{
    UIView *curView = [[[AppDelegate instance] navigationController] view];
    
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(curView.frame.size, NO, 0.0);
    }
    else {
        UIGraphicsBeginImageContext(curView.frame.size);
    }
    
    [curView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *lastViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _imageView = [[UIImageView alloc]initWithImage:lastViewImage];
    _imageView.frame  = curView.frame;
    _imageView.backgroundColor = [UIColor blackColor];
}
@end
