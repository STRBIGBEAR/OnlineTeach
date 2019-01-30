//
//  CustomGPUImageFilter.m
//  DouBo_Live
//
//  Created by JiMo on 2017/8/23.
//  Copyright © 2017年 ngmob. All rights reserved.
//

#import "CustomGPUImageFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation CustomGPUImageFilter

- (id)initWithImage:(UIImage *)image;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    if (image) {
        lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
        GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
        [self addFilter:lookupFilter];
        
        [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
        [lookupImageSource processImage];
        
        self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
        self.terminalFilter = lookupFilter;
    }
    
    
   
    
    return self;
}

#pragma mark -
#pragma mark Accessors

@end
