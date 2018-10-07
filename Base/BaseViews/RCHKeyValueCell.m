//
//  RCHKeyValueCell.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHKeyValueCell.h"
#import "UIImageView+WebCache.h"

@interface RCHKeyValueCell (){

    UILabel         *_titleLabel;
    UILabel         *_valueLabel;
    UIImageView     *_imageView;
}

@end

@implementation RCHKeyValueCell

static NSString *const ID = @"RCHKeyValueCell";
+ (instancetype)cellWithTableView:(UITableView *)tableView andCellStyle:(UITableViewCellStyle)style
{
    RCHKeyValueCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[self alloc] initWithStyle:style reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.cornerRadius = 3.0f;
        _imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = kFontBlackColor;
        [self.contentView addSubview:_titleLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        _valueLabel.numberOfLines = 0;
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = NSTextAlignmentLeft;
        _valueLabel.textColor = kFontLightGrayColor;
        [self.contentView addSubview:_valueLabel];
        
        _headImageSize = (CGSize){24.0f, 24.0f};
        _originX = 10.0f;
        _spaceX = 10.0f;
        _lineOriginX = _originX;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float valueX;
    float imageWith = _headImageSize.width;
    float imageHeight = _headImageSize.height;
    if (_imageView.image) {
        _imageView.frame = CGRectMake(_originX, (self.height - imageHeight)/2, imageWith, imageHeight);
        _titleLabel.frame = CGRectMake(_imageView.right + _spaceX, (self.height - _titleLabel.height)/2, 180, _titleLabel.height);
    } else {
        _imageView.frame = CGRectZero;
        _titleLabel.frame = CGRectMake(_originX, (self.height - _titleLabel.height)/2, 180, _titleLabel.height);
    }

    valueX =   self.accessoryView.left - _valueLabel.frame.size.width - 8.0f;
    _valueLabel.frame = CGRectMake(valueX, (self.height - _valueLabel.height)/2, _valueLabel.width, _valueLabel.height);
    if (!_valueLabel.text) {
        _titleLabel.frame = (CGRect){_titleLabel.frame.origin, {236, _titleLabel.height}};
    }
}

#pragma -
#pragma CUSTOMFOCTION

- (void)setTitle:(NSString *)title andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl  andAccessoryView:(UIView *)accessoryView
{
    
    _titleLabel.frame= CGRectMake(0, 0, 220, 18);
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    
    _valueLabel.frame= CGRectMake(0, 0, 180, 18);
    _valueLabel.text = value;
    [_valueLabel sizeToFit];
    
    UIImage *placeholderImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];
    if (!placeholderImage) {
        placeholderImage = RCHIMAGEWITHNAMED(@"headpic_default");
    }
    
    if (_imageView) {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeholderImage];
    }
    
    self.accessoryView = accessoryView;
}

- (void)setTitle:(NSString *)title andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage andAccessoryView:(UIView *)accessoryView
{
    
    _titleLabel.frame= CGRectMake(0, 0, 220, 18);
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    
    _valueLabel.frame= CGRectMake(0, 0, 180, 18);
    _valueLabel.text = value;
    [_valueLabel sizeToFit];
    
    if (_imageView) {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeholderImage];
    }
    
    self.accessoryView = accessoryView;
}


- (void)setTitle:(NSString *)title subTitle:(NSString *)subtitle andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage andAccessoryView:(UIView *)accessoryView
{
    
    _titleLabel.frame= CGRectMake(0, 0, 220, 18);
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    
    _valueLabel.frame= CGRectMake(0, 0, 180, 18);
    _valueLabel.text = value;
    [_valueLabel sizeToFit];
    
    if (_imageView) {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                      placeholderImage:placeholderImage];
    }
    
    self.accessoryView = accessoryView;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    _titleLabel.textColor = _titleColor;
}

@end
