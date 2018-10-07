//
//  RCHWalletQuoteItem.m
//  richcore
//
//  Created by WangDong on 2018/6/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWalletQuoteItem.h"

@interface RCHWalletQuoteItem ()
{
    UILabel *_coinLabel;
    UILabel *_cnyLabel;
    UILabel *_priceLabel;
    UILabel *_changeayLabel;
}
@end

@implementation RCHWalletQuoteItem

+ (id)itemViewWithFrame:(CGRect)frame market:(RCHMarket *)market
{
    RCHWalletQuoteItem *item = [[RCHWalletQuoteItem alloc] initWithFrame:frame market:market];
    return item;
}


- (id)initWithFrame:(CGRect)frame market:(RCHMarket *)market
{
    self = [super initWithFrame:frame];
    if (self) {
        self.market = market;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([[NSDecimalNumber numberWithFloat:_originy] compare:[NSDecimalNumber zero]] == NSOrderedSame) {
        _originy = (self.height - _spacey - _coinLabel.height - _priceLabel.height) / 2.0f;
    }

//    _originy = 12.0f;
    _coinLabel.frame = (CGRect){{_originx, _originy}, _coinLabel.frame.size};
    _priceLabel.frame = (CGRect){{_coinLabel.left, _coinLabel.bottom + _spacey}, _priceLabel.frame.size};
    _changeayLabel.frame = (CGRect){{self.width - _originx - _changeayLabel.width, _originy}, _changeayLabel.frame.size};
    _cnyLabel.frame = (CGRect){{_priceLabel.right + 5.0f, _priceLabel.top}, _cnyLabel.frame.size};
    _cnyLabel.center = CGPointMake(_cnyLabel.center.x, _priceLabel.center.y);
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - CustomFuction

- (void)initQuoteViewItem
{
    _coinLabelFont = [UIFont systemFontOfSize:13.0f];
    _cnyFont = [UIFont systemFontOfSize:13.0f];
    _priceFont = [UIFont systemFontOfSize:13.0f];
    _changeayFont = [UIFont systemFontOfSize:13.0f];
    _coinLabelColor = kFontGrayColor;
    _cnyColor = kAppMainColor;
    _priceColor = kFontGrayColor;
    _changeayColor = kAppMainColor;
    _coinLabelAlignment = NSTextAlignmentLeft;
    _cnyAlignment = NSTextAlignmentLeft;
    _priceAlignment = NSTextAlignmentLeft;
    _changeayAlignment = NSTextAlignmentLeft;
    _originx = 10.0f;
    _originy = 0.0f;
    _spacex = 15.0f;
    _spacey = 5.0f;
    
    _coinLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _coinLabel.textColor = kFontBlackColor;
    _coinLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f];
    _coinLabel.textAlignment = NSTextAlignmentLeft;
    _coinLabel.backgroundColor = [UIColor clearColor];
    _coinLabel.numberOfLines = 1;
    _coinLabel.layer.masksToBounds = YES;
    [self addSubview:_coinLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    _priceLabel.backgroundColor = [UIColor clearColor];
    _priceLabel.numberOfLines = 1;
    _priceLabel.textAlignment = NSTextAlignmentLeft;
    _priceLabel.textColor = kFontLightGrayColor;
    [self addSubview:_priceLabel];
    
    _cnyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _cnyLabel.textColor = kFontLightGrayColor;
    _cnyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10.0f];
    _cnyLabel.textAlignment = NSTextAlignmentLeft;
    _cnyLabel.numberOfLines = 1;
    _cnyLabel.backgroundColor = [UIColor clearColor];
    _cnyLabel.layer.masksToBounds = YES;
    [self addSubview:_cnyLabel];
    
    _changeayLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {75.0f, 40.0f}}];
    _changeayLabel.textColor = kTradeSameColor;
    _changeayLabel.numberOfLines = 1;
    [_changeayLabel setFont: [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f]];
    _changeayLabel.textAlignment = NSTextAlignmentRight;
    [_changeayLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_changeayLabel];
}

#pragma mark -
#pragma mark - setter

- (void)setMarket:(RCHMarket *)market
{
    _market = market;
    if (_market) {
        [self initQuoteViewItem];
        [self reload];
    }
    [self layoutSubviews];
}

- (void)reload {
    NSMutableAttributedString *attributedString = nil;
    NSString *defaultString = @"--";
    {
        _coinLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_market.coin.code && _market.currency.code) {
            _coinLabel.text = [NSString stringWithFormat:@"%@/%@", _market.coin.code, _market.currency.code];
        } else {
            _coinLabel.text = defaultString;
        }
        attributedString = [RCHHelper getMutableAttributedStringe:_coinLabel.text Font:_coinLabel.font color:_coinLabel.textColor alignment:NSTextAlignmentLeft];
        _coinLabel.attributedText = attributedString;
        [_coinLabel sizeToFit];
        _coinLabel.frame = (CGRect){_coinLabel.frame.origin, {_coinLabel.width, 15.0f}};
    }
    
    {
        _priceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _priceLabel.text = [RCHHelper getNSDecimalString:_market.state.last_price defaultString:defaultString step:_market.price_step];
        attributedString = [RCHHelper getMutableAttributedStringe:_priceLabel.text Font:_priceLabel.font color:_priceLabel.textColor alignment:NSTextAlignmentLeft];
        _priceLabel.attributedText = attributedString;
        [_priceLabel sizeToFit];
        _priceLabel.frame = (CGRect){_priceLabel.frame.origin, {_priceLabel.width, 14.0f}};
    }
    
    {
        _cnyLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        NSString *pre = @"¥";
        _cnyLabel.text = [NSString stringWithFormat:@"%@ %@", pre, [RCHHelper getNSDecimalString:_market.state.last_price defaultString:defaultString precision:2]];
        attributedString = [RCHHelper getMutableAttributedStringe:_cnyLabel.text Font:_cnyLabel.font color:_cnyLabel.textColor alignment:NSTextAlignmentLeft];
        _cnyLabel.attributedText = attributedString;
        [_cnyLabel sizeToFit];
        _cnyLabel.frame = (CGRect){_cnyLabel.frame.origin, {_cnyLabel.width, 12.0f}};
    }
    
    
    {
        _changeayLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        NSDecimalNumber *percent = [NSDecimalNumber decimalNumberWithDecimal:[_market.state.price_change_percent decimalValue]];
        NSComparisonResult result = [percent compare:[NSDecimalNumber zero]];
        if (result == NSOrderedDescending) {
            _changeayLabel.text = [NSString stringWithFormat:@"+%@%%", [RCHHelper getNSDecimalString:_market.state.price_change_percent defaultString:defaultString precision:2]];
            _changeayLabel.textColor = kTradePositiveColor;
        } else {
            _changeayLabel.text = [NSString stringWithFormat:@"%@%%", [RCHHelper getNSDecimalString:_market.state.price_change_percent defaultString:defaultString precision:2]];
            _changeayLabel.textColor = result == NSOrderedAscending ? kTradeNegativeColor : kTradeSameColor;
        }
        attributedString = [RCHHelper getMutableAttributedStringe:_changeayLabel.text Font:_changeayLabel.font color:_changeayLabel.textColor alignment:NSTextAlignmentCenter];
        _changeayLabel.attributedText = attributedString;
        [_changeayLabel sizeToFit];
        _changeayLabel.frame = (CGRect){_changeayLabel.frame.origin, {_changeayLabel.width, 15.0f}};
    }
}

- (void)setCoinLabelColor:(UIColor *)coinLabelColor
{
    _coinLabelColor = coinLabelColor;
    _coinLabel.textColor = _coinLabelColor;
    [self layoutSubviews];
}

- (void)setCnyColor:(UIColor *)cnyColor
{
    _cnyColor = cnyColor;
    _cnyLabel.textColor = _cnyColor;
    [self layoutSubviews];
}

- (void)setPriceColor:(UIColor *)priceColor
{
    _priceColor = priceColor;
    _priceLabel.textColor = _priceColor;
    [self layoutSubviews];
}

- (void)setChangeayColor:(UIColor *)changeayColor
{
    _changeayColor = changeayColor;
    _changeayLabel.textColor = _changeayColor;
    [self layoutSubviews];
}

- (void)setCoinLabelFont:(UIFont *)coinLabelFont
{
    _coinLabelFont = coinLabelFont;
    _coinLabel.font = _coinLabelFont;
    [_coinLabel sizeToFit];
    [self layoutSubviews];
}

- (void)setCnyFont:(UIFont *)cnyFont
{
    _cnyFont = cnyFont;
    _cnyLabel.font = _cnyFont;
    [_cnyLabel sizeToFit];
    [self layoutSubviews];
}

- (void)setPriceFont:(UIFont *)priceFont
{
    _priceFont = priceFont;
    _priceLabel.font = _priceFont;
    [_cnyLabel sizeToFit];
    [self layoutSubviews];
}

- (void)setChangeayFont:(UIFont *)changeayFont
{
    _changeayFont = changeayFont;
    _changeayLabel.font = _changeayFont;
    [_cnyLabel sizeToFit];
    [self layoutSubviews];
}

- (void)setOriginx:(CGFloat)originx
{
    _originx = originx;
    [self layoutSubviews];
}

- (void)setOriginy:(CGFloat)originy
{
    _originy = originy;
    [self layoutSubviews];
}


- (void)setSpacex:(CGFloat)spacex
{
    _spacex = spacex;
    [self layoutSubviews];
}

- (void)setSpacey:(CGFloat)spacey
{
    _spacey = spacey;
    [self layoutSubviews];
}

- (void)setCoinLabelAlignment:(NSTextAlignment)coinLabelAlignment
{
    _coinLabelAlignment = coinLabelAlignment;
    _coinLabel.textAlignment = _coinLabelAlignment;
    [self layoutSubviews];
}

- (void)setCnyAlignment:(NSTextAlignment)cnyAlignment
{
    _cnyAlignment = cnyAlignment;
    _cnyLabel.textAlignment = _cnyAlignment;
    [self layoutSubviews];
}

- (void)setPriceAlignment:(NSTextAlignment)priceAlignment
{
    _priceAlignment = priceAlignment;
    _priceLabel.textAlignment = _priceAlignment;
    [self layoutSubviews];
}

- (void)setChangeayAlignment:(NSTextAlignment)changeayAlignment
{
    _changeayAlignment = changeayAlignment;
    _changeayLabel.textAlignment = _changeayAlignment;
    [self layoutSubviews];
}

@end
