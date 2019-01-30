//
//  CustomGPUImageFilter.h
//  DouBo_Live
//
//  Created by JiMo on 2017/8/23.
//  Copyright © 2017年 ngmob. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

@interface CustomGPUImageFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}

- (id)initWithImage:(UIImage *)image;

@end
