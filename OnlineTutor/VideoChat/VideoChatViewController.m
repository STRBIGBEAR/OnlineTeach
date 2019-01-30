//
//  VideoChatViewController.m
//  DouBo_Live
//
//  Created by JiMo on 2017/8/23.
//  Copyright © 2017年 ngmob. All rights reserved.
//

#import "VideoChatViewController.h"
#import "VideoChatPreView.h"

@interface VideoChatViewController ()

@property(nonatomic,strong)VideoChatPreView *videoChatView;

@end

@implementation VideoChatViewController

- (void)dealloc
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.videoChatView.session.running = NO;
    [self.videoChatView.session leaveChannel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.videoChatView];
    
    
}

- (VideoChatPreView *)videoChatView
{
    if (!_videoChatView) {
        _videoChatView = [[VideoChatPreView alloc]initWithFrame:self.view.bounds];
    }
    return _videoChatView;
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
