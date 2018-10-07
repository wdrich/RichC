//
//  RCHFlowListCell.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHFlowListCell.h"
#import "MJLOnePixLineView.h"

@interface RCHFlowListCell ()
{
    UILabel *_codeLabel;
    UILabel *_timeLabel;
    UILabel *_balanceLabel;
    UILabel *_statusLabel;
    
    MJLOnePixLineView *_spacelineView;
}

@end

@implementation RCHFlowListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codeLabel.textColor = kFontBlackColor;
        _codeLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:17.0f];
        _codeLabel.textAlignment = NSTextAlignmentLeft;
        _codeLabel.backgroundColor = [UIColor clearColor];
        _codeLabel.layer.masksToBounds = YES;
        [self addSubview:_codeLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.textColor = kFontBlackColor;
        _statusLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        _statusLabel.numberOfLines = 0;
        _statusLabel.textAlignment = NSTextAlignmentLeft;
        _statusLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_statusLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = kFontLightGrayColor;
        _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        _timeLabel.numberOfLines = 0;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
        
        _balanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _balanceLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:17.0f];
        _balanceLabel.backgroundColor = [UIColor clearColor];
        _balanceLabel.numberOfLines = 3;
        _balanceLabel.textAlignment = NSTextAlignmentRight;
        _balanceLabel.textColor = kFontBlackColor;
        [self addSubview:_balanceLabel];
        
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
    
    CGFloat originY = (self.height - _codeLabel.height - _timeLabel.height) / 2.0f;
    
    
    _codeLabel.frame = (CGRect){{originX, originY}, _codeLabel.frame.size};
    _balanceLabel.frame = (CGRect){{_codeLabel.right + originX, _codeLabel.top}, _balanceLabel.frame.size};
    _timeLabel.frame = (CGRect){{originX, _codeLabel.bottom}, _timeLabel.frame.size};
    
    originY = (self.height - _statusLabel.height) / 2.0f;
    _statusLabel.frame = (CGRect){{self.width - originX - _statusLabel.width, originY}, _statusLabel.frame.size};
    
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

- (void)setFlow:(RCHFlow *)flow
{
    _flow = flow;
    NSString *defaultString = @"";
    
    _codeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_flow.coin_code) {
        _codeLabel.text = _flow.coin_code;
    } else {
        _codeLabel.text = defaultString;
    }
    [RCHHelper getMutableAttributedStringe:_codeLabel.text Font:_codeLabel.font color:_codeLabel.textColor alignment:_codeLabel.textAlignment];
    [_codeLabel sizeToFit];
    _codeLabel.frame = (CGRect){{0.0f, 0.0f}, {_codeLabel.width, 24.0f}};
    
    _balanceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if ([_flow._dtype isEqualToString:@"share_unlock"]) {
        NSNumberFormatter *formatter = [RCHHelper getNumberFormatterFractionDigits:flow.coin.scale fractionDigitsPadded:YES];
        [formatter setUsesGroupingSeparator:YES];
        [formatter setGroupingSize:3];
        _balanceLabel.text = [formatter stringFromNumber:_flow.quantity];
    } else {
        _balanceLabel.text = [RCHHelper getNSDecimalString:_flow.quantity defaultString:defaultString precision:defaultPrecision];
    }
    [RCHHelper getMutableAttributedStringe:_balanceLabel.text Font:_balanceLabel.font color:_balanceLabel.textColor alignment:_balanceLabel.textAlignment];
    [_balanceLabel sizeToFit];
    _balanceLabel.frame = (CGRect){{0.0f, 0.0f}, {_balanceLabel.width, 24.0f}};
    
    _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_flow.created_at) {
        _timeLabel.text = [RCHHelper transTimeStringFormat:_flow.created_at];
    } else {
        _timeLabel.text = defaultString;
    }
    [RCHHelper getMutableAttributedStringe:_timeLabel.text Font:_timeLabel.font color:_timeLabel.textColor alignment:_timeLabel.textAlignment];
    [_timeLabel sizeToFit];
    _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {_timeLabel.width, 18.0f}};
    
    _statusLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if ([_flow._dtype isEqualToString:@"share_unlock"]) {
        _statusLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0f];
        _statusLabel.text = @"富矿私募释放";
    } else {
        _statusLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        _statusLabel.text = @"成功";
    }
    [RCHHelper getMutableAttributedStringe:_statusLabel.text Font:_statusLabel.font color:_statusLabel.textColor alignment:_statusLabel.textAlignment];
    [_statusLabel sizeToFit];
    _statusLabel.frame = (CGRect){{0.0f, 0.0f}, {_statusLabel.width, 22.0f}};
}


@end
