//
//  NGMVideoController.m
//  NGMVideoLive_iOS_demo
//
//  Created by JiMo on 2018/1/23.
//  Copyright © 2018年 JiMo. All rights reserved.
//

#import "NGMVideoController.h"
#import "Masonry.h"
#import "UIView+ZWToast.h"

#import "HYColorPanel.h"
#import "HYWhiteboardView.h"
#import "HYConversationManager.h"
#import "HYUploadManager.h"

#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface NGMVideoController ()<HYColorPanelDelegate, HYWbDataSource, HYConversationDelegate, HYUploadDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;          // Tutorial Step 1
@property (strong, nonatomic) UIView *localVideo;            // Tutorial Step 3
@property (strong, nonatomic) UIView *remoteVideo;           // Tutorial Step 5
@property (strong, nonatomic) UIView *controlButtons;        // Tutorial Step 8

@property (nonatomic,strong) UIImageView *localVideoBGView;
@property (nonatomic,strong) UIImageView *remoteVideoBGView;

@property (strong, nonatomic) UIImageView *remoteVideoMutedIndicator;
@property (strong, nonatomic) UIImageView *localVideoMutedBg;
@property (strong, nonatomic) UIImageView *localVideoMutedIndicator;

@property (strong, nonatomic) UIButton *videoMuteButton;
@property (strong, nonatomic) UIButton *muteButton;
@property (strong, nonatomic) UIButton *switchCameraButton;
@property (strong, nonatomic) UIButton *hangUpButton;

@property (strong, nonatomic) UIButton *backButton;
@property (nonatomic,strong) NSString *chatRoomID;

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIView *whiteBoardView;

@property (strong, nonatomic) UIButton *videoMemu;//视频操作菜单
@property (strong, nonatomic) UIButton *boardSetting;//画板设置

@property (nonatomic,assign) BOOL   showMenu;

@property (nonatomic,strong) NSMutableArray  *userArray;
@property (nonatomic,strong) NSMutableArray  *viewArray;


//白版
@property (nonatomic, strong)HYColorPanel       *colorPanel;    // 颜色盘
@property (nonatomic, strong)HYWhiteboardView   *wbView;        // 白板视图
@property (nonatomic, strong)UIImageView        *imageView;     // 图片
@property (nonatomic, strong)UIScrollView       *scrollView;    // scroll view
@property (nonatomic, strong)UIButton           *drawingBtn;    // 画笔模式开关

@property (nonatomic, assign)NSInteger          lineColorIndex; // 画线颜色的索引
@property (nonatomic, assign)NSInteger          lineWidth;      // 画线宽度

@property (nonatomic, strong)NSMutableDictionary*allLines;      // 所有画线
@property (nonatomic, strong)NSMutableArray     *cancelLines;   // 被撤销画线
@property (nonatomic, assign)BOOL               isEraser;       // 是否为橡皮模式
@property (nonatomic, assign)BOOL               needUpdate;     // 需要更新白板视图

@property (nonatomic, assign)BOOL               drawable;       // 是否可以画线

@end

@implementation NGMVideoController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // 断网
    [[HYConversationManager shared] disconnectWhiteboard];
    [[HYUploadManager shared] disconnectUpload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self leaveChannel];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [HYConversationManager shared].converDelegate = self;
    [HYUploadManager shared].delegate = self;
    self.userArray = [NSMutableArray array];
    self.viewArray = [NSMutableArray array];
    
    self.chatRoomID = @"bankLiveDemo";
    [self hidenNavBar];
    self.showMenu = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self layoutUI];
  
    [self setupButtons];            // Tutorial Step 8
    [self hideVideoMuted];          // Tutorial Step 10
    [self initializeAgoraEngine];   // Tutorial Step 1
    [self setupVideo];              // Tutorial Step 2
    [self setupLocalVideo];         // Tutorial Step 3
    [self joinChannel];             // Tutorial Step 4
    
    [self _configOwnViews];
    [self _configWhiteboardDataSource];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Tutorial Step 1
- (void)initializeAgoraEngine {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"d2ed4627fd374121adf17c7b269c2d1e" delegate:self];
}

// Tutorial Step 2
- (void)setupVideo {
    [self.agoraKit enableVideo];
    // Default mode is disableVideo
    
    [self.agoraKit setVideoProfile:AgoraRtc_VideoProfile_240P_3 swapWidthAndHeight: YES];
    // Default video profile is 360P
}

// Tutorial Step 3
- (void)setupLocalVideo {
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 0;
    // UID = 0 means we let Agora pick a UID for us
    
    videoCanvas.view = self.localVideo;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [self.agoraKit setupLocalVideo:videoCanvas];
    // Bind local video stream to view
}

// Tutorial Step 4
- (void)joinChannel {
    [self.agoraKit joinChannelByKey:nil channelName:@"demoChannel2" info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        // Join channel "demoChannel1"
        [self.agoraKit setEnableSpeakerphone:YES];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }];
   
}

// Tutorial Step 5
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
    if (self.remoteVideo.hidden)
        self.remoteVideo.hidden = false;
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    // Since we are making a simple 1:1 video chat app, for simplicity sake, we are not storing the UIDs. You could use a mechanism such as an array to store the UIDs in a channel.
    
    [self.userArray addObject:[NSNumber numberWithInteger:uid]];
    
   
    
    videoCanvas.view = [self reloadRemoteVideoUI];
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [self.agoraKit setupRemoteVideo:videoCanvas];
    // Bind remote video stream to view
    if (self.remoteVideo.hidden)
        self.remoteVideo.hidden = false;
}
- (UIView *)reloadRemoteVideoUI
{

    UIView *newview = [[UIView alloc]init];
    newview.backgroundColor = [UIColor redColor];
    [self.remoteVideo addSubview:newview];
    
    [self.viewArray addObject:newview];
    CGFloat width = 0;
   
    if (IS_IPAD) {
        if (self.viewArray.count == 1) {
            width = kAUTOSCALE_IPAD_WIDTH(300);
        }else if (self.viewArray.count > 1 && self.viewArray.count <= 4){
            width = kAUTOSCALE_IPAD_WIDTH(150);
        }else if (self.viewArray.count > 4 && self.viewArray.count <= 9){
            width = kAUTOSCALE_IPAD_WIDTH(100);
        }
        
    }else{
        if (self.viewArray.count == 1) {
            width = kSCREEN_HEIGHT/2;
        }else if (self.viewArray.count > 1 && self.viewArray.count <= 4){
            width = kSCREEN_HEIGHT/4;
           
        }else if (self.viewArray.count > 4 && self.viewArray.count <= 9){
            width = kSCREEN_HEIGHT/6;
           
        }
    }
   
    
    for (int i = 0; i < self.viewArray.count; i++) {
       
        int m = 0;
        int n = 0;
        if (self.viewArray.count > 1 && self.viewArray.count <= 4) {
            m = i%2;
            n = i/2;
        }else if(self.viewArray.count > 4 && self.viewArray.count <= 9){
            m = i%3;
            n = i/3;
        }
        
        
        UIView *view =  self.viewArray[i];
        view.frame = CGRectMake(m*width, n*width, width, width);
    }
  
    return newview;
}



- (void)leaveChannel {
    [self.agoraKit leaveChannel:^(AgoraRtcStats *stat) {
        // Tutorial Step 8
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [self.remoteVideo removeFromSuperview];
        [self.localVideo removeFromSuperview];
        self.agoraKit = nil;
    }];
}

// Tutorial Step 7
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason {
    self.remoteVideo.hidden = true;
}

// Tutorial Step 8
- (void)setupButtons {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remoteVideoTapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.view.userInteractionEnabled = true;
}


- (void)remoteVideoTapped:(UITapGestureRecognizer *)recognizer {

    [self.view endEditing:YES];

}

// Tutorial Step 9
- (void)didClickMuteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraKit muteLocalAudioStream:sender.selected];
}

// Tutorial Step 10
- (void)didClickVideoMuteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraKit muteLocalVideoStream:sender.selected];
    self.localVideo.hidden = sender.selected;
    self.localVideoMutedIndicator.hidden = !sender.selected;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    self.remoteVideo.hidden = muted;
    self.remoteVideoMutedIndicator.hidden = !muted;
}

- (void) hideVideoMuted {
    self.remoteVideoMutedIndicator.hidden = true;
    self.localVideoMutedIndicator.hidden = true;
}

// Tutorial Step 11
- (void)didClickSwitchCameraButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraKit switchCamera];
}

- (void)hangUpButton:(UIButton *)sender {
    [self leaveChannel];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didClickVideoMemuButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected ) {
        [UIView animateWithDuration:0.2 animations:^{
            self.controlButtons.hidden = NO;
        }];
    }else{
        
        [UIView animateWithDuration:0.2 animations:^{
            self.controlButtons.hidden = YES;
        }];

    }
}


#pragma mark =========UI=========

- (void)layoutUI
{
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //添加白板
    [self.contentView addSubview:self.whiteBoardView];
    [self.whiteBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(0);
        make.left.equalTo(self.contentView).offset(-0);
        if (IS_IPAD) {
            make.width.mas_equalTo(kSCREEN_WIDTH-kAUTOSCALE_IPAD_WIDTH(300));
            make.height.mas_equalTo(kSCREEN_HEIGHT);
        }else{
            make.width.mas_equalTo(kSCREEN_WIDTH-kSCREEN_HEIGHT/2);
            make.height.mas_equalTo(kSCREEN_HEIGHT);
        }
       
    }];
    
    
    [self.contentView addSubview:self.localVideoBGView];
    [self.contentView addSubview:self.remoteVideoBGView];
    [self.localVideoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(0);
        make.right.equalTo(self.contentView).offset(-0);
        if (IS_IPAD) {
            make.width.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(300));
            make.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(300));
        }else{
            make.width.mas_equalTo(kSCREEN_HEIGHT/2);
            make.height.mas_equalTo(kSCREEN_HEIGHT/2);
        }
       
    }];
    [self.remoteVideoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.localVideoBGView.mas_bottom).offset(0);
        make.right.equalTo(self.contentView).offset(-0);
        if (IS_IPAD) {
            make.width.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(300));
            make.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(300));
        }else{
            make.width.mas_equalTo(kSCREEN_HEIGHT/2);
            make.height.mas_equalTo(kSCREEN_HEIGHT/2);
        }
    }];
    
    [self.contentView addSubview:self.localVideo];
    [self.localVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(0);
        make.right.equalTo(self.contentView).offset(-0);
        if (IS_IPAD) {
            make.width.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(300));
            make.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(300));
        }else{
            make.width.mas_equalTo(kSCREEN_HEIGHT/2);
            make.height.mas_equalTo(kSCREEN_HEIGHT/2);
        }
    }];
    
    [self.contentView addSubview:self.remoteVideo];
    [self.remoteVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.localVideo.mas_bottom).offset(0);
        make.right.equalTo(self.contentView).offset(-0);
        if (IS_IPAD) {
            make.width.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(300));
            make.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(300));
        }else{
            make.width.mas_equalTo(kSCREEN_HEIGHT/2);
            make.height.mas_equalTo(kSCREEN_HEIGHT/2);
        }
    }];
    
    [self.contentView addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
            make.top.left.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(15));
            make.size.mas_equalTo(CGSizeMake(kAUTOSCALE_IPAD_WIDTH(50), kAUTOSCALE_IPAD_WIDTH(50)));
        }else{
            make.top.left.mas_equalTo(kAUTOSCALE_WIDTH(15));
            make.size.mas_equalTo(CGSizeMake(kAUTOSCALE_WIDTH(30), kAUTOSCALE_WIDTH(30)));
        }
    }];
    
    
    [self.contentView addSubview:self.videoMemu];
    [self.videoMemu mas_makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
            make.bottom.equalTo(self.contentView).offset(-kAUTOSCALE_IPAD_WIDTH(10));
            make.left.equalTo(self.contentView).offset(kAUTOSCALE_IPAD_WIDTH(10));
            make.width.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(50));
            make.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(50));
        }else{
            make.bottom.equalTo(self.contentView).offset(-kAUTOSCALE_WIDTH(10));
            make.left.equalTo(self.contentView).offset(kAUTOSCALE_WIDTH(10));
            make.width.mas_equalTo(kAUTOSCALE_WIDTH(30));
            make.height.mas_equalTo(kAUTOSCALE_WIDTH(30));
        }
       
    }];
    
    
    //视屏操作菜单
    [self.contentView addSubview:self.controlButtons];
    [self.controlButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
            make.bottom.equalTo(self.contentView).offset(-kAUTOSCALE_IPAD_WIDTH(70));
            make.left.equalTo(self.contentView);
            make.width.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(70));
            make.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(250));
        }else{
            make.bottom.equalTo(self.contentView).offset(-kAUTOSCALE_WIDTH(50));
            make.left.equalTo(self.contentView);
            make.width.mas_equalTo(kAUTOSCALE_WIDTH(50));
            make.height.mas_equalTo(kAUTOSCALE_WIDTH(180));
        }
        
    }];
    self.controlButtons.hidden = YES;
    [self.controlButtons addSubview:self.videoMuteButton];
    [self.controlButtons addSubview:self.muteButton];
    [self.controlButtons addSubview:self.switchCameraButton];
    [self.controlButtons addSubview:self.hangUpButton];
   
    
    [self.videoMuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.controlButtons);
        if (IS_IPAD) {
            make.width.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(50));
            make.bottom.equalTo(self.controlButtons).offset(-kAUTOSCALE_IPAD_WIDTH(10));
        }else{
            make.width.height.mas_equalTo(kAUTOSCALE_WIDTH(30));
            make.bottom.equalTo(self.controlButtons).offset(-kAUTOSCALE_WIDTH(10));
        }
       

    }];
    [self.muteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.controlButtons);
        
        if (IS_IPAD) {
            make.width.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(50));
            make.bottom.equalTo(self.videoMuteButton.mas_top).offset(-kAUTOSCALE_IPAD_WIDTH(10));
        }else{
            make.width.height.mas_equalTo(kAUTOSCALE_WIDTH(30));
            make.bottom.equalTo(self.videoMuteButton.mas_top).offset(-kAUTOSCALE_WIDTH(10));
        }
      
    }];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.controlButtons);
        
        if (IS_IPAD) {
            make.width.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(50));
            make.bottom.equalTo(self.muteButton.mas_top).offset(-kAUTOSCALE_IPAD_WIDTH(10));
        }else{
            make.width.height.mas_equalTo(kAUTOSCALE_WIDTH(30));
            make.bottom.equalTo(self.muteButton.mas_top).offset(-kAUTOSCALE_WIDTH(10));
        }
        
       
    }];
    [self.hangUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.controlButtons);
        
        if (IS_IPAD) {
            make.width.height.mas_equalTo(kAUTOSCALE_IPAD_WIDTH(50));
            make.bottom.equalTo(self.switchCameraButton.mas_top).offset(-kAUTOSCALE_IPAD_WIDTH(10));
        }else{
            make.width.height.mas_equalTo(kAUTOSCALE_WIDTH(30));
            make.bottom.equalTo(self.switchCameraButton.mas_top).offset(-kAUTOSCALE_WIDTH(10));
        }
        
    }];
        
}

- (UIView *)remoteVideo
{
    if (!_remoteVideo) {
        _remoteVideo = [[UIView alloc]init];
        _remoteVideo.backgroundColor = [UIColor clearColor];
    }
    return _remoteVideo;
}

- (UIView *)localVideo{
    if (!_localVideo) {
        _localVideo = [[UIView alloc]init];
        _localVideo.backgroundColor = [UIColor blackColor];
    }
    return _localVideo;
}

- (UIView *)controlButtons{
    if (!_controlButtons) {
        _controlButtons = [[UIView alloc]init];
        _controlButtons.backgroundColor = [UIColor clearColor];
    }
    return _controlButtons;
}


- (UIButton *)videoMemu
{
    if (!_videoMemu) {
        _videoMemu = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoMemu setTitle:@"Menu" forState:UIControlStateNormal];
        _videoMemu.backgroundColor = [UIColor blueColor];
        _videoMemu.titleLabel.font = [UIFont systemFontOfSize:9];
        _videoMemu.clipsToBounds = YES;
        if (IS_IPAD) {
            _videoMemu.layer.cornerRadius = kAUTOSCALE_IPAD_WIDTH(25);

        }else{
            _videoMemu.layer.cornerRadius = kAUTOSCALE_WIDTH(15);

        }
        [_videoMemu addTarget:self action:@selector(didClickVideoMemuButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoMemu;
}


- (UIButton *)videoMuteButton
{
    if (!_videoMuteButton) {
        _videoMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoMuteButton setBackgroundImage:[UIImage imageNamed:@"videoMuteButtonSelected"] forState:UIControlStateNormal];
        [_videoMuteButton setBackgroundImage:[UIImage imageNamed:@"videoMuteButton"] forState:UIControlStateSelected];

        
        [_videoMuteButton addTarget:self action:@selector(didClickVideoMuteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoMuteButton;
}

- (UIButton *)muteButton
{
    if (!_muteButton) {
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteButton setBackgroundImage:[UIImage imageNamed:@"muteButtonSelected"] forState:UIControlStateNormal];
        [_muteButton setBackgroundImage:[UIImage imageNamed:@"muteButton"] forState:UIControlStateSelected];

        [_muteButton addTarget:self action:@selector(didClickMuteButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteButton;
}

- (UIButton *)switchCameraButton
{
    if (!_switchCameraButton) {
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCameraButton setBackgroundImage:[UIImage imageNamed:@"switchCameraButtonSelected"] forState:UIControlStateNormal];
        [_switchCameraButton setBackgroundImage:[UIImage imageNamed:@"switchCameraButton"] forState:UIControlStateSelected];

        [_switchCameraButton addTarget:self action:@selector(didClickSwitchCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
}

- (UIButton *)hangUpButton
{
    if (!_hangUpButton) {
        _hangUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangUpButton setBackgroundImage:[UIImage imageNamed:@"hangUpButton"] forState:UIControlStateNormal];
        [_hangUpButton addTarget:self action:@selector(hangUpButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangUpButton;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(hangUpButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}


- (UIImageView *)localVideoMutedBg
{
    if (!_localVideoMutedBg) {
        _localVideoMutedBg = [[UIImageView alloc] init];
        _localVideoMutedBg.contentMode = UIViewContentModeScaleAspectFill;
        _localVideoMutedBg.image = [UIImage imageNamed:@"view.jpg"];
        _localVideoMutedBg.clipsToBounds = YES;
        _localVideoMutedBg.userInteractionEnabled = YES;
    }
    return _localVideoMutedBg;
}

- (UIImageView *)localVideoBGView
{
    if (!_localVideoBGView) {
        _localVideoBGView = [[UIImageView alloc] init];
        _localVideoBGView.contentMode = UIViewContentModeScaleAspectFill;
        _localVideoBGView.image = [UIImage imageNamed:@"live_exit"];
        _localVideoBGView.clipsToBounds = YES;
    }
    return _localVideoBGView;
}

- (UIImageView *)remoteVideoBGView
{
    if (!_remoteVideoBGView) {
        _remoteVideoBGView = [[UIImageView alloc] init];
        _remoteVideoBGView.contentMode = UIViewContentModeScaleAspectFill;
        _remoteVideoBGView.image = [UIImage imageNamed:@"live_exit"];
        _remoteVideoBGView.clipsToBounds = YES;
    }
    return _remoteVideoBGView;
}


- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIView *)whiteBoardView
{
    if (!_whiteBoardView) {
        _whiteBoardView = [[UIView alloc]init];
        _whiteBoardView.backgroundColor = [UIColor whiteColor];
    }
    return _whiteBoardView;
}



#pragma mark - HYWbDataSource
#pragma mark ==================实时白板=======================

// 所有的画线
- (NSDictionary<NSString *, NSArray *> *)allLines {
    _needUpdate = NO;
    return _allLines;
}

// 颜色数组
- (NSArray<UIColor *> *)colorArr {
    return _colorPanel.colorArr;
}

// 当前是否为橡皮擦模式
- (BOOL)isEraser {
    return _isEraser;
}

// 需要更新视图
- (BOOL)needUpdate {
    return _needUpdate;
}


#pragma HYColorPanelDelegate

// 点击按钮
- (void)onClickColorPanelButton:(UIButton *)button {
    switch (button.tag) {
            // 颜色
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:{
            _lineColorIndex = button.tag - 10;
            _isEraser = NO;
            [[HYConversationManager shared] sendPenStyleColor:_lineColorIndex lineWidth:_lineWidth];
            break;
        }
            
            // 橡皮
        case 15:{
            _lineColorIndex = button.tag - 10;
            _isEraser = YES;
            [[HYConversationManager shared] sendPenStyleColor:_lineColorIndex lineWidth:_lineWidth];
            break;
        }
            
            // 画线粗细
        case 20:
        case 21:
        case 22:{
            _lineWidth = [_colorPanel.lineWidthArr[button.tag - 20] integerValue];
            [[HYConversationManager shared] sendPenStyleColor:_lineColorIndex lineWidth:_lineWidth];
            break;
        }
            
            // 撤销
        case 23:{
            if (_allLines[UserOfLinesMine] && [_allLines[UserOfLinesMine] count]) {
                NSArray *line = [_allLines[UserOfLinesMine] lastObject];
                [_cancelLines addObject:line];
                [_allLines[UserOfLinesMine] removeObject:line];
                _needUpdate = YES;
                
                [[HYConversationManager shared] sendEditAction:HYMessageCmdCancel];
            }
            break;
        }
            
            // 恢复
        case 24:{
            if (_cancelLines.count) {
                [_allLines[UserOfLinesMine] addObject:_cancelLines.lastObject];
                [_cancelLines removeObjectAtIndex:_cancelLines.count - 1];
                _needUpdate = YES;
                
                [[HYConversationManager shared] sendEditAction:HYMessageCmdResume];
            }
            break;
        }
            
            // 清除
        case 25:{
            if (_allLines.count) {
                [_allLines removeAllObjects];
                _needUpdate = YES;
                
                [[HYConversationManager shared] sendEditAction:HYMessageCmdClearAll];
            }
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - HYConversationDelegate

// 接收到画线的点
- (void)onReceivePoint:(HYWbPoint *)point {
    
    // 同时只能绘制一个人的画线
    if (point.type == HYWbPointTypeEnd) {
        _drawable = YES;
    }
    else {
        _drawable = NO;
    }
    
    point.lineWidth = _lineWidth;
    point.colorIndex = _lineColorIndex;
    [self _addPoint:point userId:UserOfLinesOther];
    
    // 橡皮擦直接渲染到视图上
    if (point.isEraser) {
        [_wbView drawEraserLineByPoint:point];
    }
}

// 接收到画笔颜色、宽度
- (void)onReceivePenColor:(NSInteger)colorIndex lineWidth:(NSInteger)lineWidth {
    _lineWidth = lineWidth;
    _lineColorIndex = colorIndex;
}

// 接收到撤销，恢复，全部擦除消息
- (void)onReceiveEditAction:(HYMessageCmd)type {
    switch (type) {
            // 撤销
        case HYMessageCmdCancel:{
            if (_allLines[UserOfLinesOther] && [_allLines[UserOfLinesOther] count]) {
                NSArray *line = [_allLines[UserOfLinesOther] lastObject];
                [_cancelLines addObject:line];
                [_allLines[UserOfLinesMine] removeObject:line];
                _needUpdate = YES;
            }
            break;
        }
            
            // 恢复
        case HYMessageCmdResume:{
            if (_cancelLines.count) {
                [_allLines[UserOfLinesOther] addObject:_cancelLines.lastObject];
                [_cancelLines removeObjectAtIndex:_cancelLines.count - 1];
                _needUpdate = YES;
            }
            break;
        }
            
            // 清除
        case HYMessageCmdClearAll:{
            [_allLines removeAllObjects];
            _needUpdate = YES;
            break;
        }
            
        default:
            break;
    }
}

// 网络断开
- (void)onNetworkDisconnect {
    
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self.view showToastWithMessage:@"对方已离开房间"];
}


#pragma mark - HYUploadDelegate

// 接收到新图片
- (void)onNewImage:(UIImage *)image {
    [self.scrollView setZoomScale:1.f];
    self.imageView.image = image;
}

// 上传连接断开
- (void)onUploadServiceDisconnect {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


#pragma mark - Private methods

// 设置子视图
- (void)_configOwnViews {
   
    
    [self.whiteBoardView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.imageView addSubview:self.wbView];
    [self.whiteBoardView addSubview:self.colorPanel];
    [self.whiteBoardView addSubview:self.drawingBtn];
    [self.whiteBoardView addSubview:self.boardSetting];
    [self _addGestureRecognizerToView:_wbView];
    
    
    [self onNewImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"view" ofType:@"jpg"]]];

    if (_isUnConnected) {
    }
}

// 设置线条数据源
- (void)_configWhiteboardDataSource {
    _lineColorIndex = 0;
    _lineWidth = [_colorPanel.lineWidthArr.firstObject integerValue];
    
    _allLines = [NSMutableDictionary new];
    _cancelLines = [NSMutableArray new];
    
    _drawable = YES;
}

// 添加所有的手势
- (void)_addGestureRecognizerToView:(UIView *)view {
    // 画线手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onPanGesture:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [view addGestureRecognizer:panGestureRecognizer];
}

// 画线手势
- (void)_onPanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    // 是否正在渲染别人的画线
    if (_drawable == NO) {
        return ;
    }
    
    CGPoint p = [panGestureRecognizer locationInView:panGestureRecognizer.view];
    
    // 画线之后无法恢复撤销的线
    [_cancelLines removeAllObjects];
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self _onPointCollected:p type:HYWbPointTypeStart];
            break;
        case UIGestureRecognizerStateChanged:
            [self _onPointCollected:p type:HYWbPointTypeMove];
            break;
        default:
            [self _onPointCollected:p type:HYWbPointTypeEnd];
            break;
    }
}

// 收集画线的点
- (void)_onPointCollected:(CGPoint)p type:(HYWbPointType)type {
    HYWbPoint *point = [HYWbPoint new];
    point.type = type;
    point.xScale = (p.x) / _wbView.frame.size.width;
    point.yScale = (p.y) / _wbView.frame.size.height;
    point.colorIndex = _lineColorIndex;
    point.lineWidth = _lineWidth;
    [self _addPoint:point userId:UserOfLinesMine];
    
    // 橡皮擦直接渲染到视图上
    if (_isEraser) {
        point.isEraser = YES;
        [_wbView drawEraserLineByPoint:point];
    }
    
    [[HYConversationManager shared] sendPointMsg:point];
}

// 保存点
- (void)_addPoint:(HYWbPoint *)point userId:(NSString *)userId {
    if (point == nil || userId == nil || userId.length < 1) {
        return;
    }
    
    NSMutableArray *lines = [_allLines objectForKey:userId];
    
    if (lines == nil) {
        lines = [[NSMutableArray alloc] init];
        [_allLines setObject:lines forKey:userId];
    }
    
    if (point.type == HYWbPointTypeStart) {
        [lines addObject:[NSMutableArray arrayWithObject:point]];
    }
    else if (lines.count == 0){
        point.type = HYWbPointTypeStart;
        [lines addObject:[NSMutableArray arrayWithObject:point]];
    }
    else {
        NSMutableArray *lastLine = [lines lastObject];
        [lastLine addObject:point];
    }
    
    _needUpdate = YES;
}

// 插入图片
- (void)_insertImage:(UIBarButtonItem *)sender {
    
    sender.enabled  = NO;
    
    // 连接上传服务器
    __weak typeof(self) ws = self;
    [[HYUploadManager shared] connectUploadServerSuccessed:^(HYSocketService *service) {
        // 上传图片
        [ws _uploadImage];
    } failed:^(NSError *error) {
        NSLog(@"****HY Error:%@", error.domain);
        sender.enabled = YES;
    }];
}

// 上传图片
- (void)_uploadImage {
    
    // 发送图片信息
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1424*2144-398KB" ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    [[HYUploadManager shared] sendImageInfoSize:CGSizeMake(4096, 4096) fileLength:(uint32_t)data.length];
    
    __weak typeof(self) ws = self;
    [[HYUploadManager shared] uploadImage:YES data:data progress:^(CGFloat progress) {
        NSLog(@"HY upload progress:%f", progress);
    } completion:^(BOOL success, NSUInteger length) {
        if (success) {
            // 显示图片
            [ws onNewImage:[UIImage imageWithContentsOfFile:filePath]];
            
            // 发送上传完成
            [[HYUploadManager shared] sendImageUploadCompletion];
        }
        else {
            NSLog(@"****HY upload Failed.");
        }
    }];
}

// 画笔模式按钮开关
- (void)_onClickDrawingBtn:(UIButton *)sender {
    
    // 退出画笔模式
    if (sender.isSelected) {
        self.imageView.userInteractionEnabled = NO;
        _scrollView.scrollEnabled = YES;
        [sender setSelected:NO];
        sender.layer.borderColor = [UIColor grayColor].CGColor;
    }
    // 进入画笔模式
    else {
        self.imageView.userInteractionEnabled = YES;
        _scrollView.scrollEnabled = NO;
        [sender setSelected:YES];
        sender.layer.borderColor = [UIColor redColor].CGColor;
    }
}

//画板设置
- (void)onClickBoardSetting:(UIButton *)sender {
    sender.selected =! sender.selected;
    if (sender.selected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.colorPanel.hidden = NO;
            self.drawingBtn.hidden = NO;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.colorPanel.hidden = YES;
            self.drawingBtn.hidden = YES;

        }];
    }
}


#pragma Property

// 颜色盘
- (HYColorPanel *)colorPanel {
    if (_colorPanel == nil) {
        _colorPanel = [HYColorPanel new];
        _colorPanel.delegate = self;
        _colorPanel.hidden = YES;
    }
    
    return _colorPanel;
}

// 白板视图
- (HYWhiteboardView *)wbView {
    if (_wbView == nil) {
        _wbView = [HYWhiteboardView new];
        _wbView.frame = self.imageView.frame;
        _wbView.dataSource = self;
    }
    
    return _wbView;
}

// scroll view
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [UIScrollView new];
        
        if (IS_IPAD) {
            _scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-kAUTOSCALE_IPAD_WIDTH(300), kAUTOSCALE_IPAD_WIDTH(600));

        }else{
            _scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-kSCREEN_HEIGHT/2, kSCREEN_HEIGHT);

        }
        
        _scrollView.maximumZoomScale = 3.f;
        _scrollView.bounces = NO;
        _scrollView.bouncesZoom = NO;
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    
    return _scrollView;
}

// 图片
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [UIImageView new];
        _imageView.frame = CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height);
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.userInteractionEnabled = _drawingBtn.isSelected ? YES : NO;
    }
    
    return _imageView;
}

// 画笔模式开关
- (UIButton *)drawingBtn {
    if (_drawingBtn == nil) {
        _drawingBtn = [UIButton new];
        if (IS_IPAD) {
            _drawingBtn.frame = CGRectMake(kAUTOSCALE_IPAD_WIDTH(150), kSCREEN_HEIGHT - 100, 44, 44);
        }else{
            _drawingBtn.frame = CGRectMake(kAUTOSCALE_WIDTH(100), kSCREEN_HEIGHT - 100, 44, 44);
        }
        _drawingBtn.layer.masksToBounds = YES;
        _drawingBtn.layer.cornerRadius = 22;
        _drawingBtn.layer.borderWidth = 1.f;
        _drawingBtn.backgroundColor = [UIColor whiteColor];
        _drawingBtn.layer.borderColor = [UIColor grayColor].CGColor;
        [_drawingBtn setTitle:@"画笔" forState:UIControlStateNormal];
        [_drawingBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_drawingBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        _drawingBtn.hidden = YES;
        _drawingBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_drawingBtn addTarget:self action:@selector(_onClickDrawingBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _drawingBtn;
}


// 画笔模式开关
- (UIButton *)boardSetting {
    if (_boardSetting == nil) {
        _boardSetting = [UIButton new];
        if (IS_IPAD) {
            _boardSetting.frame = CGRectMake(kAUTOSCALE_IPAD_WIDTH(80), kSCREEN_HEIGHT - kAUTOSCALE_IPAD_WIDTH(60), kAUTOSCALE_IPAD_WIDTH(50), kAUTOSCALE_IPAD_WIDTH(50));
            _boardSetting.layer.cornerRadius = kAUTOSCALE_IPAD_WIDTH(25);
        }else{
            _boardSetting.frame = CGRectMake(kAUTOSCALE_WIDTH(60), kSCREEN_HEIGHT - kAUTOSCALE_WIDTH(40), kAUTOSCALE_WIDTH(30), kAUTOSCALE_WIDTH(30));
            _boardSetting.layer.cornerRadius = kAUTOSCALE_WIDTH(15);
        }
        
        _boardSetting.layer.masksToBounds = YES;
        _boardSetting.layer.borderWidth = 1.f;
        _boardSetting.backgroundColor = [UIColor whiteColor];
        _boardSetting.layer.borderColor = [UIColor grayColor].CGColor;
        [_boardSetting setTitle:@"Board" forState:UIControlStateNormal];
        [_boardSetting setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_boardSetting setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        _boardSetting.titleLabel.font = [UIFont systemFontOfSize:9.f];
        [_boardSetting addTarget:self action:@selector(onClickBoardSetting:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _boardSetting;
}


@end


