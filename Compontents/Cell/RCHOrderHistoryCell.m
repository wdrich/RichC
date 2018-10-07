//
//  RCHOrderHistoryCell.m
//  MeiBe
//
//  Created by WangDong on 2018/3/24.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHOrderHistoryCell.h"


@interface RCHOrderHistoryCell ()
{
    UILabel *_typeLabel;
    UILabel *_coinLabel;
    UILabel *_coinBaseLabel;
    UILabel *_avgPriceLabel;
    UILabel *_priceLabel;
    UILabel *_countLabel;
    UILabel *_successCountLabel;
    UILabel *_timeLabel;
}

@end


@implementation RCHOrderHistoryCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.textColor = kFontBlackColor;
        _typeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.layer.masksToBounds = YES;
        [self addSubview:_typeLabel];
        
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
        
        _avgPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _avgPriceLabel.textColor = kFontBlackColor;
        _avgPriceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0f];
        _avgPriceLabel.textAlignment = NSTextAlignmentLeft;
        _avgPriceLabel.backgroundColor = [UIColor clearColor];
        _avgPriceLabel.layer.masksToBounds = YES;
        [self addSubview:_avgPriceLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.numberOfLines = 3;
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.textColor = kFontLightGrayColor;
        [self addSubview:_priceLabel];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textColor = kFontLightGrayColor;
        _countLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.layer.masksToBounds = YES;
        [self addSubview:_countLabel];
        
        
        _successCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _successCountLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0f];
        _successCountLabel.backgroundColor = [UIColor clearColor];
        _successCountLabel.numberOfLines = 3;
        _successCountLabel.textAlignment = NSTextAlignmentRight;
        _successCountLabel.textColor = kFontBlackColor;
        [self addSubview:_successCountLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = kFontLightGrayColor;
        _timeLabel.numberOfLines = 0;
        [_timeLabel setFont: [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f]];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_timeLabel];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originX = 15.0f;
    CGFloat originY = (self.contentView.height - _typeLabel.height - _timeLabel.height) / 2.0f;
    
    _typeLabel.frame = (CGRect){{originX, originY}, _typeLabel.frame.size};
    _coinLabel.frame = (CGRect){{_typeLabel.right + 5.0f, _typeLabel.top}, _coinLabel.frame.size};
    _coinBaseLabel.frame = (CGRect){{_coinLabel.right + 3.0f, _typeLabel.top}, _coinBaseLabel.frame.size};
    _timeLabel.frame = (CGRect){{_typeLabel.left, _typeLabel.bottom}, _timeLabel.frame.size};
    
    _avgPriceLabel.frame = (CGRect){{170.0f, originY}, _avgPriceLabel.frame.size};
    _priceLabel.frame = (CGRect){{_avgPriceLabel.left, _avgPriceLabel.bottom}, _priceLabel.frame.size};

    _successCountLabel.frame = (CGRect){{(self.contentView.width - originX - _successCountLabel.width), originY}, _successCountLabel.frame.size};
    _countLabel.frame = (CGRect){{(self.contentView.width - originX - _countLabel.width), _successCountLabel.bottom}, _countLabel.frame.size};
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

- (void)setOrder:(RCHOrder *)order
{
    _order = order;
    
    if (_order.revoked_at && [_order.transactions count] == 0) {
        self.backgroundColor = kTabbleViewBackgroudColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    NSMutableAttributedString *attributedString = nil;
    NSString *defaultString = @"--";
    {
        _typeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if ([_order.aim isEqualToString:@"buy"]) {
            _typeLabel.text = @"买";
            _typeLabel.textColor =  kTradePositiveColor;
        } else {
            _typeLabel.text = @"卖";
            _typeLabel.textColor = kTradeNegativeColor;
        }
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_typeLabel.text Font:_typeLabel.font color:_typeLabel.textColor alignment:NSTextAlignmentLeft];
        _typeLabel.attributedText = attributedString;
        [_typeLabel sizeToFit];
        _typeLabel.frame = (CGRect){{0.0f, 0.0f}, {_typeLabel.width, 20.0f}};
    }
    
    {
        _coinLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_order.market.coin.code) {
            _coinLabel.text = _order.market.coin.code;
        } else {
            _coinLabel.text = defaultString;
        }
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_coinLabel.text Font:_coinLabel.font color:_coinLabel.textColor alignment:NSTextAlignmentLeft];
        _coinLabel.attributedText = attributedString;
        [_coinLabel sizeToFit];
        _coinLabel.frame = (CGRect){{0.0f, 0.0f}, {_coinLabel.width, 20.0f}};
    }
    
    {
        _coinBaseLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        
        if (_order.market.currency.code) {
            _coinBaseLabel.text = [NSString stringWithFormat:@"/%@", _order.market.currency.code];
        } else {
            _coinBaseLabel.text = defaultString;
        }
        
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_coinBaseLabel.text Font:_coinBaseLabel.font color:_coinBaseLabel.textColor alignment:NSTextAlignmentLeft];
        _coinBaseLabel.attributedText = attributedString;
        [_coinBaseLabel sizeToFit];
        _coinBaseLabel.frame = (CGRect){{0.0f, 0.0f}, {_coinBaseLabel.width, 20.0f}};
    }
    
    _avgPriceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_order.transactions && [_order.transactions count] > 0) {
        NSDecimalNumber *amountSum = [NSDecimalNumber zero];
        NSDecimalNumber *priceSum = [NSDecimalNumber zero];
        for (RCHTransaction *trans in _order.transactions) {
            amountSum = [amountSum decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[trans.amount decimalValue]]];
            NSDecimalNumber *price = [[NSDecimalNumber decimalNumberWithDecimal:[trans.amount decimalValue]] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[trans.price decimalValue]]];
            priceSum = [priceSum decimalNumberByAdding:price];
        }
        
        NSDecimalNumber *avg;
        if ([amountSum compare:[NSDecimalNumber zero]] == NSOrderedSame) {
            avg = nil;
        } else {
            avg = [priceSum decimalNumberByDividingBy:amountSum];
        }

        NSString *price = [RCHHelper getNSDecimalString:avg defaultString:defaultString precision:8];
        attributedString = [RCHHelper getMutableAttributedStringe:price Font:_priceLabel.font color:_priceLabel.textColor alignment:NSTextAlignmentLeft];
        
    } else {
        attributedString = [RCHHelper getMutableAttributedStringe:defaultString Font:_priceLabel.font color:_priceLabel.textColor alignment:NSTextAlignmentLeft];
    }
    _avgPriceLabel.attributedText = attributedString;
    [_avgPriceLabel sizeToFit];
    
    _priceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_order.price) {
        NSString *price = [RCHHelper getNSDecimalString:_order.price defaultString:defaultString precision:8];
        attributedString = [RCHHelper getMutableAttributedStringe:price Font:_avgPriceLabel.font color:_avgPriceLabel.textColor alignment:NSTextAlignmentLeft];
        
    } else {
        attributedString = [RCHHelper getMutableAttributedStringe:defaultString Font:_avgPriceLabel.font color:_avgPriceLabel.textColor alignment:NSTextAlignmentLeft];
    }
    _priceLabel.attributedText = attributedString;
    [_priceLabel sizeToFit];
    
    _countLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_order.amount) {
        NSString *count = [RCHHelper getNSDecimalString:_order.amount defaultString:defaultString precision:8];
        attributedString = [RCHHelper getMutableAttributedStringe:count Font:_countLabel.font color:_countLabel.textColor alignment:NSTextAlignmentLeft];
    } else {
        attributedString = [RCHHelper getMutableAttributedStringe:defaultString Font:_countLabel.font color:_countLabel.textColor alignment:NSTextAlignmentLeft];
    }
    _countLabel.attributedText = attributedString;
    [_countLabel sizeToFit];
    
    _successCountLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_order.transactions && [_order.transactions count] > 0) {
        NSDecimalNumber *sum = [NSDecimalNumber zero];
        for (RCHTransaction *trans in _order.transactions) {
            sum = [sum decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[trans.amount decimalValue]]];
        }
        
        NSString *count = [RCHHelper getNSDecimalString:sum defaultString:defaultString precision:8];
        attributedString = [RCHHelper getMutableAttributedStringe:count Font:_successCountLabel.font color:_successCountLabel.textColor alignment:NSTextAlignmentLeft];
    } else {
        attributedString = [RCHHelper getMutableAttributedStringe:defaultString Font:_successCountLabel.font color:_successCountLabel.textColor alignment:NSTextAlignmentLeft];
    }
    _successCountLabel.attributedText = attributedString;
    [_successCountLabel sizeToFit];
    
    {
        _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_order.created_at) {
            _timeLabel.text = [RCHHelper getStempString:_order.created_at];
        } else {
            _timeLabel.text = defaultString;
        }
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_timeLabel.text Font:_timeLabel.font color:_timeLabel.textColor alignment:NSTextAlignmentLeft];
        _timeLabel.attributedText = attributedString;
        [_timeLabel sizeToFit];
        _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {_timeLabel.width, 20.0f}};
    }
}

@end
