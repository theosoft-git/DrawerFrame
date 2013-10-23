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
{
    BOOL            isShowingAnimation;
    UIImageView     *img_shadow;
}

//Whether to use iOS7 style animation
static bool useIOS7Animation = YES;

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
        img_shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border_Shadow"]];
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
        if ([controller isDrawerView] && [self.viewControllers count] > 0) {
            [self initDrawerView:controller];
            [self initBackImage:controller.backImage];

            if (animated) {
                if (useIOS7Animation) {
                    [super pushViewController:controller animated:YES];
                }
                else {
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
                }
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
            if (!isShowingAnimation) {
                isShowingAnimation = YES;
//                curView.layer.shadowOffset = CGSizeMake(-4, 0);
//                curView.layer.shadowColor = [[UIColor blackColor] CGColor];
//                curView.layer.shadowOpacity = 0.5;
                CGRect screenFrame = [[UIScreen mainScreen] bounds];
                curView.clipsToBounds = NO;
                [curView addSubview:img_shadow];
                [img_shadow setFrame:CGRectMake(-6 , 0, 6, screenFrame.size.height)];
            }
            
            [curView setTransform:CGAffineTransformMakeTranslation(translation.x, 0)];
            if (useIOS7Animation) {
                double translatedX = translation.x / 2.0f - 160;
                [_imageView setTransform:CGAffineTransformMakeTranslation(translatedX, 0)];
            }
            else {
                double scale = MIN(1.0f, 0.95 + translation.x / 4000);
                [_imageView setTransform:CGAffineTransformMakeScale(scale, scale)];
                double alpha = MIN(1.0f, 0.6 + translation.x / 500);
                _imageView.alpha = alpha;
            }
        }
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (translation.x > 100) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^(void){
                                     [curView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                                     if (useIOS7Animation) {
                                         [_imageView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                     }
                                     else {
                                         _imageView.alpha = 1;
                                         [_imageView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                     }
                                 }completion:^(BOOL finish){
                                     [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                     isShowingAnimation = NO;
                                     [self popViewControllerAnimated:NO];
                                 }];
            }else{
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^(void){
                                     [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                     if (useIOS7Animation) {
                                         [_imageView setTransform:CGAffineTransformMakeTranslation(-160, 0)];
                                     }
                                     else {
                                         _imageView.alpha = 0.95;
                                         [_imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                                     }
                                 }completion:^(BOOL finish){
                                     [img_shadow removeFromSuperview];
                                     isShowingAnimation = NO;
                                 }];
            }
        }
    }
}

- (void)initDrawerView:(DrawerViewController *)viewController
{
    UIView *curView = [self view];
    
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(curView.frame.size, NO, 0.0);
    }
    else {
        UIGraphicsBeginImageContext(curView.frame.size);
    }
    
    [curView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *lastViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [viewController setBackImage:lastViewImage];
}

- (void)initBackImage:(UIImage *)backImage
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:backImage];
        _imageView.frame  = self.view.frame;
        _imageView.backgroundColor = [UIColor blackColor];
        int zIndex = 0;
        for (UIView *view in [[AppDelegate instance] window].subviews) {
            if (view == self.view) {
                break;
            }
            zIndex++;
        }
        [[[AppDelegate instance] window] insertSubview:_imageView atIndex:zIndex];
    }
    else {
        [_imageView setImage:backImage];
        [_imageView setTransform:CGAffineTransformMakeScale(1, 1)];
        _imageView.alpha = 1;
        [_imageView setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *poppedViewController;
    poppedViewController = (UIViewController *)[super popViewControllerAnimated:animated];
    UIViewController *lastController = [[self viewControllers] lastObject];
    if ([lastController isKindOfClass:[DrawerViewController class]]) {
        DrawerViewController *curViewController = (DrawerViewController *)lastController;
        if ([curViewController isDrawerView] && curViewController.backImage) {
            [self initBackImage:curViewController.backImage];
        }
        else if (_imageView) {
            [_imageView setImage:nil];
        }
    }
    if ([[self viewControllers] count] == 1 && _imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSArray *poppedViewController = [super popToViewController:viewController animated:animated];
    UIViewController *lastController = [[self viewControllers] lastObject];
    if ([lastController isKindOfClass:[DrawerViewController class]]) {
        DrawerViewController *curViewController = (DrawerViewController *)lastController;
        if ([curViewController isDrawerView] && curViewController.backImage) {
            [self initBackImage:curViewController.backImage];
        }
        else if (_imageView) {
            [_imageView setImage:nil];
        }
    }
    if ([[self viewControllers] count] == 1 && _imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
	return poppedViewController;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
	NSArray *poppedViewController = [super popToRootViewControllerAnimated:animated];
    if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
	return poppedViewController;
}

@end
