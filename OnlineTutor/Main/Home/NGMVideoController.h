//
//  NGMVideoController.h
//  NGMVideoLive_iOS_demo
//
//  Created by JiMo on 2018/1/23.
//  Copyright © 2018年 JiMo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "BaseViewController.h"

@interface NGMVideoController : BaseViewController<AgoraRtcEngineDelegate>

@property(nonatomic,strong)NSString *titleString;

@property(nonatomic,strong)NSString *chanelString;

@property (nonatomic, assign)BOOL isServer;         // 服务器端

@property (nonatomic, assign)BOOL isUnConnected;    // 不需socket

@end
