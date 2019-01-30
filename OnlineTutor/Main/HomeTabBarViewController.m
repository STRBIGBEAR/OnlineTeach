//
//  HomeTabBarViewController.m
//  DouBo_Live
//
//  Created by coco on 16/12/29.
//  Copyright © 2016年 wby. All rights reserved.
//

#import "HomeTabBarViewController.h"
#import "HomeTabBarView.h"
#import "TQMineViewController.h"
#import "TQMainViewController.h"
#import "Masonry.h"

@interface HomeTabBarViewController ()

@property (nonatomic, assign) BOOL  fristLaunch;

@property (nonatomic, strong) HomeTabBarView *homeTabbarView;

@end

@implementation HomeTabBarViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initViewControllers];
    }
    return self;
}
- (void)initViewControllers{
    
    NSArray *vcNames = @[@"TQMainViewController",@"TQMineViewController"];

    NSMutableArray *viewcontrollers = [NSMutableArray array];
    for (NSString *className in vcNames) {
        UIViewController *vc = [[NSClassFromString(className) alloc]init];
        [viewcontrollers addObject:vc];
    }
    self.viewControllers = viewcontrollers;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
   

    self.fristLaunch = YES;
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.tabBar.hidden = YES;
    self.selectedIndex = 0;

   
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.homeTabbarView = [[HomeTabBarView alloc]init];
    [self.view addSubview:self.homeTabbarView];
    
    if (IPHONEX) {
        [self.homeTabbarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(65);
            make.left.right.bottom.mas_equalTo(0);
        }];
    } else {
        [self.homeTabbarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(50);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    
    __weak typeof(self)weakSelf = self;
    [self.homeTabbarView setClickBlocks:^(NSInteger index){
        [weakSelf setSelectedIndex:index-1];
    }];
}



@end
