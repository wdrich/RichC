//
//  MJLFaceItemCell.m
//  MJLMerchantsChat
//
//  Created by WangDong on 13-4-30.
//  Copyright (c) 2013年 WangDong. All rights reserved.
//

#import "MJLFaceItemCell.h"
#import "UIImageView+WebCache.h"

@interface MJLFaceItemCell (){
    UILabel         *_titleLabel;
    UILabel         *_subTitleLabel;
    UILabel         *_valueLabel;
    UILabel         *_accessoryLabel;
    UIImageView     *_imageView;
}

@end

@implementation MJLFaceItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.cornerRadius = 3.0f;
        _imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_imageView];
        [_imageView release];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = kFontBlackColor;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel release];
        
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.font = [UIFont systemFontOfSize:12.0f];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        _subTitleLabel.textColor = kFontBlackColor;
        [self.contentView addSubview:_subTitleLabel];
        [_subTitleLabel release];

        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.font = [UIFont systemFontOfSize:12.0f];
        _valueLabel.numberOfLines = 0;
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = NSTextAlignmentLeft;
        _valueLabel.textColor = kFontLightGrayColor;
        [self.contentView addSubview:_valueLabel];
        [_valueLabel release];
        
        _accessoryLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {100.0f, 0.0f}}];
        _accessoryLabel.font = [UIFont systemFontOfSize:13.0f];
        _accessoryLabel.numberOfLines = 0;
        _accessoryLabel.backgroundColor = [UIColor clearColor];
        _accessoryLabel.textAlignment = NSTextAlignmentLeft;
        _accessoryLabel.textColor = kFontLightGrayColor;
        [self.contentView addSubview:_accessoryLabel];
        [_accessoryLabel release];
        
        _headImageSize = (CGSize){35, 35};
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
    _imageView.frame = CGRectMake(_originX, (self.height - imageHeight)/2, imageWith, imageHeight);
    
    if (_subTitleLabel.frame.size.width > 10) {
        _titleLabel.frame = CGRectMake(_imageView.right + _spaceX, (self.height - _titleLabel.height - _subTitleLabel.height - 3)/2 , 180, _titleLabel.height);
        _subTitleLabel.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 3, 180, _subTitleLabel.height);
    } else {
        _titleLabel.frame = CGRectMake(_imageView.right + _spaceX, (self.height - _titleLabel.height)/2, 180, _titleLabel.height);
        _subTitleLabel.frame = CGRectZero;
    }

    
    valueX =  self.width - 20 -  _valueLabel.frame.size.width;
    _valueLabel.frame = CGRectMake(valueX, (self.height - _valueLabel.height)/2, _valueLabel.width, _valueLabel.height);
    if (!_valueLabel.text) {
        _titleLabel.frame = (CGRect){_titleLabel.frame.origin, {236, _titleLabel.height}};
    }
    _accessoryLabel.frame = (CGRect){{self.width - 40.0f - _accessoryLabel.width, (self.height - _accessoryLabel.height) / 2.0f}, _accessoryLabel.frame.size};
}

- (void) drawRect:(CGRect)rect{
    
    if (!_isHideLine) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat lineHeight = [RCHHelper retinaFloat:1.0f];
        
        CGContextBeginPath(context);
        
        CGContextSetLineWidth(context, lineHeight);
        CGColorSpaceRef myColorSpace1 = CGColorSpaceCreateDeviceRGB();
        CGFloat myCcomponents1[] = { 222.0/255.0, 222.0/255.0, 222.0/255.0, 1.0};
        CGColorRef textColorRef1 = (CGColorRef)[(id)CGColorCreate(myColorSpace1, myCcomponents1)autorelease];
        CGContextSetStrokeColorWithColor(context, textColorRef1);
        CGContextMoveToPoint(context, _lineOriginX, rect.size.height - 1.0f);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 1.0f);
        CGContextStrokePath(context);
        CGColorSpaceRelease(myColorSpace1);
        
        CGContextClosePath(context);
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
    
    _subTitleLabel.frame= CGRectMake(0, 0, 220, 18);
    _subTitleLabel.text = subtitle;
    [_subTitleLabel sizeToFit];
    
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

- (void)setAccessoryColor:(UIColor *)accessoryColor
{
    _accessoryColor = accessoryColor;
    _accessoryLabel.textColor = accessoryColor;
}

- (void)setAccessoryCount:(NSString *)accessoryCount
{
    _accessoryLabel.frame = (CGRect){{0.0f, 0.0f}, {100.0f, 0.0f}};
    _accessoryCount = accessoryCount;
    _accessoryLabel.text = accessoryCount;
    [_accessoryLabel sizeToFit];
    [self layoutSubviews];
}

@end
