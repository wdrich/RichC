//
//  RCHInviteRecordCell.m
//  richcore
//
//  Created by WangDong on 2018/6/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHInviteRecordCell.h"

@interface RCHInviteRecordCell ()
{
    UILabel *_typeLabel;
    UILabel *_countLabel;
    UILabel *_timeLabel;
}

@end

@implementation RCHInviteRecordCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.textColor = kFontGrayColor;
        _typeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13.0f];
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.layer.masksToBounds = YES;
        [self addSubview:_typeLabel];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textColor = kFontGrayColor;
        _countLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.layer.masksToBounds = YES;
        [self addSubview:_countLabel];

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
    CGFloat originY = (self.contentView.height - _typeLabel.height - _timeLabel.height) / 2.0f;
    
    _typeLabel.frame = (CGRect){{originX, originY}, _typeLabel.frame.size};
    _timeLabel.frame = (CGRect){{_typeLabel.left, _typeLabel.bottom + 5.0f}, _timeLabel.frame.size};
    _countLabel.frame = (CGRect){{(self.contentView.width - _countLabel.width - originX), (self.contentView.height - _countLabel.height) / 2.0f}, _countLabel.frame.size};
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

- (void)setInvite:(RCHInvite *)invite
{
    _invite = invite;

    NSString *defaultString = @"--";
    {
        _typeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _typeLabel.text = _invite.type ?: defaultString;
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_typeLabel.text Font:_typeLabel.font color:_typeLabel.textColor alignment:NSTextAlignmentLeft];
        _typeLabel.attributedText = attributedString;
        [_typeLabel sizeToFit];
        _typeLabel.frame = (CGRect){{0.0f, 0.0f}, {_typeLabel.width, 14.0f}};
    }
    
    {
        _countLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _countLabel.text = [NSString stringWithFormat:@"%@ %@", _invite.amount ?: defaultString, _invite.wallet.coin.code ?: defaultString];
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_countLabel.text Font:_countLabel.font color:_countLabel.textColor alignment:NSTextAlignmentLeft];
        _countLabel.attributedText = attributedString;
        [_countLabel sizeToFit];
        _countLabel.frame = (CGRect){{0.0f, 0.0f}, {_countLabel.width, 14.0f}};
    }
    
    {
        _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        _timeLabel.text = _invite.created_at ? [RCHHelper getStempString:_invite.created_at] : defaultString;
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:_timeLabel.text Font:_timeLabel.font color:_timeLabel.textColor alignment:NSTextAlignmentLeft];
        _timeLabel.attributedText = attributedString;
        [_timeLabel sizeToFit];
        _timeLabel.frame = (CGRect){{0.0f, 0.0f}, {_timeLabel.width, 16.0f}};
    }
}


@end
