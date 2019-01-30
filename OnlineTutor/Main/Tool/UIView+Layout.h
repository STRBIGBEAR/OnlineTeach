//
//  UIView+Layout.h
//  VideoPlay
//
//  Created by Peng Sheng on 15/11/7.
//  Copyright © 2015年 WangLi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IPAD [TQUIHelper isIPad]

#define kAUTOSCALE_IPAD_WIDTH(width) (width) * kSCREEN_WIDTH/1024.00

#define kAUTOSCALE_FONT(fontSize) (fontSize) * (kFONT_SCALE_VALUE)
#define kAUTOSCALE_WIDTH(width) (width) * kSCREEN_WIDTH/667.00
#define kAUTOSCALE_HEIGHT(height) (height) * kSCREEN_HEIGHT/375.00

#define kFONT_SCALE_VALUE kSCREEN_HEIGHT >= 667?(kSCREEN_WIDTH/375):1

#define kSCREEB_SCALE_VALUE kSCREEN_WIDTH/kSCREEN_HEIGHT


//当前设备屏幕宽高
#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define IPHONEX [UIScreen mainScreen].bounds.size.height == 812||[UIScreen mainScreen].bounds.size.width == 812 ? YES:NO

@interface UIView (Layout)

@property (assign, nonatomic) CGFloat    top;
@property (assign, nonatomic) CGFloat    bottom;
@property (assign, nonatomic) CGFloat    left;
@property (assign, nonatomic) CGFloat    right;

@property (assign, nonatomic) CGFloat    x;
@property (assign, nonatomic) CGFloat    y;
@property (assign, nonatomic) CGPoint    origin;

@property (assign, nonatomic) CGFloat    centerX;
@property (assign, nonatomic) CGFloat    centerY;

@property (assign, nonatomic) CGFloat    width;
@property (assign, nonatomic) CGFloat    height;
@property (assign, nonatomic) CGSize    size;


@end
