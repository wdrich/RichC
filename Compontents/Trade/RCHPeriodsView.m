//
//  RCHPeriodsView.m
//  richcore
//
//  Created by WangDong on 2018/7/5.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHPeriodsView.h"

@implementation RCHPeriodsView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = newSuperview.backgroundColor;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self createButtons];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createButtons];
    }
    return self;
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)periodClick:(id)sender{
    
    !self.onChanged ?: self.onChanged((UIButton *)sender);
}

#pragma mark -
#pragma mark - CustomFuction

- (void)createButtons {
    
    [self removeAllSubviews];
    
    NSInteger colCount = 5;
    NSInteger rowCount = ceil(self.titles.count / 5.0f);
    CGFloat lineHieght = 20.0f;
    CGFloat lineWeight = self.width / colCount;
    CGFloat spaceY = (self.height  - rowCount * lineHieght) / (rowCount + 1);
    
    NSInteger index = 0;
    for (NSString *title in _titles) {
        
        NSInteger col = index % colCount;
        NSInteger row = index / colCount;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [button setUserInteractionEnabled:YES];
        button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        [button setTitleColor:kTradeBorderColor forState:UIControlStateNormal];
        [button setTitleColor:kAppOrangeColor forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(periodClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = index;
        [self addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo((row + 1) * spaceY + row * lineHieght);
            make.left.mas_equalTo(col * lineWeight);
            make.width.mas_equalTo(lineWeight);
            make.height.mas_equalTo(lineHieght);
        }];
        index ++;
    }
}

#pragma mark -
#pragma mark - setter

- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    [self createButtons];
}

@end
