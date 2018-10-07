//
//  RCHOrderCell.m
//  richcore
//
//  Created by WangDong on 2018/7/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHOrderCell.h"
#import "MJLOnePixLineView.h"

@interface RCHOrderCell ()
{
    UILabel *_typeLabel;
    UILabel *_coinLabel;
    UILabel *_priceTitleLabel;
    UILabel *_priceLabel;
    UILabel *_countTitleLabel;
    UILabel *_countLabel;
    UILabel *_transactionTitleLable;
    UILabel *_transactionLable;
    UIButton *_undoButton;
    UILabel *_timeLabel;
    
    MJLOnePixLineView *_spacelineView;
}

@end

@implementation RCHOrderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _originX = 15.0f;
        _separatorX = 0.0f;
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.textColor = kFontBlackColor;
        _typeLabel.numberOfLines = 0;
        _typeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.layer.masksToBounds = YES;
        [self addSubview:_typeLabel];

        _priceTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceTitleLabel.textColor = kTextUnselectColor;
        _priceTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        _priceTitleLabel.textAlignment = NSTextAlignmentLeft;
        _priceTitleLabel.backgroundColor = [UIColor clearColor];
        _priceTitleLabel.layer.masksToBounds = YES;
        [self addSubview:_priceTitleLabel];
        
        _coinLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _coinLabel.textColor = kFontBlackColor;
        _coinLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
        _coinLabel.textAlignment = NSTextAlignmentLeft;
        _coinLabel.backgroundColor = [UIColor clearColor];
        _coinLabel.layer.masksToBounds = YES;
        [self addSubview:_coinLabel];
        
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.textColor = kTextColor_MB;
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        _priceLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_priceLabel];
        
        _countTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countTitleLabel.textColor = kTextUnselectColor;
        _countTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        _countTitleLabel.textAlignment = NSTextAlignmentLeft;
        _countTitleLabel.backgroundColor = [UIColor clearColor];
        _countTitleLabel.layer.masksToBounds = YES;
        [self addSubview:_countTitleLabel];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textColor = kTextColor_MB;
        _countLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_countLabel];
        
        _transactionTitleLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _transactionTitleLable.textColor = kTextUnselectColor;
        _transactionTitleLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        _transactionTitleLable.textAlignment = NSTextAlignmentLeft;
        _transactionTitleLable.backgroundColor = [UIColor clearColor];
        _transactionTitleLable.layer.masksToBounds = YES;
        [self addSubview:_transactionTitleLable];
        
        _transactionLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _transactionLable.textColor = kTextColor_MB;
        _transactionLable.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
        _transactionLable.textAlignment = NSTextAlignmentRight;
        _transactionLable.backgroundColor = [UIColor clearColor];
        [self addSubview:_transactionLable];
        
        _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _undoButton.frame = CGRectMake(0.0f, 0.0f, 26.0f, 16.0f);
        [_undoButton setTitle:NSLocalizedString(@"撤单",nil) forState:UIControlStateNormal];
        _undoButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        [_undoButton setTitleColor:kYellowColor forState:UIControlStateNormal];
        [_undoButton setTitleColor:kFontGrayColor forState:UIControlStateHighlighted];
        [_undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_undoButton];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = kFontLightGrayColor;
        _timeLabel.numberOfLines = 0;
        [_timeLabel setFont: [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_timeLabel];
        
        _spacelineView = [[MJLOnePixLineView alloc] initWithFrame:CGRectZero];
        [self addSubview:_spacelineView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat originY = 20.0f;
    
    _typeLabel.frame = (CGRect){{_originX, originY}, _typeLabel.frame.size};
    
    if (self.showCoin) {
        _coinLabel.frame = (CGRect){{_typeLabel.right + 5.0f, _typeLabel.top}, _coinLabel.frame.size};
        _coinLabel.centerY = _typeLabel.centerY;
    } else {
        _coinLabel.frame = (CGRect){{_typeLabel.right, _typeLabel.top},{0.0f, 0.0f}};
    }
    
    _timeLabel.frame = (CGRect){{_coinLabel.right + 10.0f, _coinLabel.top}, _timeLabel.frame.size};
    _timeLabel.centerY = _typeLabel.centerY;
    
    
    
    
    _priceTitleLabel.frame = (CGRect){{_typeLabel.left, _typeLabel.bottom + 10.0f}, _priceTitleLabel.frame.size};
    _priceLabel.frame = (CGRect){{_priceTitleLabel.left, _priceTitleLabel.bottom + 5.0f}, _priceLabel.frame.size};
    
    _countTitleLabel.frame = (CGRect){{160.0f, _priceTitleLabel.top}, _countTitleLabel.frame.size};
    _countLabel.frame = (CGRect){{_countTitleLabel.left, _countTitleLabel.bottom + 5.0f}, _countLabel.frame.size};
    
    _transactionTitleLable.frame = (CGRect){{(self.contentView.width - _originX - _transactionTitleLable.width), _countTitleLabel.top}, _transactionTitleLable.frame.size};
    _transactionLable.frame = (CGRect){{(self.contentView.width - _originX - _transactionLable.width), _countLabel.top}, _transactionLable.frame.size};
    
    _undoButton.frame = (CGRect){{(self.contentView.width - _originX - _undoButton.width), _timeLabel.bottom + 10.0f}, _undoButton.frame.size};
    _undoButton.centerY = _typeLabel.centerY;
    
    _spacelineView.frame = (CGRect){{_separatorX, self.height - [RCHHelper retinaFloat:0.5f]}, {self.width - _separatorX * 2, [RCHHelper retinaFloat:0.5f]}};
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
    [self reload];
}

- (void)reload
{
    NSMutableAttributedString *attributedString = nil;
    NSString *defaultString = @"0";
    
    NSString *aim;
    if ([_order.aim isEqualToString:@"buy"]) {
        aim = @"买入";
        _typeLabel.textColor = kTradePositiveColor;
    } else {
        aim = @"卖出";
        _typeLabel.textColor = kTradeNegativeColor;;
    }
    
    {
        NSString *coin;
        NSString *coin_base;
        if (_order.market.coin.code) {
            coin = _order.market.coin.code;
        } else {
            coin = defaultString;
        }
        
        if (_order.market.currency.code) {
            coin_base = _order.market.currency.code;
        } else {
            coin_base = defaultString;
        }
        
        _coinLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        
        _coinLabel.text = [NSString stringWithFormat:@"%@/%@", coin, coin_base];
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_coinLabel.text Font:_coinLabel.font color:_coinLabel.textColor alignment:NSTextAlignmentLeft];
        _coinLabel.attributedText = attributedString;
        [_coinLabel sizeToFit];
        _coinLabel.size = (CGSize){_coinLabel.width, 20.0f};
    }
    
    {
        _typeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _typeLabel.text = aim;
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_typeLabel.text Font:_typeLabel.font color:_typeLabel.textColor alignment:NSTextAlignmentLeft];
        _typeLabel.attributedText = attributedString;
        [_typeLabel sizeToFit];
        _typeLabel.size = (CGSize){_typeLabel.width, 16.0f};
    }
    
    {
        _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_order.created_at) {
            _timeLabel.text = [[NSDate dateWithISOFormatString:_order.created_at] stringWithFormat:@"MM-dd HH:mm:ss"];
        } else {
            _timeLabel.text = @"--";
        }
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_timeLabel.text Font:_timeLabel.font color:_timeLabel.textColor alignment:NSTextAlignmentLeft];
        _timeLabel.attributedText = attributedString;
        [_timeLabel sizeToFit];
        _timeLabel.size = (CGSize){_timeLabel.width, 17.0f};
    }

    {
        NSString *coin;
        if (_order.market.coin.code) {
            coin = _order.market.currency.code;
        } else {
            coin = defaultString;
        }
        
        _priceTitleLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        
        _priceTitleLabel.text = [NSString stringWithFormat:@"价格(%@)", coin];
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_priceTitleLabel.text Font:_priceTitleLabel.font color:_priceTitleLabel.textColor alignment:NSTextAlignmentLeft];
        _priceTitleLabel.attributedText = attributedString;
        [_priceTitleLabel sizeToFit];
        _priceTitleLabel.size = (CGSize){_priceTitleLabel.width, 14.0f};
    }
    
    {
        NSString *coin_base;
        if (_order.market.currency.code) {
            coin_base = _order.market.currency.code;
        } else {
            coin_base = defaultString;
        }

        _priceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        NSString *price = [RCHHelper getNSDecimalString:_order.price defaultString:@"--" precision:8];
        attributedString = [RCHHelper getMutableAttributedStringe:price Font:_priceLabel.font color:_priceLabel.textColor alignment:NSTextAlignmentLeft];
        _priceLabel.attributedText = attributedString;
        [_priceLabel sizeToFit];
        _priceLabel.size = (CGSize){_priceLabel.width, 16.0f};
    }
    
    {
        NSString *coin_base;
        if (_order.market.currency.code) {
            coin_base = _order.market.coin.code;
        } else {
            coin_base = defaultString;
        }

        _countTitleLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        
        _countTitleLabel.text = [NSString stringWithFormat:@"数量(%@)", coin_base];
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_countTitleLabel.text Font:_countTitleLabel.font color:_countTitleLabel.textColor alignment:NSTextAlignmentLeft];
        _countTitleLabel.attributedText = attributedString;
        [_countTitleLabel sizeToFit];
        _countTitleLabel.size = (CGSize){_countTitleLabel.width, 14.0f};
    }
    
    {
        _countLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        NSString *totalCount = [RCHHelper getNSDecimalString:_order.amount defaultString:defaultString precision:8];
        NSString *count = [NSString stringWithFormat:@"%@", totalCount];
        attributedString = [[NSMutableAttributedString alloc] initWithString:count];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [count length])];
        [attributedString addAttribute:NSFontAttributeName value:_countLabel.font range:NSMakeRange(0, [count length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kTextColor_MB range:NSMakeRange(0, [count length])];
        
        _countLabel.attributedText = attributedString;
        [_countLabel sizeToFit];
        _countLabel.size = (CGSize){_countLabel.width, 16.0f};
    }
    
    {
        NSString *coin_base;
        if (_order.market.currency.code) {
            coin_base = _order.market.coin.code;
        } else {
            coin_base = defaultString;
        }
        
        _transactionTitleLable.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        
        _transactionTitleLable.text = [NSString stringWithFormat:@"已成交(%@)", coin_base];
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_transactionTitleLable.text Font:_transactionTitleLable.font color:_transactionTitleLable.textColor alignment:NSTextAlignmentLeft];
        _transactionTitleLable.attributedText = attributedString;
        [_transactionTitleLable sizeToFit];
        _transactionTitleLable.size = (CGSize){_transactionTitleLable.width, 14.0f};
    }
    
    {
        NSString *successCount;
        if (_order.transactions && [_order.transactions count] > 0) {
            NSDecimalNumber *sum = [NSDecimalNumber zero];
            for (RCHTransaction *trans in _order.transactions) {
                sum = [sum decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[trans.amount decimalValue]]];
            }
            successCount = [RCHHelper getNSDecimalString:sum defaultString:defaultString precision:8];
        } else {
            successCount = defaultString;
        }
        
        _transactionLable.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        attributedString = [RCHHelper getMutableAttributedStringe:successCount Font:_transactionLable.font color:_transactionLable.textColor alignment:NSTextAlignmentLeft];
        _transactionLable.attributedText = attributedString;
        [_transactionLable sizeToFit];
        _transactionLable.size = (CGSize){_transactionLable.width, 16.0f};
    }

}

- (void)setOriginX:(CGFloat)originX
{
    _originX = originX;
    [self layoutSubviews];
}

- (void)setSeparatorX:(CGFloat)separatorX
{
    _separatorX = separatorX;
    [self layoutSubviews];
}

#pragma mark -
#pragma mark - ButtonClicked
- (void)undo:(id)sender
{
    //    UIButton *button = (UIButton *)sender;
    if(_delegate && [(NSObject *)_delegate respondsToSelector:@selector(RCHOrderCell:order:)]) {
        [_delegate RCHOrderCell:self order:self.order];
    }
}

@end
