//
//  BaseViewController.h
//  DouBoPlayer
//
//  Created by macdev on 2017/3/20.
//  Copyright © 2017年 wby. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger navBarH = 60;

@interface BaseViewController : UIViewController

@property (nonatomic,strong) UIButton *leftItemBtn;

@property (nonatomic,strong) UIButton *rightItemBtn;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *backTipLabel;

@property (nonatomic,strong) UIView  *customNavBar;

- (void)hidenBottomLine;

- (CGFloat)getTabBarHeight;

- (void)hidenNavBar;

- (void)addDefaultBackItem;

- (void)setNavBarTitle:(NSString *)title;

- (void)setLeftItemTitle:(NSString *)title;

- (void)setLeftItemImage:(NSString *)imageName;

- (void)setRightItemTitle:(NSString *)title;

- (void)setRightItemImage:(NSString *)imageName;

- (void)leftItemAction:(id)sender;

- (void)rightItemAction:(id)sender;

-(BOOL) IsFirstTimeDisplay;

@end
