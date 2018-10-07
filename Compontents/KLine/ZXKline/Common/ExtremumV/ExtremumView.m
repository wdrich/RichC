//
//  ExtremumView.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2018/4/25.
//  Copyright © 2018年 郑旭. All rights reserved.
//

#import "ExtremumView.h"
#import "ZXHeader.h"
#import <Masonry.h>
@interface ExtremumView()
@property (nonatomic,strong) UILabel  *priceLabel;
@property (nonatomic,strong) UIImageView  *arrowImageView;
@end
@implementation ExtremumView
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
#pragma mark - Private Methods
- (void)updateExtremumViewWithArrowPositionLeft:(BOOL)positionLeft price:(double)price
{
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    if (positionLeft) {
        self.arrowImageView.image = [UIImage imageNamed:@"arrow_left"];
        [self.arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(18);
        }];
        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.arrowImageView.mas_right);
            make.top.bottom.mas_equalTo(self);
        }];
        self.priceLabel.text = [RCHHelper getNSDecimalString:[NSNumber numberWithFloat:price] defaultString:@"--" step:market.price_step];
    }else{
        self.arrowImageView.image = [UIImage imageNamed:@"arrow_right"];
        [self.arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(18);
           
        }];
        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.arrowImageView.mas_left);
            make.top.bottom.mas_equalTo(self);
        }];
        self.priceLabel.text = [RCHHelper getNSDecimalString:[NSNumber numberWithFloat:price] defaultString:@"--" step:market.price_step];
    }
}
#pragma mark - UITableViewDelegate


#pragma mark - Event Response


#pragma mark - CustomDelegate


#pragma mark - Getters & Setters
- (UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont systemFontOfSize:FontSize];
        _priceLabel.textColor = [UIColor whiteColor];
        [self addSubview:_priceLabel];
    }
    return _priceLabel;
}
- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_arrowImageView];
    }
    return _arrowImageView;
}
@end
