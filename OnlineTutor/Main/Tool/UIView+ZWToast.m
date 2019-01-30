//
//  UIView+ZWToast.m
//  AiYiGe
//
//  Created by Ben on 16/12/14.
//  Copyright © 2016年 中舞网. All rights reserved.
//

#import "UIView+ZWToast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static const CGFloat ToastMaxWidth            = 0.8;      // 80% of parent view width
static const CGFloat ToastMaxHeight           = 0.8;      // 80% of parent view height
static const CGFloat ToastHorizontalPadding   = 10.0;
static const CGFloat ToastVerticalPadding     = 10.0;
static const CGFloat ToastCornerRadius        = 2.0;
static const CGFloat ToastOpacity             = 0.8;
static const CGFloat ToastFontSize            = 16.0;
static const CGFloat ToastMaxTitleLines       = 0;
static const CGFloat ToastMaxMessageLines     = 0;
static const NSTimeInterval ToastFadeDuration = 0.2;

// shadow appearance
static const CGFloat ToastShadowOpacity       = 1;
static const CGFloat ToastShadowRadius        = 2.0;
static const CGSize  ToastShadowOffset        = { 0.0, 6.0 };
static const BOOL    ToastDisplayShadow       = YES;

// display duration
static const NSTimeInterval ToastDefaultDuration  = 1.5;

// image view size
static const CGFloat ToastImageViewWidth      = 80.0;
static const CGFloat ToastImageViewHeight     = 80.0;

// activity
static const CGFloat ToastActivityWidth       = 100.0;
static const CGFloat ToastActivityHeight      = 100.0;
static const NSString * ToastActivityDefaultPosition = @"center";

// interaction
static const BOOL ToastHidesOnTap             = YES;     // excludes activity views

// associative reference keys
static const NSString * ToastTimerKey         = @"CSToastTimerKey";
static const NSString * ToastActivityViewKey  = @"CSToastActivityViewKey";
static const NSString * ToastTapCallbackKey   = @"CSToastTapCallbackKey";

// positions
NSString * const ToastPositionTop             = @"top";
NSString * const ToastPositionCenter          = @"center";
NSString * const ToastPositionBottom          = @"bottom";

@interface UIView (ZWToastPrivate)

- (void)hideToastWithView:(UIView *)toastView;
- (void)toastTimerDidFinish:(NSTimer *)timer;
- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer;
- (CGPoint)centerPointForPosition:(id)position withToast:(UIView *)toast;
- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;
- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end


@implementation UIView (ZWToast)

- (void)dismissToastWithView:(UIView *)toastView
{
    [self hideToastWithView:toastView];
}

- (UIView *)showToastWithMessage:(NSString *)message orientation:(UIInterfaceOrientation)orientation
{
    _orientation = orientation;
    UIView *toast = [self viewForMessage:message title:nil image:nil];
    [self showToastWithView:toast duration:ToastDefaultDuration position:ToastPositionCenter];
    
    return toast;
}

- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)interval position:(id)position orientation:(UIInterfaceOrientation)orientation
{
    _orientation = orientation;
    UIView *toast = [self viewForMessage:message title:nil image:nil];
    [self showToastWithView:toast duration:interval position:position];
    
    return toast;
}

- (UIView *)showToastWithMessage:(NSString *)message {
    UIView *toast = [self showToastWithMessage:message duration:ToastDefaultDuration position:ToastPositionCenter];
    
    return toast;
}

- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration position:(id)position {
    UIView *toast = [self viewForMessage:message title:nil image:nil];
    [self showToastWithView:toast duration:duration position:position];
    
    return toast;
}

- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title {
    UIView *toast = [self viewForMessage:message title:title image:nil];
    [self showToastWithView:toast duration:duration position:position];
    
    return toast;
}

- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration position:(id)position image:(UIImage *)image {
    UIView *toast = [self viewForMessage:message title:nil image:image];
    [self showToastWithView:toast duration:duration position:position];
    
    return toast;
}

- (UIView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration  position:(id)position title:(NSString *)title image:(UIImage *)image {
    UIView *toast = [self viewForMessage:message title:title image:image];
    [self showToastWithView:toast duration:duration position:position];
    
    return toast;
}

- (void)showToastWithView:(UIView *)toastView {
    [self showToastWithView:toastView duration:ToastDefaultDuration position:nil];
}


- (void)showToastWithView:(UIView *)toastView duration:(NSTimeInterval)duration position:(id)position {
    [self showToastWithView:toastView duration:duration position:position tapCallback:nil];
    
}


- (void)showToastWithView:(UIView *)toastView duration:(NSTimeInterval)duration position:(id)position
              tapCallback:(void(^)(void))tapCallback
{
    toastView.center = [self centerPointForPosition:position withToast:toastView];
    toastView.alpha = 0.0;
    
    if (ToastHidesOnTap) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:toastView action:@selector(handleToastTapped:)];
        [toastView addGestureRecognizer:recognizer];
        toastView.userInteractionEnabled = YES;
        toastView.exclusiveTouch = YES;
    }
    
    [self addSubview:toastView];
    
    [UIView animateWithDuration:ToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toastView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [self hideToastWithView:toastView];
                         //                         NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(toastTimerDidFinish:) userInfo:toastView repeats:NO];
                         // associate the timer with the toast view
                         //                         objc_setAssociatedObject (toastView, &ToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         objc_setAssociatedObject (toastView, &ToastTapCallbackKey, tapCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}


- (void)hideToastWithView:(UIView *)toastView {
    
    [UIView animateWithDuration:ToastFadeDuration
                          delay:ToastDefaultDuration
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toastView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toastView removeFromSuperview];
                     }];
}

#pragma mark - Events

- (void)toastTimerDidFinish:(NSTimer *)timer {
    [self hideToastWithView:(UIView *)timer.userInfo];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, &ToastTimerKey);
    [timer invalidate];
    
    void (^callback)(void) = objc_getAssociatedObject(self, &ToastTapCallbackKey);
    if (callback) {
        callback();
    }
    [self hideToastWithView:recognizer.view];
}

#pragma mark - Toast Activity Methods

- (void)showToastActivity {
    [self showToastActivity:ToastActivityDefaultPosition];
}

- (void)showToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &ToastActivityViewKey);
    if (existingActivityView != nil) return;
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ToastActivityWidth, ToastActivityHeight)];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:ToastOpacity];
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = ToastCornerRadius;
    
    if (ToastDisplayShadow) {
        activityView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
        activityView.layer.shadowOpacity = ToastShadowOpacity;
        activityView.layer.shadowRadius = ToastShadowRadius;
        activityView.layer.shadowOffset = ToastShadowOffset;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    // associate the activity view with self
    objc_setAssociatedObject (self, &ToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addSubview:activityView];
    
    [UIView animateWithDuration:ToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)hideToastActivity {
    
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &ToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:ToastFadeDuration
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &ToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

#pragma mark - Helpers

- (CGPoint)centerPointForPosition:(id)point withToast:(UIView *)toast {
    if([point isKindOfClass:[NSString class]]) {
        if([point caseInsensitiveCompare:ToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + ToastVerticalPadding);
        } else if([point caseInsensitiveCompare:ToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    // default to bottom
    return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - ToastVerticalPadding);
}

- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode {
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        CGRect boundingRect = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return CGSizeMake(ceilf(boundingRect.size.width), ceilf(boundingRect.size.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [string sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
}

- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image {
    if (_toastView)
    {
        [self hideToastWithView:_toastView];
    }
    // sanity
    if((message == nil) && (title == nil) && (image == nil)) return nil;
    
    // dynamically build a toast view with any combination of message, title, & image.
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = ToastCornerRadius;
    
    if (ToastDisplayShadow) {
        wrapperView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
        wrapperView.layer.shadowOpacity = ToastShadowOpacity;
        wrapperView.layer.shadowRadius = ToastShadowRadius;
        wrapperView.layer.shadowOffset = ToastShadowOffset;
    }
    
    wrapperView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:ToastOpacity];
    
    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(ToastHorizontalPadding, ToastVerticalPadding, ToastImageViewWidth, ToastImageViewHeight);
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = ToastHorizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = ToastMaxTitleLines;
        titleLabel.font = [UIFont boldSystemFontOfSize:ToastFontSize];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * ToastMaxWidth) - imageWidth, self.bounds.size.height * ToastMaxHeight);
        CGSize expectedSizeTitle = [self sizeForString:title font:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = ToastMaxMessageLines;
        messageLabel.font = [UIFont systemFontOfSize:ToastFontSize];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * ToastMaxWidth) - imageWidth, self.bounds.size.height * ToastMaxHeight);
        CGSize expectedSizeMessage = [self sizeForString:message font:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = ToastVerticalPadding;
        titleLeft = imageLeft + imageWidth + ToastHorizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;
    
    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + ToastHorizontalPadding;
        messageTop = titleTop + titleHeight + ToastVerticalPadding;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }
    
    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (ToastHorizontalPadding * 2)), (longerLeft + longerWidth + ToastHorizontalPadding));
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + ToastVerticalPadding), (imageHeight + (ToastVerticalPadding * 2)));
    
    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
    
    if(titleLabel != nil) {
        titleLabel.frame = CGRectMake(titleLeft, titleTop, messageWidth, titleHeight);
        [wrapperView addSubview:titleLabel];
    }
    
    if(messageLabel != nil) {
        messageLabel.frame = CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
        [wrapperView addSubview:messageLabel];
    }
    
    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (_orientation != UIInterfaceOrientationUnknown){
        orientation = _orientation;
    }else{
        orientation = UIInterfaceOrientationUnknown;
    }
    
    if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        wrapperView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
        wrapperView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    else
    {
        wrapperView.transform = CGAffineTransformIdentity;
    }
    
    _orientation = UIInterfaceOrientationUnknown;
    
    _toastView = wrapperView;
    
    return wrapperView;
}

static UIInterfaceOrientation _orientation;
static UIView *_toastView;

@end
