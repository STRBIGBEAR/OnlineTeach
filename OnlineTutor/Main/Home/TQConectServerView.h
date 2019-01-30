//
//  TQConectServerView.h
//  OnlineTutor
//
//  Created by JiMo on 2018/8/4.
//  Copyright © 2018年 TQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TQConectServerView : UIView

@property (nonatomic, strong)UILabel     *serverLb;      // 显示服务器ip地址

@property (nonatomic, strong)UILabel     *loadingLb;     // loading...

@property(nonatomic,copy)void(^startConect)(NSArray *strArr);

@property(nonatomic,copy)void(^startSettingServer)();

@property(nonatomic,copy)void(^refreshPort)();

@property(nonatomic,copy)void(^dismiss)();

@end
