//
//  DrawerView.m
//  DrawerFrame
//
//  Created by Johnson Zhang on 13-3-28.
//  Copyright (c) 2013年 Theosoft. All rights reserved.
//

#import "DrawerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DrawerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithView:(UIView *)contentView parentView:(UIView *)parentView{
    
    self = [super initWithFrame:CGRectMake(0,0,contentView.frame.size.width, contentView.frame.size.height)];
    if (self) {
        [self addSubview:contentView];
        UIPanGestureRecognizer *panGestureRecognier = [[UIPanGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(HandlePan:)];
        [self addGestureRecognizer:panGestureRecognier];
        
        if (UIGraphicsBeginImageContextWithOptions != NULL) {
            UIGraphicsBeginImageContextWithOptions(parentView.frame.size, NO, 0.0);
        }
        else {
            UIGraphicsBeginImageContext(parentView.frame.size);
        }
        
        [parentView.layer renderInContext:UIGraphicsGetCurrentContext()];
        lastViewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageView = [[UIImageView alloc]initWithImage:lastViewImage];
        imageView.frame  = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:imageView];
    }
    
    self.parentView = parentView;
    return self;
}


//- (void)HandlePan:(UIPanGestureRecognizer*)panGestureRecognizer{
//    
//    CGPoint translation = [panGestureRecognizer translationInView:self.parentView];
//    float x = self.center.x + translation.x;
//    if (x < 160) {
//        x = 160;
//    }
//    
//    if(translation.x > 0){
//        if (!isPanComment) {
//            self.center = CGPointMake(x, 230);
//        }
//    }
//    
//    if (translation.x < 0 && self.center.x > 160) {
//        if (!isPanComment) {
//            self.center = CGPointMake(x, 230);
//        }
//    }else if(translation.x < 0){
//        isPanComment = YES;
//        commentView.center = CGPointMake(commentView.center.x + translation.x, 230);
//    }
//    
//    if (commentView.center.x < 480 && translation.x > 0) {
//        isPanComment = YES;
//        commentView.center = CGPointMake(commentView.center.x + translation.x, 230);
//    }
//    
//    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
//        if (commentView.center.x < 400) {
//            [UIView animateWithDuration:0.4
//                                  delay:0.1
//                                options:UIViewAnimationCurveEaseInOut
//                             animations:^(void){
//                                 commentView.center = CGPointMake(160, 230);
//                             }completion:^(BOOL finish){
//                                 isPanComment = NO;
//                             }];
//        }else{
//            [UIView animateWithDuration:0.4
//                                  delay:0.1
//                                options:UIViewAnimationCurveEaseInOut
//                             animations:^(void){
//                                 commentView.center = CGPointMake(480, 230);
//                             }completion:^(BOOL finish){
//                                 isPanComment = NO;
//                             }];
//        }
//        if (self.center.x > 190) {
//            [UIView animateWithDuration:0.4
//                                  delay:0.1
//                                options:UIViewAnimationCurveEaseInOut
//                             animations:^(void){
//                                 self.center = CGPointMake(480, 230);
//                             }completion:^(BOOL finish){
//                                 [self.parentView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
//                             }];
//        }else{
//            [UIView animateWithDuration:0.4
//                                  delay:0.1
//                                options:UIViewAnimationCurveEaseInOut
//                             animations:^(void){
//                                 self.center = CGPointMake(160, 230);
//                             }completion:^(BOOL finish){
//                                 
//                             }];
//            
//        }
//        
//    }
//    
//    [panGestureRecognizer setTranslation:CGPointZero inView:self.parentView];
//    
//}
//
//- (void) back:(id)sender{
//    [UIView animateWithDuration:0.4
//                          delay:0.1
//                        options:UIViewAnimationCurveEaseInOut
//                     animations:^(void){
//                         self.center = CGPointMake(480, 230);
//                     }completion:^(BOOL finish){
//                         [self.parentView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
//                     }];
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
