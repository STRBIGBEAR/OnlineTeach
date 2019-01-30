//
//  NGMHotListModel.h
//  DouBo_Live
//
//  Created by macdev on 2017/9/5.
//  Copyright © 2017年 ngmob. All rights reserved.
//


@interface NGMHotListModel : NSObject


@property (nonatomic,strong) NSString *cover;

@property (nonatomic,strong) NSString *headimg;

@property (nonatomic,strong) NSString *live_id;

@property (nonatomic,strong) NSString *title;

@property (nonatomic,strong) NSString *username;

@property (nonatomic,strong) NSString *tip;

+ (NGMHotListModel *)getTestModel;

@end
