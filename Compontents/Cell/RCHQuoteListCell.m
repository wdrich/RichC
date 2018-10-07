//
//  RCHQuoteListCell.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHQuoteListCell.h"

@interface RCHQuoteListCell ()
{
    UIImageView *_quoteImageview;
    
    UILabel *_coinLabel;
    UILabel *_cnyLabel;
    UILabel *_dayVolumeLabel;
    UILabel *_priceLabel;
    UILabel *_changeayLabel;
}

@end

@implementation RCHQuoteListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tickerUpdated:)
                                                     name:kTickerUpdatedNotification
                                                   object:nil];
        
        _quoteImageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_quoteImageview setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_quoteImageview];
        
        
        _coinLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _coinLabel.textColor = kFontLightGrayColor;
        _coinLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        _coinLabel.textAlignment = NSTextAlignmentLeft;
        _coinLabel.backgroundColor = [UIColor clearColor];
        _coinLabel.layer.masksToBounds = YES;
        [self addSubview:_coinLabel];
        
        _dayVolumeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dayVolumeLabel.textColor = kFontLightGrayColor;
        _dayVolumeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        _dayVolumeLabel.numberOfLines = 0;
        _dayVolumeLabel.textAlignment = NSTextAlignmentLeft;
        _dayVolumeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_dayVolumeLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17.0f];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.numberOfLines = 3;
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.textColor = kFontBlackColor;
        [self addSubview:_priceLabel];
        
        _cnyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cnyLabel.textColor = kFontLightGrayColor;
        _cnyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        _cnyLabel.textAlignment = NSTextAlignmentLeft;
        _cnyLabel.backgroundColor = [UIColor clearColor];
        _cnyLabel.layer.masksToBounds = YES;
        [self addSubview:_cnyLabel];
        
        _changeayLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {80.0f, 36.0f}}];
        _changeayLabel.textColor = [UIColor whiteColor];
        _changeayLabel.numberOfLines = 0;
        _changeayLabel.layer.cornerRadius =2.0f;
        _changeayLabel.layer.masksToBounds = YES;
        [_changeayLabel setFont: [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f]];
        _changeayLabel.textAlignment = NSTextAlignmentRight;
        [_changeayLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_changeayLabel];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originX = 15.0f;
    CGFloat space = 2.0f; //（10 -12号字体 减去2.0）(13号字体 减去 2.5) (14-17号字体 减去3) (18号字体 减去 3.5) (19-20号字体 减去4)
    CGFloat originY = (self.height - space - _coinLabel.height - _dayVolumeLabel.height) / 2.0f;
    _coinLabel.frame = (CGRect){{originX, originY}, _coinLabel.frame.size};
    _dayVolumeLabel.frame = (CGRect){{_coinLabel.left, _coinLabel.bottom + space}, _dayVolumeLabel.frame.size};
    
    _priceLabel.frame = (CGRect){{140.0f, originY}, _priceLabel.frame.size};
    _cnyLabel.frame = (CGRect){{_priceLabel.left, _dayVolumeLabel.top}, _cnyLabel.frame.size};
    
    originY = (self.height - _changeayLabel.height) / 2.0f;
    _changeayLabel.frame = (CGRect){{self.width - originX - _changeayLabel.width, originY}, _changeayLabel.frame.size};
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark -
#pragma mark - CustomFuction

- (void)setMarket:(RCHMarket *)market {
    _market = market;
    [self reload];
}

- (void)reload {
    NSMutableAttributedString *attributedString = nil;
    NSString *defaultString = @"--";
    
    {
        _coinLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_market.isSecondary) {
            _coinLabel.text = _market.coin.name_cn ?: _market.coin.name_en;
        } else {
            _coinLabel.text = [NSString stringWithFormat:@"%@/%@", _market.coin.code, _market.currency.code];
        }
        attributedString = [[NSMutableAttributedString alloc] initWithString:_coinLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:paragraphStyle
                                 range:NSMakeRange(0, [_coinLabel.text length])];
        if (_market.isSecondary) {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont fontWithName:@"PingFangSC-Medium" size:15.0f]
                                     range:NSMakeRange(0, [_coinLabel.text length])];
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:kFontBlackColor
                                     range:NSMakeRange(0, [_coinLabel.text length])];
        } else {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont fontWithName:@"PingFangSC-Medium" size:17.0f]
                                     range:NSMakeRange(0, [_market.coin.code length])];
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:kFontBlackColor
                                     range:NSMakeRange(0, [_market.coin.code length])];
        }
        _coinLabel.attributedText = attributedString;
        
        [_coinLabel sizeToFit];
        _coinLabel.frame = (CGRect){_coinLabel.frame.origin, {_coinLabel.width, 20.0f}};
    }
    
    {
        _dayVolumeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_market.isSecondary) {
            _dayVolumeLabel.text = [NSString stringWithFormat:@"%@/%@", _market.coin.code, _market.currency.code];
        } else {
            NSString *pre = @"24h量";
            if (_market.state && _market.state.quote_volume) {
                NSNumberFormatter *format = [self getNumberFormatterFractionDigits:([_market.state.quote_volume doubleValue] < 10 ? 3 : 0)];
                _dayVolumeLabel.text = [NSString stringWithFormat:@"%@ %@",  pre, [NSDecimalNumber decimalNumberWithString:[format stringFromNumber:_market.state.quote_volume]]];
            } else {
                _dayVolumeLabel.text = defaultString;
            }
        }
        attributedString = [self getMutableAttributedStringe:_dayVolumeLabel.text Font:_dayVolumeLabel.font color:_dayVolumeLabel.textColor alignment:NSTextAlignmentLeft];
        _dayVolumeLabel.attributedText = attributedString;
        [_dayVolumeLabel sizeToFit];
        _dayVolumeLabel.frame = (CGRect){_dayVolumeLabel.frame.origin, {_dayVolumeLabel.width, 14.0f}};
    }
    
    {
        _priceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_market.state && _market.state.last_price) {
            NSNumberFormatter *format = [RCHHelper getNumberFormatterFractionDigits:_market.priceScale fractionDigitsPadded:YES];
            _priceLabel.text = [format stringFromNumber:_market.state.last_price];
        } else {
            _priceLabel.text = defaultString;
        }
        attributedString = [self getMutableAttributedStringe:_priceLabel.text
                                                        Font:_priceLabel.font
                                                       color:_priceLabel.textColor
                                                   alignment:NSTextAlignmentLeft];
        _priceLabel.attributedText = attributedString;
        [_priceLabel sizeToFit];
        _priceLabel.frame = (CGRect){_priceLabel.frame.origin, {_priceLabel.width, 20.0f}};
    }
    {
        _cnyLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        NSString *pre = @"¥";
        if (_market.state && _market.state.cny_price) {
            NSNumberFormatter *format = [self getNumberFormatterFractionDigits:2];
            _cnyLabel.text = [NSString stringWithFormat:@"%@ %@",  pre, [NSDecimalNumber decimalNumberWithString:[format stringFromNumber:_market.state.cny_price]]];
        } else {
            _cnyLabel.text = defaultString;
        }
        attributedString = [self getMutableAttributedStringe:_cnyLabel.text Font:_cnyLabel.font color:_cnyLabel.textColor alignment:NSTextAlignmentLeft];
        _cnyLabel.attributedText = attributedString;
        [_cnyLabel sizeToFit];
        _cnyLabel.frame = (CGRect){_cnyLabel.frame.origin, {_cnyLabel.width, 14.0f}};
    }
    
    
    {
        if (_market.state && _market.state.price_change_percent) {
            NSDecimalNumber *percent = [NSDecimalNumber decimalNumberWithDecimal:[_market.state.price_change_percent decimalValue]];
            NSInteger precision = 2;
            NSNumberFormatter *format = [self getNumberFormatterFractionDigits:precision];
            NSComparisonResult result = [percent compare:[NSDecimalNumber zero]];
            if (result == NSOrderedDescending) {
                _changeayLabel.text = [NSString stringWithFormat:@"+%@%%", [NSDecimalNumber decimalNumberWithString:[format stringFromNumber:_market.state.price_change_percent]]];
                _changeayLabel.backgroundColor = kTradePositiveColor;
            } else {
                _changeayLabel.text = [NSString stringWithFormat:@"%@%%", [NSDecimalNumber decimalNumberWithString:[format stringFromNumber:_market.state.price_change_percent]]];
                _changeayLabel.backgroundColor = result == NSOrderedAscending ? kTradeNegativeColor : kTradeSameColor;
            }
        } else {
            _changeayLabel.text = defaultString;
            _changeayLabel.backgroundColor = kFontLightGrayColor;
        }
        attributedString = [self getMutableAttributedStringe:_changeayLabel.text Font:_changeayLabel.font color:_changeayLabel.textColor alignment:NSTextAlignmentCenter];
        _changeayLabel.attributedText = attributedString;
    }
}

- (NSMutableAttributedString *)getMutableAttributedStringe:(NSString *)title Font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:1];
    [paragraphStyle setAlignment:alignment];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [title length])];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [title length])];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [title length])];;
    return attributedString;
}

- (NSNumberFormatter *)getNumberFormatterFractionDigits:(NSInteger)FractionDigit {
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    [format setPositiveFormat:@"####.##"];
    [format setMaximumFractionDigits:FractionDigit];
    return format;
}

- (void)tickerUpdated:(NSNotification *)note
{
    if (_market && [_market.symbol isEqualToString:[[note userInfo] objectForKey:@"symbol"]]) {
        [self reload];
    }
}

@end
