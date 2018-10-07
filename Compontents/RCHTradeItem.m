//
//  RCHTradeItem.m
//  MJLMerchantsChatServerPush
//
//  Created by WangDong on 2018/5/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTradeItem.h"

@interface RCHTradeItem ()
{
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
}

@end

@implementation RCHTradeItem

- (id)initWithFrame:(CGRect)frame title:(NSMutableAttributedString *)title value:(NSMutableAttributedString *)value
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _price = title;
        _amount = value;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.attributedText = title;
        [self addSubview:_titleLabel];
        
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
        _subTitleLabel.attributedText = value;
        [self addSubview:_subTitleLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
        tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originX = 0.0f;
    _titleLabel.frame = (CGRect){{originX, 0.0f}, {120.0f, self.height}};
    _subTitleLabel.frame = (CGRect){{self.width - originX - _titleLabel.width, _titleLabel.top}, {120.0f, _titleLabel.height}};
}

-(void)itemTapped:(UITapGestureRecognizer*)tapGesture
{
    if (self.didSelected)
    {
        self.didSelected(self.price.string);
    }
    
}

@end
