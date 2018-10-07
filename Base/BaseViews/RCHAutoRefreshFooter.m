//
//  RCHAutoRefreshFooter.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAutoRefreshFooter.h"

@implementation RCHAutoRefreshFooter

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
    [self setTitle:@"    加载中..." forState:MJRefreshStateIdle];
    [self setTitle:@"    加载中..." forState:MJRefreshStatePulling];
    [self setTitle:@"    加载中..." forState:MJRefreshStateRefreshing];
    self.stateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    // 设置颜色
    self.stateLabel.textColor = kFontLightGrayColor;
    self.labelLeftInset = 0.0f;
    
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
