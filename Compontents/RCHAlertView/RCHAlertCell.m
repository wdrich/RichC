//
//  RCHAlertCell.m
//  MeiBe
//
//  Created by WangDong on 2018/3/30.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAlertCell.h"

@interface RCHAlertCell ()
{
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
    UILabel *_descriptionLabel;
    UIImageView *_iconImageView;
    UIView *_topLine;
    UIView *_bottomLine;
}

@end

@implementation RCHAlertCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_iconImageView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = kLoginButtonColor;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.layer.masksToBounds = YES;
        [self addSubview:_titleLabel];
        
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.textColor = kLoginButtonColor;
        _subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.layer.masksToBounds = YES;
        [self addSubview:_subTitleLabel];
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.textColor = kFontLightGrayColor;
        _descriptionLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.textAlignment = NSTextAlignmentLeft;
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_descriptionLabel];
        
        _topLine = [[UIView alloc] initWithFrame:CGRectZero];
        _topLine.backgroundColor = kLightGreenColor;
        [self addSubview:_topLine];
        
        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColor = kLightGreenColor;
        [self addSubview:_bottomLine];
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originX = 48.0f;
    CGFloat originY = (self.height - _iconImageView.height) / 2.0f;
    CGFloat lineHeight = 10.0f;
    
    _iconImageView.frame = (CGRect){{originX, originY}, _iconImageView.frame.size};
    _titleLabel.frame = (CGRect){{_iconImageView.right + 20.0f, _iconImageView.top}, _titleLabel.frame.size};
    _subTitleLabel.frame = (CGRect){{_titleLabel.right + 5.0f, _iconImageView.top}, _subTitleLabel.frame.size};
    _descriptionLabel.frame = (CGRect){{_titleLabel.left, _titleLabel.bottom + 1.0f}, _descriptionLabel.frame.size};
    
    if (_alert.showTopLine) {
        _topLine.frame = (CGRect){{0.0f, 0.0f}, {2.0f, lineHeight}};
        _topLine.center = CGPointMake(_iconImageView.center.x, _topLine.center.y);
    }
    
    if (_alert.showBottomLine) {
        _bottomLine.frame = (CGRect){{0.0f, self.height - lineHeight}, {2.0f, lineHeight}};
        _bottomLine.center = CGPointMake(_iconImageView.center.x, _bottomLine.center.y);
    }
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

- (void)setAlert:(RCHAlert *)alert
{
    _alert = alert;
    
    UIImage *image;
    if (alert.leveled) {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"ico_medal.png"]];
    } else {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"ico_medal_gray.png"]];
    }
    _iconImageView.image = image;
    _iconImageView.frame = (CGRect){{0.0f, 0.0f}, image.size};
    
    if (alert.leveled) {
        _titleLabel.textColor = kLoginButtonColor;
    } else {
        _titleLabel.textColor = kFontLightGrayColor;
    }
    
    _titleLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_alert.title) {
        _titleLabel.text = _alert.title;
    } else {
        _titleLabel.text = @"";
    }
    _titleLabel.attributedText = [RCHHelper getMutableAttributedStringe:_titleLabel.text Font:_titleLabel.font color:_titleLabel.textColor alignment:_titleLabel.textAlignment];
    [_titleLabel sizeToFit];
    _titleLabel.frame = (CGRect){_titleLabel.frame.origin, _titleLabel.width, 18.0f};
    
    
    if (alert.leveled) {
        _subTitleLabel.textColor = kLoginButtonColor;
    } else {
        _subTitleLabel.textColor = kFontLightGrayColor;
    }
    _subTitleLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    if (_alert.subTitle) {
        _subTitleLabel.text = _alert.subTitle;
    } else {
        _subTitleLabel.text = @"";
    }
    _subTitleLabel.attributedText = [RCHHelper getMutableAttributedStringe:_subTitleLabel.text Font:_subTitleLabel.font color:_subTitleLabel.textColor alignment:_subTitleLabel.textAlignment];
    [_subTitleLabel sizeToFit];
    _subTitleLabel.frame = (CGRect){_subTitleLabel.frame.origin, _subTitleLabel.width, 18.0f};
    
    
    _descriptionLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    
    if (_alert.value) {
        _descriptionLabel.text = _alert.value;
    } else {
        _descriptionLabel.text = @"";
    }
    _descriptionLabel.attributedText = [RCHHelper getMutableAttributedStringe:_descriptionLabel.text Font:_descriptionLabel.font color:_descriptionLabel.textColor alignment:_descriptionLabel.textAlignment];
    [_descriptionLabel sizeToFit];
    _descriptionLabel.frame = (CGRect){_descriptionLabel.frame.origin, _descriptionLabel.width, 16.0f};
    
}

@end
