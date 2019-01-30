//
//  TQConectServerView.m
//  OnlineTutor
//
//  Created by JiMo on 2018/8/4.
//  Copyright © 2018年 TQ. All rights reserved.
//

#import "TQConectServerView.h"
#import "HYSocketService.h"


@interface TQConectServerView ()<UITextFieldDelegate>
{
}

@property(nonatomic,strong)UIView          *bgView;

@property (nonatomic, strong)UIButton    *serverBtn;     // 选择按钮
@property (nonatomic, strong)UIButton    *refreshPortBtn;// 刷新端口号

@property (nonatomic, strong)UIButton    *clientBtn;     // 选择按钮
@property (nonatomic, strong)UITextField *clientTf;      // 输入连接服务器的地址



@end


@implementation TQConectServerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self creatUI];
       
    }
    return self;
}




- (void)creatUI
{
    
  
    
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.mas_equalTo([TQUIHelper adjustToWidth:200]);
        make.width.mas_equalTo([TQUIHelper adjustToWidth:400]);
    }];
    
    [self.bgView addSubview:self.serverBtn];
    [self.bgView addSubview:self.clientBtn];
    
    [self.serverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(40);
        make.left.equalTo(self.bgView).offset(40);
        make.right.equalTo(self.bgView).offset(-40);
        make.height.mas_equalTo(40);
    }];
    
    [self.clientBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.serverBtn.mas_bottom).offset(40);
        make.left.equalTo(self.bgView).offset(40);
        make.right.equalTo(self.bgView).offset(-40);
        make.height.mas_equalTo(40);
    }];
    
   
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField.text.length < 1) {
        textField.text = [HYSocketService getIPAddress:YES];
    }
    
    return YES;
}

// 输入ip地址完成
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.loadingLb.text = @"连接中...";
    
    // 连接服务器
    NSMutableString *text = [[NSMutableString alloc] initWithString:textField.text];
    NSArray *strArr = [text componentsSeparatedByString:@" "];
    if (strArr.count != 2) {
        self.loadingLb.text = @"ip输入格式有误,例:172.168.2.2 43999";
        return ;
    }
    if (self.startConect) {
        self.startConect(strArr);
    }
    
}


#pragma mark - Private methods

// 选择按钮点击事件
- (void)_didClickButton:(UIButton *)sender {
    
    // 服务器
    if (sender.tag == 100) {
        self.serverBtn.hidden = YES;
        self.clientBtn.hidden = YES;
        
        [self.bgView addSubview:self.serverLb];
        [self.serverLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView).offset(40);
            make.left.right.equalTo(self.bgView);
            make.height.mas_equalTo(40);
        }];
     
        [self.bgView addSubview:self.refreshPortBtn];
        [self.refreshPortBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.serverLb.mas_bottom).offset(40);
            make.left.equalTo(self.bgView).offset(40);
            make.right.equalTo(self.bgView).offset(-40);

            make.height.mas_equalTo(40);
        }];
       
        if (self.startSettingServer) {
            self.startSettingServer();
        }
        
    }
    else if (sender.tag == 110) {
        // 刷新端口号
        if (self.refreshPort) {
            self.refreshPort();
        }
    }
   
    else if (sender.tag == 200) { // 客户端
        self.serverBtn.hidden = YES;
        self.clientBtn.hidden = YES;
        
        [self.bgView addSubview:self.clientTf];
        [self.clientTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView).offset(40);
            make.left.right.equalTo(self.bgView);
            make.height.mas_equalTo(40);
        }];
        
        [self.bgView addSubview:self.loadingLb];
        [self.loadingLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.clientTf.mas_bottom).offset(40);
            make.left.right.equalTo(self.bgView);
            make.height.mas_equalTo(40);
        }];

    }
    
}


#pragma mark - Property

// 选择按钮（服务器）
- (UIButton *)serverBtn {
    if (_serverBtn == nil) {
        _serverBtn = [UIButton new];
        [_serverBtn setTitle:@"将此设备设置为服务器" forState:UIControlStateNormal];
        [_serverBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _serverBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _serverBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _serverBtn.layer.borderWidth = 0.5f;
        _serverBtn.tag = 100;
        [_serverBtn addTarget:self action:@selector(_didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _serverBtn;
}

// 显示服务器ip地址
- (UILabel *)serverLb {
    if (_serverLb == nil) {
        _serverLb = [UILabel new];
        _serverLb.textAlignment = NSTextAlignmentCenter;
        _serverLb.font = [UIFont systemFontOfSize:15.f];
        _serverLb.numberOfLines = 0;

    }
    
    return _serverLb;
}

// 刷新服务器端口号
- (UIButton *)refreshPortBtn {
    if (_refreshPortBtn == nil) {
        _refreshPortBtn = [UIButton new];
        [_refreshPortBtn setTitle:@"刷新端口号" forState:UIControlStateNormal];
        [_refreshPortBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _refreshPortBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _refreshPortBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _refreshPortBtn.layer.borderWidth = 1.f;
        _refreshPortBtn.tag = 110;
        [_refreshPortBtn addTarget:self action:@selector(_didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _refreshPortBtn;
}

// 选择按钮（客户端）
- (UIButton *)clientBtn {
    if (_clientBtn == nil) {
        _clientBtn = [UIButton new];
        [_clientBtn setTitle:@"将此设备设置为客户端" forState:UIControlStateNormal];
        [_clientBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _clientBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _clientBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _clientBtn.layer.borderWidth = 0.5f;
        _clientBtn.tag = 200;
        [_clientBtn addTarget:self action:@selector(_didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _clientBtn;
}

// 输入连接服务器的地址
- (UITextField *)clientTf {
    if (_clientTf == nil) {
        _clientTf = [UITextField new];
        _clientTf.placeholder = @"输入服务器ip地址和端口(ip和端口用空格隔开)";
        _clientTf.delegate = self;
        _clientTf.textAlignment = NSTextAlignmentCenter;
        _clientTf.font = [UIFont systemFontOfSize:14.f];
        _clientTf.borderStyle = UITextBorderStyleLine;
        _clientTf.returnKeyType = UIReturnKeyDone;
    }
    
    return _clientTf;
}

// loading...
- (UILabel *)loadingLb {
    if (_loadingLb == nil) {
        _loadingLb = [UILabel new];
        _loadingLb.textAlignment = NSTextAlignmentCenter;
        _loadingLb.font = [UIFont systemFontOfSize:15.f];
        _loadingLb.numberOfLines = 0;
        
    }
    
    return _loadingLb;
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.clipsToBounds = YES;
        _bgView.layer.cornerRadius = 10;
    }
    return _bgView;
}


- (UIViewController *)belongViewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)close
{
    if (self.dismiss) {
        self.dismiss();
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    
    point = [_bgView.layer convertPoint:point fromLayer:self.layer];
    if ([_bgView.layer containsPoint:point]) {
        [self endEditing:YES];
    }else{
        [self endEditing:YES];
        [self close];
    }
}
- (void)showCard
{
    UIWindow *window=[[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
}

- (void)dealloc{
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
