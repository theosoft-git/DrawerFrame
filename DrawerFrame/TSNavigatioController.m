//
//  TSNavigatioController.m
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import "TSNavigatioController.h"
#import "DrawerViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface TSNavigatioController ()

@end

@implementation TSNavigatioController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super initWithRootViewController:rootViewController];
	if (self) {
        UIPanGestureRecognizer *panGestureRecognier = [[UIPanGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(HandlePan:)];
        [self.view addGestureRecognizer:panGestureRecognier];
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

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ([viewController isKindOfClass:[DrawerViewController class]]) {
        DrawerViewController *controller = (DrawerViewController *) viewController;
        if ([controller isDrawerView]) {
            [controller initDrawerView];
            if (_imageView) {
                [_imageView removeFromSuperview];
            }
            _imageView = controller.imageView;
            [[[AppDelegate instance] window] insertSubview:_imageView atIndex:0];
            if (animated) {
                UIView *curView = [self view];
                [curView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                [super pushViewController:controller animated:NO];
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^(void){
                                     [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                     [_imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                                     _imageView.alpha = 0.6;
                                 }completion:^(BOOL finish){
                                 }];
                return;
            }
        }
    }
	
	[super pushViewController:viewController animated:animated];
//    [super pushViewController:viewController animated:animated];
}

- (void)HandlePan:(UIPanGestureRecognizer*)panGestureRecognizer{
    UIView *curView = [self view];
    if (![[[self viewControllers] lastObject] isKindOfClass:[DrawerViewController class]]) {
        return;
    }
    DrawerViewController *lastViewController = (DrawerViewController *)[[self viewControllers] lastObject];
    if (![lastViewController isDrawerView]) {
        return;
    }
   
    CGPoint translation = [panGestureRecognizer translationInView:self.imageView];
    NSLog(@"x:%.2f", translation.x);
    
    if ([[self viewControllers] count] > 1) {
        if (translation.x > 0) {
            [curView setTransform:CGAffineTransformMakeTranslation(translation.x, 0)];
            double scale = MIN(1.0f, 0.95 + translation.x / 4000);
            [_imageView setTransform:CGAffineTransformMakeScale(scale, scale)];
            double alpha = MIN(1.0f, 0.6 + translation.x / 500);
            _imageView.alpha = alpha;
        }
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (translation.x > 100) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^(void){
                                     [curView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                                     _imageView.alpha = 1;
                                     [_imageView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                 }completion:^(BOOL finish){
                                     [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                     [self popViewControllerAnimated:NO];
                                 }];
            }else{
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^(void){
                                     [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                     _imageView.alpha = 0.95;
                                     [_imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                                 }completion:^(BOOL finish){
                                     
                                 }];
            }
        }
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *poppedViewController;
    poppedViewController = (UIViewController *)[super popViewControllerAnimated:animated];
    UIViewController *lastController = [[self viewControllers] lastObject];
    if (_imageView) {
        [_imageView removeFromSuperview];
    }
    if ([lastController isKindOfClass:[DrawerViewController class]]) {
        DrawerViewController *curViewController = (DrawerViewController *)lastController;
        if ([curViewController isDrawerView] && curViewController.imageView) {
            _imageView = curViewController.imageView;
            [[[AppDelegate instance] window] insertSubview:_imageView atIndex:0];
        }
    }
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSArray *poppedViewController = [super popToViewController:viewController animated:animated];
    if (_imageView) {
        [_imageView removeFromSuperview];
    }
    UIViewController *lastController = [[self viewControllers] lastObject];
    if ([lastController isKindOfClass:[DrawerViewController class]]) {
        DrawerViewController *curViewController = (DrawerViewController *)lastController;
        if ([curViewController isDrawerView] && curViewController.imageView) {
            _imageView = curViewController.imageView;
            [[[AppDelegate instance] window] insertSubview:_imageView atIndex:0];
        }
    }
	return poppedViewController;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
	NSArray *poppedViewController = [super popToRootViewControllerAnimated:animated];
    if (_imageView) {
        [_imageView removeFromSuperview];
    }
	return poppedViewController;
}

@end
