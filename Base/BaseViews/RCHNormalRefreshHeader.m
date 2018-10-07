//
//  RCHNormalRefreshHeader.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHNormalRefreshHeader.h"

@implementation RCHNormalRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUIOnce];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupUIOnce];
}

- (void)setupUIOnce
{
    self.automaticallyChangeAlpha = YES;
    
    [self setTitle:@"    下拉刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"    释放刷新" forState:MJRefreshStatePulling];
    [self setTitle:@"    加载中..." forState:MJRefreshStateRefreshing];
    
    self.arrowView.image = RCHIMAGEWITHNAMED(@"arrowFall");
    
    self.stateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    // 设置颜色
    self.stateLabel.textColor = kFontLightGrayColor;
    self.labelLeftInset = 0.0f;
    
    // 隐藏时间
    self.lastUpdatedTimeLabel.hidden = YES;
    
    // 隐藏状态
    self.stateLabel.hidden = NO;
}

// MJBug fix
- (void)endRefreshing {
    [super endRefreshing];
    self.state = MJRefreshStateIdle;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
}

@end
