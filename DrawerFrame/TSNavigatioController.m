//
//  TSNavigatioController.m
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import "TSNavigatioController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation UIViewController (NVNavigationController)

@dynamic backImage;

static char const * const BackImageTag = "BackImageTag";

- (void)setBackImage:(UIImage *)backImage
{
    objc_setAssociatedObject(self, BackImageTag, backImage, OBJC_ASSOCIATION_RETAIN);
}

- (UIImage *)backImage
{
    return objc_getAssociatedObject(self, BackImageTag);
}

- (BOOL)isDrawerView
{
    return YES;     //黑名单制，不需要支持的页面请返回NO；也可以将这里改为NO，成为白名单制
}

- (BOOL)canSlideBack
{
    return [self isDrawerView];
}

- (TSNavigationStyle)navigationStyle
{
    return TSNavigationStyleIOS7;
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backToPreviousViewController)];
}

- (void)backToPreviousViewController {
	UINavigationController *naviController = nil;
	if (self.navigationController) {
		naviController = self.navigationController;
	} else {
		naviController = [[AppDelegate instance] navigationController];
	}
    
	if ([naviController isKindOfClass:[TSNavigationController class]]) {
        TSNavigationController *nvNavController = (TSNavigationController *)naviController;
        if ([self isDrawerView] && self.backImage != nil && [naviController.viewControllers count] > 1) {
            [nvNavController popViewControllerAnimated:YES];
            return;
        }
    }
    
	[naviController popViewControllerAnimated:YES];
}

- (void)cancelBackToPreviousViewController
{
	UINavigationController *naviController = nil;
	if (self.navigationController) {
		naviController = self.navigationController;
	} else {
		naviController = [[AppDelegate instance] navigationController];
	}
    
	if (![naviController isKindOfClass:[TSNavigationController class]]) {
        return;
    }
    
    TSNavigationController *navController = (TSNavigationController *)self.navigationController;
    [navController cancelPopWithAnimation];
}

@end

@interface TSNavigationController ()

@end

@implementation TSNavigationController
{
    BOOL                        _isShowingAnimation;
    UIImageView                 *_img_shadow_left;
    UIImageView                 *_img_shadow_up;
    UIImageView                 *_img_shadow_down;
    UIImageView                 *_img_shadow_right;
    UIPanGestureRecognizer      *_panGestureRecognier;
    UIView                      *_backgroundView;
    UIImage                     *_lastViewBackImage;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super initWithRootViewController:rootViewController];
	if (self) {
        [self setupView];
	}
	return self;
}

- (void)setupView
{
    if (!_panGestureRecognier) {
        _panGestureRecognier = [[UIPanGestureRecognizer alloc]
                                initWithTarget:self
                                action:@selector(HandlePan:)];
        _panGestureRecognier.delegate = self;
        [self.view addGestureRecognizer:_panGestureRecognier];
        
        _img_shadow_left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border_Shadow"]];
        _img_shadow_up = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_screen_shadow_up"]];
        _img_shadow_down = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_screen_shadow_down"]];
        _img_shadow_right = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"list_screen_shadow_right"] stretchableImageWithLeftCapWidth:0 topCapHeight:36]];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
        _backgroundView.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:_backgroundView atIndex:0];
    }
}

- (void)setNeedPop2Root:(BOOL)needPop2Root
{
    _needPop2Root = needPop2Root;
    if (_needPop2Root) {
        __weak __typeof(&*self) weakSelf = self;
        _preAction = ^NSArray *{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            return [strongSelf popToRootViewControllerAnimated:NO];
        };
    }
    else {
        _preAction = NULL;
    }
}

#pragma mark Push

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (self.viewControllers.count > 0) {
        [[viewController navigationItem] setLeftBarButtonItem:[viewController backBarButtonItem]];
	}
    UIView *curView = [self view];
    [curView endEditing:YES];
	
	if ([viewController respondsToSelector:@selector(isDrawerView)]) {
        if ([viewController isDrawerView] && [self.viewControllers count] > 0) {
            [self initDrawerView:viewController];
            
            if (_preAction != NULL) {
                NSArray *popped = _preAction();
                if (popped.count > 0) {
                    _lastViewBackImage = ((UIViewController *)popped.firstObject).backImage;
                }
            }

            [self initBackImage:viewController.backImage];
            _tsDelegate = viewController;
            
            if (_imageView.image == nil) {
                [super pushViewController:viewController animated:YES];
            }
            else {
                if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationWillShow:)]) {
                    [_tsDelegate drawerAnimationWillShow:self];
                }
                _isShowingAnimation = YES;
                switch ([viewController navigationStyle]) {
                    case TSNavigationStyleIOS7:
                    case TSNavigationStyleDrawer:
                        [_imageView removeFromSuperview];
                        [[[AppDelegate instance] window] insertSubview:_imageView belowSubview:self.view];
                        [self removeRightShadow];
                        [self addLeftShadow2View:curView];
                        [curView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                        break;
                    case TSNavigationStyleCascade:
                        [_imageView removeFromSuperview];
                        [[[AppDelegate instance] window] addSubview:_imageView];
                        [self addRightShadow];
                        [self removeLeftShadow];
                        break;
                    case TSNavigationStyleIOS7Pop:
                        [curView setTransform:CGAffineTransformMakeTranslation(-160, 0)];
                        [_imageView removeFromSuperview];
                        [[[AppDelegate instance] window] addSubview:_imageView];
                        [self addLeftShadow2View:_imageView];
                        [self removeRightShadow];
                        
                    default:
                        break;
                }
                [super pushViewController:viewController animated:NO];
                [UIView animateWithDuration:0.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^(void) {
                                     switch ([viewController navigationStyle]) {
                                         case TSNavigationStyleIOS7:
                                             [_imageView setTransform:CGAffineTransformMakeTranslation(-160, 0)];
                                             [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                             break;
                                         case TSNavigationStyleDrawer:
                                             [_imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                                             _imageView.alpha = 0.6;
                                             [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                             break;
                                         case TSNavigationStyleCascade:
                                             [_imageView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.75, 0.75), CGAffineTransformMakeTranslation(-240, 0))];
                                             break;
                                         case TSNavigationStyleIOS7Pop:
                                             [_imageView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                                             [curView setTransform:CGAffineTransformIdentity];
                                             break;
                                             
                                         default:
                                             break;
                                     }
                                 }
                                 completion:^(BOOL finish) {
                                     _isShowingAnimation = NO;
                                     [self removeLeftShadow];
                                     if (_preAction != NULL && _lastViewBackImage) {
                                         _preAction = NULL;
                                         self.topViewController.backImage = _lastViewBackImage;
                                         _imageView.image = _lastViewBackImage;
                                         _lastViewBackImage = nil;
                                     }
                                     if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationDidEnd:)]) {
                                         [_tsDelegate drawerAnimationDidEnd:self];
                                     }
                                 }
                 ];
            }
            return;
        }
    }
	
	[super pushViewController:viewController animated:animated];
}

#pragma mark Pop

- (void)preparePopAnimation:(UIImage *)image
{
    if (image != nil) {
        _imageView.image = image;
    }
    UIViewController *viewController = [self topViewController];
    switch ([viewController navigationStyle]) {
        case TSNavigationStyleIOS7: {
            if (CGAffineTransformIsIdentity(_imageView.transform)) {
                [_imageView setTransform:CGAffineTransformMakeTranslation(-160, 0)];
            }
            [_imageView removeFromSuperview];
            [[[AppDelegate instance] window] insertSubview:_imageView belowSubview:self.view];
            [self addLeftShadow2View:self.view];
            break;
        }
        case TSNavigationStyleDrawer: {
            if (CGAffineTransformIsIdentity(_imageView.transform)) {
                _imageView.alpha = 0.6;
                [_imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
            }
            [_imageView removeFromSuperview];
            [[[AppDelegate instance] window] insertSubview:_imageView belowSubview:self.view];
            [self addLeftShadow2View:self.view];
            break;
        }
        case TSNavigationStyleCascade:
            [_imageView removeFromSuperview];
            [[[AppDelegate instance] window] addSubview:_imageView];
            [self addRightShadow];
            break;
        case TSNavigationStyleIOS7Pop:
            [_imageView setTransform:CGAffineTransformMakeTranslation(-160, 0)];
            [_imageView removeFromSuperview];
            [[[AppDelegate instance] window] insertSubview:_imageView belowSubview:self.view];
            [self addLeftShadow2View:self.view];
            
        default:
            break;
    }
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
    if ([self presentedViewController]) {
        // 模态情况下禁止返回
        return nil;
    }
	UIViewController *returnController = nil;
	
    if (animated && [self.topViewController isDrawerView]) {
        [self preparePopAnimation:nil];
        if (_imageView.image == nil) {
            returnController = [super popViewControllerAnimated:animated];
        }
        else {
            returnController = self.topViewController;
            [self continuePopWithAnimation];
        }
    }
    else {
        returnController = [super popViewControllerAnimated:animated];
        if (self.topViewController.backImage) {
            _imageView.image = self.topViewController.backImage;
        }
    }
    
	return returnController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self presentedViewController]) {
        // 模态情况下禁止返回
        return nil;
    }
	NSArray *returnControllers = nil;
	
    if (animated && [self.topViewController isDrawerView]) {
        UIImage *image = nil;
        NSMutableArray *popedVC = [[NSMutableArray alloc] init];
        for (int i = self.viewControllers.count - 1; i >= 0; i--) {
            if (self.viewControllers[i] != viewController) {
                [popedVC insertObject:self.viewControllers[i] atIndex:0];
            }
            else {
                image = ((UIViewController *)[popedVC lastObject]).backImage;
                break;
            }
        }
        returnControllers = [NSArray arrayWithArray:popedVC];
        [self preparePopAnimation:image];
        if (_imageView.image == nil) {
            returnControllers = [super popToViewController:viewController animated:animated];
            if (self.topViewController.backImage) {
                _imageView.image = self.topViewController.backImage;
            }
        }
        else {
            [self continuePopWithAnimation:^(BOOL animated){
                [self popToViewController:viewController animated:animated];
            }];
        }
    }
    else {
        returnControllers = [super popToViewController:viewController animated:animated];
    }
    
	return returnControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    if ([self presentedViewController]) {
        // 模态情况下禁止返回
        return nil;
    }
	NSArray *returnControllers = nil;
	
    if (animated && [self.topViewController isDrawerView]) {
        UIImage *image = nil;
        NSMutableArray *popedVC = [[NSMutableArray alloc] init];
        for (int i = self.viewControllers.count - 1; i > 0; i--) {
            [popedVC insertObject:self.viewControllers[i] atIndex:0];
        }
        returnControllers = [NSArray arrayWithArray:popedVC];
        image = ((UIViewController *)[popedVC lastObject]).backImage;
        [self preparePopAnimation:image];
        if (_imageView.image == nil) {
            returnControllers = [super popToRootViewControllerAnimated:animated];
        }
        else {
            [self continuePopWithAnimation:^(BOOL animated){
                [self popToRootViewControllerAnimated:animated];
            }];
        }
    }
    else {
        returnControllers = [super popToRootViewControllerAnimated:animated];
    }
	
	return returnControllers;
}

#pragma mark Set

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    NSArray *oldArray = self.viewControllers;
    for (int i = viewControllers.count - 1; i > 0; i--) {
        UIViewController *curVC = viewControllers[i];
        UIViewController *preVC = self.viewControllers[i - 1];

        [[curVC navigationItem] setLeftBarButtonItem:[curVC backBarButtonItem]];
        
        int index = [oldArray indexOfObject:preVC];
        if (index >= 0 && index < oldArray.count - 1) {
            UIViewController *lastVC = oldArray[index + 1];
            curVC.backImage = lastVC.backImage;
        }
    }
    
    UIViewController *curLastVC = [viewControllers lastObject];
    
    if (animated && [curLastVC isDrawerView]) {
        UIViewController *oldLastVC = [oldArray lastObject];
        [self initDrawerView:oldLastVC];
        [self initBackImage:oldLastVC.backImage];
        
        UIView *curView = [self view];
        if (oldLastVC.backImage != nil) {
            if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationWillShow:)]) {
                [_tsDelegate drawerAnimationWillShow:self];
            }
            _isShowingAnimation = YES;
            switch ([curLastVC navigationStyle]) {
                case TSNavigationStyleIOS7:
                case TSNavigationStyleDrawer:
                    [_imageView removeFromSuperview];
                    [[[AppDelegate instance] window] insertSubview:_imageView belowSubview:self.view];
                    [self removeRightShadow];
                    [curView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                    break;
                case TSNavigationStyleCascade:
                    [_imageView removeFromSuperview];
                    [[[AppDelegate instance] window] addSubview:_imageView];
                    [self addRightShadow];
                    break;
                case TSNavigationStyleIOS7Pop:
                    [curView setTransform:CGAffineTransformMakeTranslation(-160, 0)];
                    [_imageView removeFromSuperview];
                    [[[AppDelegate instance] window] addSubview:_imageView];
                    [self addLeftShadow2View:_imageView];
                    
                default:
                    break;
            }
            [super setViewControllers:viewControllers animated:NO];
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(void) {
                                 switch ([curLastVC navigationStyle]) {
                                     case TSNavigationStyleIOS7:
                                         [_imageView setTransform:CGAffineTransformMakeTranslation(-160, 0)];
                                         [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                         break;
                                     case TSNavigationStyleDrawer:
                                         [_imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                                         _imageView.alpha = 0.6;
                                         [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                         break;
                                     case TSNavigationStyleCascade:
                                         [_imageView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.75, 0.75), CGAffineTransformMakeTranslation(-240, 0))];
                                         break;
                                     case TSNavigationStyleIOS7Pop:
                                         [_imageView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                                         [curView setTransform:CGAffineTransformIdentity];
                                         break;
                                         
                                     default:
                                         break;
                                 }
                             }
                             completion:^(BOOL finish) {
                                 _imageView.image = self.topViewController.backImage;
                                 _isShowingAnimation = NO;
                                 if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationDidEnd:)]) {
                                     [_tsDelegate drawerAnimationDidEnd:self];
                                 }
                             }
             ];
            return;
        }
    }
    else {
        [self initBackImage:curLastVC.backImage];
    }
    [super setViewControllers:viewControllers animated:animated];
    if (self.topViewController.backImage) {
        _imageView.image = self.topViewController.backImage;
    }
}

#pragma mark Gesture

- (void)HandlePan:(UIPanGestureRecognizer*)panGestureRecognizer{
    UIView *curView = [self view];
    
    CGPoint translation = [panGestureRecognizer translationInView:self.imageView];
    //    NSLog(@"x:%.2f", translation.x);
    
    if ([[self viewControllers] count] > 1) {
        if (translation.x > 0) {
            if (!_isShowingAnimation) {
                if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationWillShow:)]) {
                    [_tsDelegate drawerAnimationWillShow:self];
                }
                _isShowingAnimation = YES;
                [self addLeftShadow2View:curView];
            }
            
            UIViewController *viewController = [self topViewController];
            switch ([viewController navigationStyle]) {
                case TSNavigationStyleIOS7: {
                    double translatedX = translation.x / 2.0f - 160;
                    [_imageView setTransform:CGAffineTransformMakeTranslation(translatedX, 0)];
                    [curView setTransform:CGAffineTransformMakeTranslation(translation.x, 0)];
                    break;
                }
                case TSNavigationStyleDrawer: {
                    double scale = MIN(1.0f, 0.95 + translation.x / 4000);
                    [_imageView setTransform:CGAffineTransformMakeScale(scale, scale)];
                    double alpha = MIN(1.0f, 0.6 + translation.x / 500);
                    _imageView.alpha = alpha;
                    [curView setTransform:CGAffineTransformMakeTranslation(translation.x, 0)];
                    break;
                }
                case TSNavigationStyleCascade: {
                    double scale = MIN(1.0f, 0.75f + translation.x / 320 * 0.25f);
                    [_imageView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale), CGAffineTransformMakeTranslation(translation.x - 320 + 80, 0))];
                    break;
                }
                    
                default:
                    break;
            }
        }
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (translation.x > 100) {
                [self.topViewController backToPreviousViewController];
            }else{
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
    if (![lastViewController isDrawerView] || ![lastViewController canSlideBack] || lastViewController.backImage == nil || _imageView == nil || _imageView.image == nil) {
        return NO;
    }
    CGPoint translation = [_panGestureRecognier translationInView:self.imageView];
    //    NSLog(@"x:%.2f", translation.x);
    return translation.x > 0;
}

- (void)continuePopWithAnimation
{
    [self continuePopWithAnimation:^(BOOL animated) {
        [self popViewControllerAnimated:animated];
    }];
}

- (void)continuePopWithAnimation:(void(^)(BOOL animated))action
{
    UIView *curView = [self view];
    UIViewController *viewController = [self topViewController];
    if (_imageView.image == nil) {
        _isShowingAnimation = NO;
        action(YES);
        return;
    }
    if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationWillShow:)]) {
        [_tsDelegate drawerAnimationWillShow:self];
    }
    _isShowingAnimation = YES;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         switch ([viewController navigationStyle]) {
                             case TSNavigationStyleIOS7:
                             case TSNavigationStyleIOS7Pop:
                                 [_imageView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                 [curView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                                 break;
                             case TSNavigationStyleDrawer:
                                 _imageView.alpha = 1;
                                 [_imageView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                 [curView setTransform:CGAffineTransformMakeTranslation(320, 0)];
                                 break;
                             case TSNavigationStyleCascade:
                                 [_imageView setTransform:CGAffineTransformIdentity];
                                 break;
                                 
                             default:
                                 break;
                         }
                     }completion:^(BOOL finish){
                         [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                         action(NO);
                         UIViewController *viewController = [self topViewController];
                         _tsDelegate = viewController;
                         switch ([viewController navigationStyle]) {
                             case TSNavigationStyleIOS7:
                             case TSNavigationStyleDrawer:
                             case TSNavigationStyleIOS7Pop:
                                 [_imageView removeFromSuperview];
                                 [[[AppDelegate instance] window] insertSubview:_imageView belowSubview:self.view];
                                 [self removeRightShadow];
                                 [self removeLeftShadow];
                                 _isShowingAnimation = NO;
                                 _imageView.image = viewController.backImage;
                                 if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationDidEnd:)]) {
                                     [_tsDelegate drawerAnimationDidEnd:self];
                                 }
                                 break;
                             case TSNavigationStyleCascade: {
                                 [_imageView removeFromSuperview];
                                 [[[AppDelegate instance] window] addSubview:_imageView];
                                 if (self.viewControllers.count == 1) {
                                     _isShowingAnimation = NO;
                                     if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationDidEnd:)]) {
                                         [_tsDelegate drawerAnimationDidEnd:self];
                                     }
                                     return;
                                 }
                                 [self addRightShadow];
                                 [_imageView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.67, 0.67), CGAffineTransformMakeTranslation(-320, 0))];
                                 [UIView animateWithDuration:0.25
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^(void){
                                                      switch ([viewController navigationStyle]) {
                                                          case TSNavigationStyleIOS7:
                                                              break;
                                                          case TSNavigationStyleDrawer:
                                                              break;
                                                          case TSNavigationStyleCascade:
                                                              [_imageView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.75, 0.75), CGAffineTransformMakeTranslation(-240, 0))];
                                                              break;
                                                              
                                                          default:
                                                              break;
                                                      }
                                                  } completion:^(BOOL finish){
                                                      _isShowingAnimation = NO;
                                                      _imageView.image = viewController.backImage;
                                                      if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationDidEnd:)]) {
                                                          [_tsDelegate drawerAnimationDidEnd:self];
                                                      }
                                                  }];
                                 break;
                             }
                                 
                             default:
                                 _isShowingAnimation = NO;
                                 break;
                         }
                     }];
}

- (void)cancelPopWithAnimation
{
    UIView *curView = [self view];
    UIViewController *viewController = [self topViewController];
    if ([viewController navigationStyle] != TSNavigationStyleCascade && CGAffineTransformIsIdentity(curView.transform)) {
        return;
    }
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         switch ([viewController navigationStyle]) {
                             case TSNavigationStyleIOS7:
                             case TSNavigationStyleIOS7Pop:
                                 [_imageView setTransform:CGAffineTransformMakeTranslation(-160, 0)];
                                 [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                 break;
                             case TSNavigationStyleDrawer:
                                 _imageView.alpha = 0.95;
                                 [_imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                                 [curView setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                 break;
                             case TSNavigationStyleCascade:
                                 [_imageView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.75, 0.75), CGAffineTransformMakeTranslation(-240, 0))];
                                 break;
                                 
                             default:
                                 break;
                         }
                     }completion:^(BOOL finish){
                         _isShowingAnimation = NO;
                         if (_tsDelegate && [_tsDelegate respondsToSelector:@selector(drawerAnimationDidEnd:)]) {
                             [_tsDelegate drawerAnimationDidEnd:self];
                         }
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
    
    if ([curView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [curView drawViewHierarchyInRect:curView.frame afterScreenUpdates:NO];
    }
    else {
        [curView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
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

- (void)addLeftShadow2View:(UIView *)superView
{
    if (!_img_shadow_left.superview) {
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        superView.clipsToBounds = NO;
        [superView addSubview:_img_shadow_left];
        [_img_shadow_left setFrame:CGRectMake(-6 , 0, 6, screenFrame.size.height)];
    }
}

- (void)removeLeftShadow
{
    [_img_shadow_left removeFromSuperview];
}

- (void)addRightShadow
{
    if (_img_shadow_down.superview || _img_shadow_right.superview || _img_shadow_up.superview) {
        return;
    }
    _imageView.clipsToBounds = NO;
    _img_shadow_up.frame = CGRectMake(0, -36, _imageView.frame.size.width, 36);
    [_imageView addSubview:_img_shadow_up];
    _img_shadow_down.frame = CGRectMake(0, _imageView.frame.size.height, _imageView.frame.size.width, 36);
    [_imageView addSubview:_img_shadow_down];
    _img_shadow_right.frame = CGRectMake(_imageView.frame.size.width, -36, 20, _imageView.frame.size.height + 36 * 2);
    [_imageView addSubview:_img_shadow_right];
}

- (void)removeRightShadow
{
    [_img_shadow_down removeFromSuperview];
    [_img_shadow_right removeFromSuperview];
    [_img_shadow_up removeFromSuperview];
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
