//
//  HomeTabBarView.m
//  DouBo_Live
//
//  Created by macdev on 2017/8/17.
//  Copyright © 2017年 ngmob. All rights reserved.
//

#import "HomeTabBarView.h"

@interface HomeTabBarView()
{
    UIButton *_messageItemBtn;
}

@property (nonatomic,strong) NSArray *normalImgs;
@end
@implementation HomeTabBarView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.normalImgs = @[@"home",@"my"];
        NSArray * selectImgs = @[@"sel_home", @"sel_my"];
        CGFloat marginSide = 10;
        CGFloat tabBarWidth = (kSCREEN_WIDTH - marginSide * 2)/self.normalImgs.count;
        UIButton *lastItem;
        self.backgroundColor = [UIColor colorWithHexString:@"1f1f25"];
        for (int i = 1;i<= self.normalImgs.count;i++)
        {
            UIButton *ItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            ItemBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            ItemBtn.tag = i;
            [self addSubview:ItemBtn];
            [ItemBtn setImage:[UIImage imageNamed:self.normalImgs[i-1]] forState:UIControlStateNormal];
            [ItemBtn setImage:[UIImage imageNamed:selectImgs[i-1]] forState:UIControlStateSelected];
            ItemBtn.imageView.contentMode = UIViewContentModeCenter;
            [ItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastItem) {
                    make.left.equalTo(lastItem.mas_right);
                }
                else{
                    make.left.mas_equalTo(marginSide);
                }
                make.width.mas_equalTo(tabBarWidth);
                
                if (IPHONEX) {
                    make.centerY.equalTo(self).offset(-7.5);
                }else{
                    make.centerY.equalTo(self);
                }
                if (i == 3) {
                    ItemBtn.imageEdgeInsets = UIEdgeInsetsMake(-7, 0, 7, 0);
                    make.height.mas_equalTo(57);
                }
                else{
                    make.height.equalTo(self);
                }
                
            }];
            [ItemBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            lastItem = ItemBtn;
        }
        [self clickBtn:[self viewWithTag:1]];
        
    }
    return self;
}



- (void)clickBtn:(UIButton *)sender
{
   
    
    if (sender.selected) {
        return;
    }
    [self resetButton];
    sender.selected = YES;
    
    if (self.clickBlocks) {
        self.clickBlocks(sender.tag);
    }
    
    
}
- (void)setSelectIndex:(NSInteger)selectIndex{
    
    UIButton *btn = (UIButton *)[self viewWithTag:selectIndex+1];
    [self clickBtn:btn];
    
}
-(void)resetButton
{
    for (int i = 1; i<=self.normalImgs.count; i++) {
        UIButton *btn = [self viewWithTag:i];
        btn.selected = NO;
    }
}

- (void)toHomeTabAction:(NSNotification *)notification {
    UIButton *btn = (UIButton *)[self viewWithTag:1];
    [self clickBtn:btn];
}


@end
