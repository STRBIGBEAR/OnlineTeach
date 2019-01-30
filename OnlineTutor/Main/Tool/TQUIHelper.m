//
//  TQUIHelper.m
//  OnlineTutor
//
//  Created by JiMo on 2018/8/6.
//  Copyright © 2018年 TQ. All rights reserved.
//

#import "TQUIHelper.h"

@implementation TQUIHelper


static NSInteger isIPad = -1;

+ (BOOL)isIPad {
    if (isIPad < 0) {
        // [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] 无法判断模拟器，改为以下方式
        isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0;
    }
    return isIPad > 0;
}

+ (CGFloat)adjustToWidth:(CGFloat)width
{
    if (IS_IPAD) {
        return kAUTOSCALE_IPAD_WIDTH(width);
    }else{
        return kAUTOSCALE_WIDTH(width);
    }
}

@end
