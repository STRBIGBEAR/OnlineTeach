//
//  VideoChatPreView.m
//  DouBo_Live
//
//  Created by JiMo on 2017/8/23.
//  Copyright © 2017年 ngmob. All rights reserved.
//

#import "VideoChatPreView.h"
#import "Masonry.h"

@interface VideoChatPreView ()

@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *startLiveButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIView *remoteView;
@property (nonatomic, strong) UIView *locationView;




@end

@implementation VideoChatPreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.containerView];
        
        [self.containerView addSubview:self.locationView];
        [self.containerView addSubview:self.remoteView];
        [self.containerView addSubview:self.cameraButton];
        [self.containerView addSubview:self.beautyButton];
        
        [self.locationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView.mas_left).offset(10);
            make.bottom.equalTo(self.containerView.mas_bottom).offset(-10);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(38);
        }];
        
        [self.beautyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.cameraButton.mas_right).offset(10);
            make.centerY.equalTo(self.cameraButton.mas_centerY);
            make.width.mas_equalTo(46);
            make.height.mas_equalTo(46);
        }];
        
        [self.remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(100);
            make.right.equalTo(self.containerView).offset(-20);
            make.size.mas_equalTo(CGSizeMake(90, 160));
        }];
       
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        
        [self.locationView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationViewTap:)]];
        [self.remoteView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remoteViewTap:)]];
    }
    return self;
}

- (void)locationViewTap:(UITapGestureRecognizer *)gesture
{
    self.session.remoteView =  self.remoteView;
    self.session.preView = self.locationView;
}

- (void)remoteViewTap:(UITapGestureRecognizer *)gesture
{
    self.session.remoteView =  self.locationView ;
    self.session.preView = self.remoteView;
}

#pragma mark -- Public Method
- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self.session setRunning:YES];
            });
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            
            break;
        default:
            break;
    }
}

- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

#pragma mark ===========切换摄像头============
- (void)changeCamera:(UIButton *)sender
{
    AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

#pragma mark ===========开启、关闭美颜============
- (void)changeBeautyStatus:(UIButton *)sender
{
    self.session.beautyFace = !self.session.beautyFace;
    self.beautyButton.selected = !self.session.beautyFace;
}

#pragma mark -- Getter Setter
- (VideoChatSession *)session {
    if (!_session) {
        
        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
        
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
        videoConfiguration.videoSize = CGSizeMake(360, 640);
        videoConfiguration.videoBitRate = 800*1024;
        videoConfiguration.videoMaxBitRate = 1000*1024;
        videoConfiguration.videoMinBitRate = 500*1024;
        videoConfiguration.videoFrameRate = 30;
        videoConfiguration.videoMaxKeyframeInterval = 48;
        videoConfiguration.outputImageOrientation = UIDeviceOrientationPortrait;
        videoConfiguration.autorotate = NO;
        videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;
        _session = [[VideoChatSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
        
        _session.remoteView = self.remoteView;
        _session.preView = self.locationView;
    }
    return _session;
}


- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.frame = self.bounds;
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
        _stateLabel.text = @"未连接";
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    }
    return _stateLabel;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton new];
        [_cameraButton setImage:[UIImage imageNamed:@"camra_preview"] forState:UIControlStateNormal];
        _cameraButton.exclusiveTouch = YES;
        [_cameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)beautyButton {
    if (!_beautyButton) {
        _beautyButton = [UIButton new];
       
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateSelected];
        _beautyButton.exclusiveTouch = YES;
        
        [_beautyButton addTarget:self action:@selector(changeBeautyStatus:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}

- (UIView *)remoteView
{
    if (!_remoteView) {
        _remoteView = [[UIView alloc]init];
        _remoteView.backgroundColor = [UIColor blackColor];
    }
    return _remoteView;
}

- (UIView *)locationView
{
    if (!_locationView) {
        _locationView = [[UIView alloc]init];
        _locationView.backgroundColor = [UIColor blackColor];
    }
    return _locationView;
}

@end

