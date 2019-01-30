//
//  HomeTabBarView.h
//  DouBo_Live
//
//  Created by macdev on 2017/8/17.
//  Copyright © 2017年 ngmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTabBarView : UIView

@property (nonatomic,copy) void  (^clickBlocks)(NSInteger tag);


@property (nonatomic,assign) NSInteger selectIndex;

- (void)clickBtn:(UIButton *)sender;

@end
