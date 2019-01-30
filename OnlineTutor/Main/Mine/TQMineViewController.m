//
//  TQMineViewController.m
//  OnlineTutor
//
//  Created by JiMo on 2018/8/3.
//  Copyright © 2018年 TQ. All rights reserved.
//

#import "TQMineViewController.h"

@interface TQMineViewController ()



@end

@implementation TQMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    [self creatUI];
}

- (void)creatUI
{
    UIImageView *headView = [[UIImageView alloc] init];
    headView.image = [UIImage imageNamed:@"1f374317852071e19c786f6e60793dae.jpg"];
    headView.clipsToBounds = YES;
    headView.layer.cornerRadius = 40;
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.text = @"张老师";
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = [UIColor blackColor];
    [self.view addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.text = @"张老师带你学英语";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.textColor = [UIColor blackColor];
    [self.view addSubview:tipLabel];
    
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
