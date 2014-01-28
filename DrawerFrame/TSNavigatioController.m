//
//  TSNavigatioController.m
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import "TSNavigatioController.h"
#import "UIViewController+DrawerView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (NVNavigationController)

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backToPreviousViewController)];
}

- (void)backToPreviousViewController {
	if ([self.navigationController isKindOfClass:[TSNavigatioController class]]) {
        TSNavigatioController *navController = (TSNavigatioController *)self.navigationController;
        if ([self respondsToSelector:@selector(isDrawerView)]) {
            if ([self isDrawerView] && [navController.viewControllers count] > 1) {
                [navController popWithAnimation];
                return;
            }
        }
    }
    
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelBackToPreviousViewController
{
	if (![self.navigationController isKindOfClass:[TSNavigatioController class]]) {
        return;
    }
    
    TSNavigatioController *navController = (TSNavigatioController *)self.navigationController;
    [navController cancelPopWithAnimation];
}

@end

@interface TSNavigatioController ()

@end

@implementation TSNavigatioController
{
    BOOL                    isShowingAnimation;
    UIImageView             *img_shadow;
    UIPanGestureRecognizer  *_panGestureRecognier;
}

//Whether to use iOS7 style animation
static bool useIOS7Animation = YES;

- (id)init
{
    self = [super init];
    if (self) {
        if (!_panGestureRecognier) {
            _panGestureRecognier = [[UIPanGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(HandlePan:)];
            _panGestureRecognier.delegate = self;
            [self.view addGestureRecognizer:_panGestureRecognier];
            img_shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border_Shadow"]];
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (!_panGestureRecognier) {
            _panGestureRecognier = [[UIPanGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(HandlePan:)];
            _panGestureRecognier.delegate = self;
            [self.view addGestureRecognizer:_panGestureRecognier];
            img_shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border_Shadow"]];
        }
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super initWithRootViewController:rootViewController];
	if (self) {
        if (!_panGestureRecognier) {
            _panGestureRecognier = [[UIPanGestureRecognizer alloc]
                                                           initWithTarget:self
                                                           action:@selector(HandlePan:)];
            _panGestureRecognier.delegate = self;
            [self.view addGestureRecognizer:_panGestureRecognier];
            img_shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border_Shadow"]];
        }
	}
	return self;
}

#pragma mark Push

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (self.viewControllers.count>0) {
        [[viewController navigationItem] setLeftBarButtonItem:[viewController backBarButtonItem]];
	}
    UIView *curView = [self view];
    [curView endEditing:YES];
	
	if ([viewController respondsToSelector:@selector(isDrawerView)]) {
        if ([viewController isDrawerView] && [self.viewControllers count] > 0) {
            [self initDrawerView:viewController];
            [self initBackImage:viewController.backImage];

            if (animated) {
                if (useIOS7Animation) {
                    [super pushViewController:viewController animated:YES];
                }
                else {
                    [curView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                    [super pushViewController:viewController animated:NO];
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
}

#pragma mark Pop

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *poppedViewController;
    poppedViewController = (UIViewController *)[super popViewControllerAnimated:animated];
    if ([self.topViewController respondsToSelector:@selector(isDrawerView)]) {
        UIViewController *curViewController = self.topViewController;
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
    if ([self.topViewController respondsToSelector:@selector(isDrawerView)]) {
        UIViewController *curViewController = self.topViewController;
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

- (void)popWithAnimation
{
    isShowingAnimation = YES;
    if (useIOS7Animation) {
        isShowingAnimation = NO;
        [self continuePopWithAnimation];
        return;
    }
    _imageView.alpha = 0.6;
    [_imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         [self.view setTransform:CGAffineTransformMakeTranslation(320, 0)];
                         _imageView.alpha = 1.0;
                         [_imageView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                     }completion:^(BOOL finish){
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
                         isShowingAnimation = NO;
                         [self popViewControllerAnimated:NO];
                     }];
    
}

#pragma mark Gesture

- (void)HandlePan:(UIPanGestureRecognizer*)panGestureRecognizer{
    UIView *curView = [self view];
    
    CGPoint translation = [panGestureRecognizer translationInView:self.imageView];
//    NSLog(@"x:%.2f", translation.x);
    
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
                [self.topViewController backToPreviousViewController];
            } else {
                [self cancelPopWithAnimation];
            }
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (![self.topViewController respondsToSelector:@selector(isDrawerView)]) {
        return NO;
    }
    UIViewController *lastViewController = self.topViewController;
    if (![lastViewController isDrawerView] || lastViewController.backImage == nil) {
        return NO;
    }
    CGPoint translation = [_panGestureRecognier translationInView:self.imageView];
    //    NSLog(@"x:%.2f", translation.x);
    return translation.x > 0;
}

- (void)continuePopWithAnimation
{
    UIView *curView = [self view];
    if (CGAffineTransformIsIdentity(curView.transform)) {
        [self popViewControllerAnimated:YES];
        return;
    }
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
}

- (void)cancelPopWithAnimation
{
    UIView *curView = [self view];
    if (CGAffineTransformIsIdentity(curView.transform)) {
        return;
    }
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
                         isShowingAnimation = NO;
                         [img_shadow removeFromSuperview];
                     }];
}

#pragma mark initDrawerView

- (void)initDrawerView:(UIViewController *)viewController
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
        [[[AppDelegate instance] window] insertSubview:_imageView belowSubview:self.view];
    }
    else {
        [_imageView setImage:backImage];
        [_imageView setTransform:CGAffineTransformMakeScale(1, 1)];
        _imageView.alpha = 1;
        [_imageView setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }
}

#pragma mark -
#pragma mark View Life Methods

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

- (void)dealloc
{
    if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
}

@end
