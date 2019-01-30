//
//  UIView+ZWToast.h
//  AiYiGe
//
//  Created by Ben on 16/12/14.
//  Copyright © 2016年 中舞网. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const ToastPositionTop;
extern NSString * const ToastPositionCenter;
extern NSString * const ToastPositionBottom;

@interface UIView (ZWToast)

- (UIView *)showToastWithMessage:(NSString *)message;
- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)interval position:(id)position;
- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)interval position:(id)position image:(UIImage *)image;
- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)interval position:(id)position title:(NSString *)title;
- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)interval position:(id)position title:(NSString *)title image:(UIImage *)image;

- (UIView *)showToastWithMessage:(NSString *)message orientation:(UIInterfaceOrientation)orientation;

- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)interval position:(id)position orientation:(UIInterfaceOrientation)orientation;

- (void)dismissToastWithView:(UIView *)toastView;

- (void)showToastActivity;
- (void)showToastActivity:(id)position;
- (void)hideToastActivity;

- (void)showToastWithView:(UIView *)toastView;
- (void)showToastWithView:(UIView *)toastView duration:(NSTimeInterval)interval position:(id)point;
- (void)showToastWithView:(UIView *)toastView duration:(NSTimeInterval)interval position:(id)point
             tapCallback:(void(^)(void))tapCallback;

@end
