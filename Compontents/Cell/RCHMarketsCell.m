//
//  RCHRCHMarketsCell.m
//  MeiBe
//
//  Created by WangDong on 2018/3/21.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMarketsCell.h"
#import "MJLOnePixLineView.h"

@interface RCHMarketsCell ()
{
    UILabel *_coinLabel;
    UILabel *_coinBaseLabel;
    UILabel *_priceLabel;
    UILabel *_changeLabel;
    
    MJLOnePixLineView *_spacelineView;
    
}

@end

@implementation RCHMarketsCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tickerUpdated:)
                                                     name:kTickerUpdatedNotification
                                                   object:nil];
        
        _coinLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _coinLabel.textColor = kFontBlackColor;
        _coinLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17.0f];
        _coinLabel.textAlignment = NSTextAlignmentLeft;
        _coinLabel.backgroundColor = [UIColor clearColor];
        _coinLabel.layer.masksToBounds = YES;
        [self addSubview:_coinLabel];
        
        _coinBaseLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _coinBaseLabel.textColor = kFontLightGrayColor;
        _coinBaseLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        _coinBaseLabel.numberOfLines = 0;
        _coinBaseLabel.textAlignment = NSTextAlignmentLeft;
        _coinBaseLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_coinBaseLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17.0f];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.numberOfLines = 3;
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.textColor = kFontGrayColor;
        [self addSubview:_priceLabel];
        
        _changeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _changeLabel.textColor = kFontBlackColor;
        _changeLabel.numberOfLines = 0;
        [_changeLabel setFont: [UIFont fontWithName:@"PingFangSC-Medium" size:17.0f]];
        _changeLabel.textAlignment = NSTextAlignmentRight;
        [_changeLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_changeLabel];
        
        _spacelineView = [[MJLOnePixLineView alloc] initWithFrame:CGRectZero];
        _spacelineView.lineType = MJLOnePixLineViewImage;
        _spacelineView.lineImageName = @"line_e1_U.png";
        [self addSubview:_spacelineView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originX = 15.0f;
    
    _coinLabel.frame = (CGRect){{originX, 0.0f}, _coinLabel.frame.size};
    _coinLabel.center = CGPointMake(_coinLabel.center.x, self.contentView.center.y);
    
    _coinBaseLabel.frame = (CGRect){{_coinLabel.right + 3.0f, 0.0f}, _coinBaseLabel.frame.size};
    _coinBaseLabel.center = CGPointMake(_coinBaseLabel.center.x, self.contentView.center.y);
    
    _priceLabel.frame = (CGRect){{140.0f, 0.0f}, _priceLabel.frame.size};
    _priceLabel.center = CGPointMake(_priceLabel.center.x, self.contentView.center.y);
    
    _changeLabel.frame = (CGRect){{self.width - originX - _changeLabel.width, 0.0f}, _changeLabel.frame.size};
    _changeLabel.center = CGPointMake(_changeLabel.center.x, self.contentView.center.y);
    
    _spacelineView.frame = (CGRect){{0.0f, self.height - 1.0f}, {self.width, 1.0f}};
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

- (void)setMarket:(RCHMarket *)market
{
    _market = market;
    [self reload];
}

- (void)reload
{
    NSString *defaultString = @"--";
    {
        _coinLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _coinLabel.text = _market.coin.code;
        NSMutableAttributedString *attributedString = [self getMutableAttributedString:_coinLabel.text Font:_coinLabel.font color:_coinLabel.textColor alignment:NSTextAlignmentLeft];
        _coinLabel.attributedText = attributedString;
        [_coinLabel sizeToFit];
    }
    
    {
        _coinBaseLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _coinBaseLabel.text = [NSString stringWithFormat:@"/%@", _market.currency.code];
        
        NSMutableAttributedString *attributedString = [self getMutableAttributedString:_coinBaseLabel.text Font:_coinBaseLabel.font color:_coinBaseLabel.textColor alignment:NSTextAlignmentLeft];
        _coinBaseLabel.attributedText = attributedString;
        [_coinBaseLabel sizeToFit];
    }
    
    _priceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_market.state && _market.state.last_price) {
        NSNumberFormatter *format = [RCHHelper getNumberFormatterFractionDigits:_market.priceScale fractionDigitsPadded:YES];
        _priceLabel.attributedText = [self getMutableAttributedString:[format stringFromNumber:_market.state.last_price] Font:_priceLabel.font color:_priceLabel.textColor alignment:NSTextAlignmentLeft];
    } else {
        _priceLabel.attributedText = [self getMutableAttributedString:defaultString Font:_priceLabel.font color:kFontLightGrayColor alignment:NSTextAlignmentLeft];
    }
    [_priceLabel sizeToFit];
    
    _changeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_market.state && _market.state.price_change_percent) {
        NSString *text;
        NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
        [format setNumberStyle:NSNumberFormatterDecimalStyle];
        [format setPositiveFormat:@"####.##"];
        [format setMaximumFractionDigits:2];
        
        NSString *percent = [NSString stringWithFormat:@"%@", [NSDecimalNumber decimalNumberWithString:[format stringFromNumber:_market.state.price_change_percent]]];
        NSComparisonResult result = [_market.state.price_change_percent compare:[NSDecimalNumber zero]];
        if (result == NSOrderedDescending) {
            text = [NSString stringWithFormat:@"+%@%%", percent];
            _changeLabel.textColor = kTradePositiveColor;
        } else {
            text = [NSString stringWithFormat:@"%@%%", percent];
            _changeLabel.textColor = result == NSOrderedAscending ? kTradeNegativeColor : kTradeSameColor;
        }
        
        NSMutableAttributedString *attributedString = [self getMutableAttributedString:text Font:_changeLabel.font color:_changeLabel.textColor alignment:NSTextAlignmentRight];
        _changeLabel.attributedText = attributedString;
    } else {
        _changeLabel.attributedText = [self getMutableAttributedString:defaultString Font:_changeLabel.font color:kFontLightGrayColor alignment:NSTextAlignmentRight];
    }
    [_changeLabel sizeToFit];
}


- (NSMutableAttributedString *)getMutableAttributedString:(NSString *)title Font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment
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

- (void)tickerUpdated:(NSNotification *)note
{
    if (_market && [_market.symbol isEqualToString:[[note userInfo] objectForKey:@"symbol"]]) {
        [self reload];
    }
}

@end
