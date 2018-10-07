//
//  RCHTradePriceView.m
//  richcore
//
//  Created by WangDong on 2018/7/7.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTradePriceView.h"

@interface RCHTradePriceView()

@property (weak, nonatomic) UILabel *priceLabel;
@property (weak, nonatomic) UILabel *CNYPriceLabel;
@property (weak, nonatomic) UILabel *amplitudeLabel;
@property (weak, nonatomic) UILabel *amplitudePercentLabel;
@property (weak, nonatomic) UILabel *lowPriceLabel;
@property (weak, nonatomic) UILabel *lowPriceTitleLabel;
@property (weak, nonatomic) UILabel *heightPriceLabel;
@property (weak, nonatomic) UILabel *heightPriceTitleLabel;
@property (weak, nonatomic) UILabel *volumeLabel;
@property (weak, nonatomic) UILabel *volumeTitleLabel;
@property (weak, nonatomic) UIImageView *arrowView;

@end

@implementation RCHTradePriceView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = newSuperview.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self refreshPrice];
    }
    return self;
}

#pragma mark -
#pragma mark - customFucton

- (void)refreshPrice {
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    if (!market || !market.state) {
        
        self.volumeTitleLabel.text = market.coin.commodity ?  @"累计成交量" : @"24h成交量";
        
        self.priceLabel.textColor = kTradeSameColor;
        self.priceLabel.text = @"--";
        
        self.CNYPriceLabel.text = @"--";
        
        self.amplitudeLabel.textColor = kTradeSameColor;
        self.amplitudeLabel.text = @"--";
        
        self.amplitudePercentLabel.textColor = kTradeSameColor;
        self.amplitudePercentLabel.text = @"--";
        
        self.lowPriceLabel.text = @"--";
        
        self.heightPriceLabel.text = @"--";
        
        self.volumeLabel.text = @"--";
    } else {
        
        NSComparisonResult result = [market.state.price_change_percent compare:[NSDecimalNumber zero]];
        if (result == NSOrderedDescending) {
            self.amplitudeLabel.textColor = kTradePositiveColor;
            self.amplitudeLabel.text = [NSString stringWithFormat:@"+%@", [RCHHelper getNSDecimalString:market.state.price_change defaultString:@"--" precision:market.priceScale fractionDigitsPadded:YES]];
            self.amplitudePercentLabel.textColor = self.amplitudeLabel.textColor;
            self.amplitudePercentLabel.text = [NSString stringWithFormat:@"+%.2f%%", [market.state.price_change_percent doubleValue]];
        } else {
            self.amplitudeLabel.textColor = result == NSOrderedAscending ? kTradeNegativeColor : kTradeSameColor;
            self.amplitudeLabel.text = [NSString stringWithFormat:@"%@", [RCHHelper getNSDecimalString:market.state.price_change defaultString:@"--" precision:market.priceScale fractionDigitsPadded:YES]];
            self.amplitudePercentLabel.textColor = self.amplitudeLabel.textColor;
            self.amplitudePercentLabel.text = [NSString stringWithFormat:@"%.2f%%", [market.state.price_change_percent doubleValue]];
        }
        
        if (market.state.amplitude == NSOrderedAscending) {
            self.priceLabel.textColor = kTradeNegativeColor;
            self.arrowView.image = RCHIMAGEWITHNAMED(@"arrow_fall");
        } else if (market.state.amplitude == NSOrderedDescending) {
            self.priceLabel.textColor = kTradePositiveColor;
            self.arrowView.image = RCHIMAGEWITHNAMED(@"arrow_rise");
        } else {
            self.priceLabel.textColor = kTradeSameColor;
            self.arrowView.image = nil;
        }
        
        
        self.priceLabel.text = [RCHHelper getNSDecimalString:market.state.last_price defaultString:@"--" precision:market.priceScale fractionDigitsPadded:YES];
        self.CNYPriceLabel.text = [NSString stringWithFormat:@"￥%.2f", [market.state.cny_price doubleValue]];
        
        NSNumberFormatter *format = [RCHHelper getNumberFormatterFractionDigits:([market.state.quote_volume doubleValue] < 10 ? 3 : 0)];
        self.volumeLabel.text = [NSString stringWithFormat:@"%@ %@",  [NSDecimalNumber decimalNumberWithString:[format stringFromNumber:market.coin.commodity ? market.state.overal_quote_volume : market.state.quote_volume]], market.currency.code];
        self.lowPriceLabel.text = [RCHHelper getNSDecimalString:market.state.low_price defaultString:@"--" precision:market.priceScale fractionDigitsPadded:YES];
        self.heightPriceLabel.text = [RCHHelper getNSDecimalString:market.state.high_price defaultString:@"--" precision:market.priceScale fractionDigitsPadded:YES];
        
        if (self.lowPriceLabel.text.length > self.heightPriceLabel.text.length) {
            [self.heightPriceTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.lowPriceTitleLabel);
            }];
        } else {
            [self.lowPriceTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.heightPriceTitleLabel);
            }];
        }
    }
}

- (void)setMarket:(RCHMarket *)market {
    [self refreshPrice];
//    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark - getter

- (UIView *)priceLabel
{
    if(!_priceLabel)
    {
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        priceLabel.textAlignment = NSTextAlignmentLeft;
        priceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24.f];
        priceLabel.textColor = kTradeSameColor;
        [priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:priceLabel];

        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15.0f);
            make.left.mas_equalTo(15.0f);
            make.height.mas_equalTo(24.0f);
        }];

        _priceLabel = priceLabel;
    }
    return _priceLabel;
}

- (UIView *)CNYPriceLabel
{
    if(!_CNYPriceLabel)
    {
        UILabel *CNYPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        CNYPriceLabel.textAlignment = NSTextAlignmentLeft;
        CNYPriceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.f];
        CNYPriceLabel.textColor = [UIColor whiteColor];
        [CNYPriceLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:CNYPriceLabel];

        [CNYPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.priceLabel.mas_bottom);
            make.left.mas_equalTo(self.priceLabel.mas_right).offset(10.0f);
            make.height.mas_equalTo(20.0f);
        }];

        _CNYPriceLabel = CNYPriceLabel;
    }
    return _CNYPriceLabel;
}

- (UIView *)amplitudeLabel
{
    if(!_amplitudeLabel)
    {
        UILabel *amplitudeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        amplitudeLabel.textAlignment = NSTextAlignmentLeft;
        amplitudeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
        amplitudeLabel.textColor = kTradeSameColor;
        [amplitudeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:amplitudeLabel];

        [amplitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(8.0f);
            make.left.mas_equalTo(self.priceLabel.mas_left);
            make.height.mas_equalTo(20.0f);
        }];

        _amplitudeLabel = amplitudeLabel;
    }
    return _amplitudeLabel;
}

- (UIView *)amplitudePercentLabel
{
    if(!_amplitudePercentLabel)
    {
        UILabel *amplitudePercentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        amplitudePercentLabel.textAlignment = NSTextAlignmentLeft;
        amplitudePercentLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
        amplitudePercentLabel.textColor = kTradeNegativeColor;
        [amplitudePercentLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:amplitudePercentLabel];

        [amplitudePercentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.amplitudeLabel);
            make.left.mas_equalTo(self.amplitudeLabel.mas_right).offset(10.0f);
            make.height.mas_equalTo(20.0f);
        }];

        _amplitudePercentLabel = amplitudePercentLabel;
    }
    return _amplitudePercentLabel;
}

- (UIView *)lowPriceLabel
{
    if(!_lowPriceLabel)
    {
        UILabel *lowPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        lowPriceLabel.textAlignment = NSTextAlignmentRight;
        lowPriceLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f]?:[UIFont systemFontOfSize:12.0f];
        lowPriceLabel.textColor = kTradeBorderColor;
        [lowPriceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:lowPriceLabel];

        [lowPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(10.0f);
            make.right.mas_equalTo(-15.0f);
            make.height.mas_equalTo(18.0f);
        }];
        
        _lowPriceLabel = lowPriceLabel;
    }
    return _lowPriceLabel;
}

- (UIView *)lowPriceTitleLabel
{
    if(!_lowPriceTitleLabel)
    {
        UILabel *lowPriceTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        lowPriceTitleLabel.text = @"24h最低价";
        [lowPriceTitleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:lowPriceTitleLabel];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lowPriceTitleLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [lowPriceTitleLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:12.0f] range:NSMakeRange(0, [lowPriceTitleLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [lowPriceTitleLabel.text length])];
        lowPriceTitleLabel.attributedText = attributedString;
        
        [lowPriceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lowPriceLabel);
            make.right.mas_equalTo(self.lowPriceLabel.mas_left).offset(-10.0f);
            make.height.mas_equalTo(18.0f);
        }];
        
        _lowPriceTitleLabel = lowPriceTitleLabel;
    }
    return _lowPriceTitleLabel;
}

- (UIView *)volumeLabel
{
    if(!_volumeLabel)
    {
        UILabel *volumeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        volumeLabel.textAlignment = NSTextAlignmentLeft;
        volumeLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f]?:[UIFont systemFontOfSize:12.0f];
        volumeLabel.textColor = kTradeBorderColor;
        [volumeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:volumeLabel];

        [volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.volumeTitleLabel);
            make.left.mas_equalTo(self.volumeTitleLabel.mas_right).offset(10.0f);
            make.height.mas_equalTo(18.0f);
            
        }];



        _volumeLabel = volumeLabel;
    }
    return _volumeLabel;
}

- (UIView *)volumeTitleLabel
{
    if(!_volumeTitleLabel)
    {
        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        UILabel *volumeTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        volumeTitleLabel.text = market.coin.commodity ?  @"累计成交量" : @"24h成交量";
        [volumeTitleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:volumeTitleLabel];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:volumeTitleLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [volumeTitleLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:12.0f] range:NSMakeRange(0, [volumeTitleLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [volumeTitleLabel.text length])];
        volumeTitleLabel.attributedText = attributedString;
        
        [volumeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-15.0f);
            make.left.mas_equalTo(self.priceLabel);
            make.height.mas_equalTo(18.0f);
        }];
        
        _volumeTitleLabel = volumeTitleLabel;
    }
    return _volumeTitleLabel;
}

- (UIView *)heightPriceLabel
{
    if(!_heightPriceLabel)
    {
        UILabel *heightPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        heightPriceLabel.textAlignment = NSTextAlignmentRight;
        heightPriceLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f]?:[UIFont systemFontOfSize:12.0f];
        heightPriceLabel.textColor = kTradeBorderColor;
        [heightPriceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:heightPriceLabel];

        [heightPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.volumeLabel);
            make.right.mas_equalTo(-15.0f);
            make.height.mas_equalTo(18.0f);
        }];
        
        _heightPriceLabel = heightPriceLabel;
    }
    return _heightPriceLabel;
}

- (UIView *)heightPriceTitleLabel
{
    if(!_heightPriceTitleLabel)
    {
        UILabel *heightPriceTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        heightPriceTitleLabel.text = @"24h最高价";
        [heightPriceTitleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:heightPriceTitleLabel];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:heightPriceTitleLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [heightPriceTitleLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:12.0f] range:NSMakeRange(0, [heightPriceTitleLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [heightPriceTitleLabel.text length])];
        heightPriceTitleLabel.attributedText = attributedString;
        
        [heightPriceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.heightPriceLabel);
            make.right.mas_equalTo(self.heightPriceLabel.mas_left).offset(-10.0f);
            make.height.mas_equalTo(18.0f);
        }];
        
        _heightPriceTitleLabel = heightPriceTitleLabel;
    }
    return _heightPriceTitleLabel;
}

- (UIImageView *)arrowView
{
    if(!_arrowView)
    {
        UIImageView *arrowView = [[UIImageView alloc] init];
        [self addSubview:arrowView];
        [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.priceLabel);
            make.left.mas_equalTo(self.priceLabel.mas_right).offset(10.0f);
        }];
        arrowView.hidden = YES;
        _arrowView = arrowView;
    }
    return _arrowView;
}

@end
