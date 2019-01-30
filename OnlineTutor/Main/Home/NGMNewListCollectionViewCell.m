//
//  NGMNewListCollectionViewCell.m
//  DouBo_Live
//
//  Created by macdev on 2017/9/7.
//  Copyright © 2017年 ngmob. All rights reserved.
//

#import "NGMNewListCollectionViewCell.h"

@interface NGMNewListCollectionViewCell ()

@property (nonatomic,strong) UILabel            *userNameLabel;

@property (nonatomic, strong)UIImageView        *picImage,*coverView;

@property (nonatomic, strong) UILabel           *watchLabel;


@end

@implementation NGMNewListCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.picImage];
        [self.picImage addSubview:self.coverView];
        [self.picImage addSubview:self.watchLabel];
        [self.picImage addSubview:self.userNameLabel];
        
        [self.picImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
    
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
       
        [self.watchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.picImage).offset(-5);
            make.left.equalTo(self.picImage).offset(5);
        }];
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.watchLabel);
            make.bottom.equalTo(self.watchLabel.mas_top).offset(-5);
            make.width.mas_lessThanOrEqualTo(135);
        }];
        
        
    }
    return self;
}

- (void)setModel:(NGMHotListModel *)model{
    _model = model;
    
    self.picImage.image = [UIImage imageNamed:_model.cover];
    
    self.userNameLabel.text = _model.username;

    self.watchLabel.text = _model.tip;

}

- (UILabel *)watchLabel {
    if (!_watchLabel) {
        _watchLabel = [UILabel new];
        _watchLabel.textColor = [UIColor blackColor];
        _watchLabel.font = [UIFont systemFontOfSize:11];
        CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(-20 * (CGFloat)M_PI / 180), 1, 0, 0);
        _watchLabel.transform = matrix;
        _watchLabel.textAlignment = NSTextAlignmentCenter;
        _watchLabel.text = @"在看";
        
    }
    return _watchLabel;
}
- (UILabel *)userNameLabel{
    if (!_userNameLabel) {
        _userNameLabel  = [UILabel new];
        _userNameLabel.font = [UIFont boldSystemFontOfSize:15];
        _userNameLabel.textColor =[UIColor blackColor];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        [_userNameLabel sizeToFit];
    }
    return _userNameLabel;
}


- (UIImageView *)picImage {
    if (!_picImage) {
        _picImage = [[UIImageView alloc] init];
        _picImage.contentMode = UIViewContentModeScaleAspectFill;
        _picImage.clipsToBounds = YES;
    }
    return _picImage;
}

- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [UIImageView new];
        _coverView.backgroundColor = [UIColor whiteColor];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverView;
}

@end
