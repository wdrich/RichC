//
//  RCHWithdrawListCell.m
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWithdrawListCell.h"

@interface RCHWithdrawListCell ()
{
    UILabel *_coinLabel;
    UILabel *_priceLabel;
    UILabel *_statusLabel;
    UIButton *_undoButton;
    UILabel *_timeLabel;
}

@end

@implementation RCHWithdrawListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _coinLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _coinLabel.textColor = kFontBlackColor;
        _coinLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:17.0f];
        _coinLabel.textAlignment = NSTextAlignmentLeft;
        _coinLabel.backgroundColor = [UIColor clearColor];
        _coinLabel.layer.masksToBounds = YES;
        [self addSubview:_coinLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:17.0f];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.textColor = kFontBlackColor;
        [self addSubview:_priceLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.textColor = kFontBlackColor;
        _statusLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        _statusLabel.textAlignment = NSTextAlignmentLeft;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.layer.masksToBounds = YES;
        [self addSubview:_statusLabel];
        
        _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _undoButton.backgroundColor = [UIColor whiteColor];
        _undoButton.layer.cornerRadius = 2.0f;
        _undoButton.layer.borderWidth = 1.0f;
        _undoButton.layer.borderColor = [kYellowColor CGColor];
        _undoButton.layer.masksToBounds = YES;
        _undoButton.frame = CGRectMake(0.0f, 0.0f, 60.0f, 28.0f);
        [_undoButton setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
        _undoButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        [_undoButton setTitleColor:kYellowColor forState:UIControlStateNormal];
        [_undoButton setTitleColor:kFontGrayColor forState:UIControlStateHighlighted];
        [_undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_undoButton];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = kFontLightGrayColor;
        _timeLabel.numberOfLines = 0;
        [_timeLabel setFont: [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f]];
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
    
    _coinLabel.frame = (CGRect){{originX, originY}, {_coinLabel.width, 24.0f}};
    _priceLabel.frame = (CGRect){{_coinLabel.right + 15.0f, _coinLabel.top}, {_priceLabel.width, 24.0f}};
    _timeLabel.frame = (CGRect){{_coinLabel.left, _coinLabel.bottom}, {_timeLabel.width, 18.0f}};
    
    _statusLabel.frame = (CGRect){{(self.contentView.width - originX - _statusLabel.width), (self.contentView.height - _statusLabel.height) / 2.0f}, {_statusLabel.width, 22.0f}};
    _undoButton.frame = (CGRect){{(self.contentView.width - originX - _undoButton.width), (self.contentView.height - _undoButton.height) / 2.0f}, {_undoButton.width, 28.0f}};
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
- (void)setWithdraw:(RCHWithdraw *)withdraw
{
    _withdraw = withdraw;
    [self reload];
}

- (void)reload
{
    NSString *defaultString = @"";
    {
        _coinLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_withdraw.coin_code) {
            _coinLabel.text = _withdraw.coin_code;
        } else {
            _coinLabel.text = defaultString;
        }
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_coinLabel.text Font:_coinLabel.font color:_coinLabel.textColor alignment:NSTextAlignmentLeft];
        _coinLabel.attributedText = attributedString;
        [_coinLabel sizeToFit];
    }
    
    {
        _priceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _priceLabel.text = [RCHHelper getNSDecimalString:_withdraw.arrival defaultString:defaultString precision:defaultPrecision];
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_priceLabel.text Font:_priceLabel.font color:_priceLabel.textColor alignment:NSTextAlignmentLeft];
        _priceLabel.attributedText = attributedString;
        [_priceLabel sizeToFit];
    }
    
    {
        _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        if (_withdraw.created_at) {
            _timeLabel.text = [RCHHelper transTimeStringFormat:_withdraw.created_at];
        } else {
            _timeLabel.text = defaultString;
        }
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_timeLabel.text Font:_timeLabel.font color:_timeLabel.textColor alignment:NSTextAlignmentLeft];
        _timeLabel.attributedText = attributedString;
        [_timeLabel sizeToFit];
    }
    
    
    {
        _statusLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _undoButton.frame = CGRectZero;
        if (_withdraw.resolved_at) {
            _statusLabel.text = NSLocalizedString(@"已完成", nil);
        } else if (_withdraw.revoked_at) {
            _statusLabel.text = NSLocalizedString(@"已取消", nil);
        } else if (_withdraw.confirmed_at) {
            _statusLabel.text = NSLocalizedString(@"进行中", nil);
        } else {
            _undoButton.frame = (CGRect){{0.0f, 0.0f}, {60.0f, 28.0f}};
            _statusLabel.text = defaultString;
        }
        
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_statusLabel.text Font:_statusLabel.font color:_statusLabel.textColor alignment:NSTextAlignmentLeft];
        _statusLabel.attributedText = attributedString;
        [_statusLabel sizeToFit];
    }
}

#pragma mark -
#pragma mark - ButtonClicked
- (void)undo:(id)sender
{
    if(_delegate && [(NSObject *)_delegate respondsToSelector:@selector(RCHWithdrawListCell:withdraw:)]) {
        [_delegate RCHWithdrawListCell:self withdraw:self.withdraw];
    }
}


@end
