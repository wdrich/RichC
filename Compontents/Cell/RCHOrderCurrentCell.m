//
//  RCHOrderCurrentCell.m
//  MeiBe
//
//  Created by WangDong on 2018/3/25.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHOrderCurrentCell.h"

@interface RCHOrderCurrentCell ()
{
    UILabel *_typeLabel;
    UILabel *_priceTypeLabel;
    UILabel *_coinLabel;
    UILabel *_priceTitleLabel;
    UILabel *_priceLabel;
    UILabel *_countTitleLabel;
    UILabel *_countLabel;
    UIButton *_undoButton;
    UILabel *_timeLabel;
}

@end

@implementation RCHOrderCurrentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.textColor = kFontBlackColor;
        _typeLabel.numberOfLines = 0;
        _typeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.layer.masksToBounds = YES;
        [self addSubview:_typeLabel];
    
        _priceTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceTypeLabel.textColor = kFontBlackColor;
        _priceTypeLabel.numberOfLines = 0;
        _priceTypeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
        _priceTypeLabel.textAlignment = NSTextAlignmentLeft;
        _priceTypeLabel.backgroundColor = [UIColor clearColor];
        _priceTypeLabel.layer.masksToBounds = YES;
        [self addSubview:_priceTypeLabel];
        
        _coinLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _coinLabel.textColor = kFontBlackColor;
        _coinLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
        _coinLabel.textAlignment = NSTextAlignmentLeft;
        _coinLabel.backgroundColor = [UIColor clearColor];
        _coinLabel.layer.masksToBounds = YES;
        [self addSubview:_coinLabel];
        
        _priceTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceTitleLabel.textColor = kFontLightGrayColor;
        _priceTitleLabel.text = @"价格";
        _priceTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        _priceTitleLabel.numberOfLines = 0;
        _priceTitleLabel.textAlignment = NSTextAlignmentLeft;
        _priceTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_priceTitleLabel];
        [_priceTitleLabel sizeToFit];
        _priceTitleLabel.size = (CGSize){_priceTitleLabel.width, 16.0f};
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.numberOfLines = 3;
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.textColor = kFontBlackColor;
        [self addSubview:_priceLabel];
        
        _countTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countTitleLabel.textColor = kFontLightGrayColor;
        _countTitleLabel.text = @"数量";
        _countTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        _countTitleLabel.textAlignment = NSTextAlignmentLeft;
        _countTitleLabel.backgroundColor = [UIColor clearColor];
        _countTitleLabel.layer.masksToBounds = YES;
        [self addSubview:_countTitleLabel];
        [_countTitleLabel sizeToFit];
        _countTitleLabel.size = (CGSize){_countTitleLabel.width, 16.0f};
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textColor = kFontLightGrayColor;
        _countLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.layer.masksToBounds = YES;
        [self addSubview:_countLabel];
        
        _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _undoButton.backgroundColor = [UIColor whiteColor];
        _undoButton.layer.cornerRadius = 2.0f;
        _undoButton.layer.borderWidth = 0.5f;
        _undoButton.layer.borderColor = [kYellowColor CGColor];
        _undoButton.layer.masksToBounds = YES;
        _undoButton.frame = CGRectMake(0.0f, 0.0f, 70.0f, 28.0f);
        //    [_undoButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [_undoButton setTitle:NSLocalizedString(@"撤单",nil) forState:UIControlStateNormal];
        _undoButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
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
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originX = 15.0f;
    CGFloat originY = 15.0f;
    
    _typeLabel.frame = (CGRect){{originX, originY}, _typeLabel.frame.size};
    _priceTypeLabel.frame = (CGRect){{_typeLabel.left, _typeLabel.bottom}, _priceTypeLabel.frame.size};
    _coinLabel.frame = (CGRect){{_typeLabel.right + 10.0f, _typeLabel.top}, _coinLabel.frame.size};
    
    _countTitleLabel.frame = (CGRect){{_coinLabel.left, _coinLabel.bottom + 2.0f}, _countTitleLabel.frame.size};
    _countLabel.frame = (CGRect){{_countTitleLabel.right + 10.0f, _countTitleLabel.top}, _countLabel.frame.size};
    
    _priceTitleLabel.frame = (CGRect){{_coinLabel.left, _countTitleLabel.bottom + 3.0f}, _priceTitleLabel.frame.size};
    _priceLabel.frame = (CGRect){{_priceTitleLabel.right + 10.0f, _priceTitleLabel.top}, _priceLabel.frame.size};
    
    _timeLabel.frame = (CGRect){{(self.contentView.width - originX - _timeLabel.width), _typeLabel.top}, _timeLabel.frame.size};
    _undoButton.frame = (CGRect){{(self.contentView.width - originX - _undoButton.width), _timeLabel.bottom + 10.0f}, _undoButton.frame.size};
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
        _priceTypeLabel.textColor =  kTradePositiveColor;
    } else {
        aim = @"卖出";
        _typeLabel.textColor = kTradeNegativeColor;
        _priceTypeLabel.textColor = kTradeNegativeColor;
    }
    
    {
        _typeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        
        NSString *dtype;
        if ([_order._dtype isEqualToString:@"limit"]) {
            dtype = @"限价";
        } else {
            dtype = @"市价";
        }
        
        _typeLabel.text = dtype;
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_typeLabel.text Font:_typeLabel.font color:_typeLabel.textColor alignment:NSTextAlignmentLeft];
        _typeLabel.attributedText = attributedString;
        [_typeLabel sizeToFit];
        _typeLabel.size = (CGSize){_typeLabel.width, 20.0f};
    }
    
    {
        _priceTypeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        
        _priceTypeLabel.text = aim;
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_priceTypeLabel.text Font:_priceTypeLabel.font color:_priceTypeLabel.textColor alignment:NSTextAlignmentLeft];
        _priceTypeLabel.attributedText = attributedString;
        [_priceTypeLabel sizeToFit];
        _priceTypeLabel.size = (CGSize){_priceTypeLabel.width, 20.0f};
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
    
    _priceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    NSString *price = [RCHHelper getNSDecimalString:_order.price defaultString:@"--" precision:8];
    attributedString = [RCHHelper getMutableAttributedStringe:price Font:_priceLabel.font color:_priceLabel.textColor alignment:NSTextAlignmentLeft];
    _priceLabel.attributedText = attributedString;
    [_priceLabel sizeToFit];
    _priceLabel.size = (CGSize){_priceLabel.width, 16.0f};
    
    NSString *successCount;
    _countLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    NSString *totalCount = [RCHHelper getNSDecimalString:_order.amount defaultString:defaultString precision:8];
    if (_order.transactions && [_order.transactions count] > 0) {
        NSDecimalNumber *sum = [NSDecimalNumber zero];
        for (RCHTransaction *trans in _order.transactions) {
            sum = [sum decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[trans.amount decimalValue]]];
        }
        successCount = [RCHHelper getNSDecimalString:sum defaultString:defaultString precision:8];
    } else {
        successCount = defaultString;
    }
    NSString *count = [NSString stringWithFormat:@"%@/%@", successCount, totalCount];
    attributedString = [[NSMutableAttributedString alloc] initWithString:count];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:1];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [count length])];
    [attributedString addAttribute:NSFontAttributeName value:_countLabel.font range:NSMakeRange(0, [count length])];
    [attributedString addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange(0, [[NSString stringWithFormat:@"%@", successCount] length])];
    
    _countLabel.attributedText = attributedString;
    [_countLabel sizeToFit];
    _countLabel.size = (CGSize){_countLabel.width, 16.0f};
    
    {
        _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_order.created_at) {
            _timeLabel.text = [RCHHelper transTimeStringFormat:_order.created_at];
        } else {
            _timeLabel.text = defaultString;
        }
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_timeLabel.text Font:_timeLabel.font color:_timeLabel.textColor alignment:NSTextAlignmentLeft];
        _timeLabel.attributedText = attributedString;
        [_timeLabel sizeToFit];
        _timeLabel.size = (CGSize){_timeLabel.width, 17.0f};
    }
}

#pragma mark -
#pragma mark - ButtonClicked
- (void)undo:(id)sender
{
//    UIButton *button = (UIButton *)sender;
    if(_delegate && [(NSObject *)_delegate respondsToSelector:@selector(RCHOrderCurrentCell:order:)]) {
        [_delegate RCHOrderCurrentCell:self order:self.order];
    }
}

@end
