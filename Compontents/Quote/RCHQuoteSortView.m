//
//  RCHQuoteSortView.m
//  richcore
//
//  Created by WangDong on 2018/8/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHQuoteSortView.h"
#import "UIImage_WD.h"

@interface RCHQuoteSortView()

@property (weak, nonatomic) UIButton *nameButton;
@property (weak, nonatomic) UIButton *volumeButton;
@property (weak, nonatomic) UIButton *priceButton;
@property (weak, nonatomic) UIButton *changeButton;
@property (weak, nonatomic) UILabel *divLabel;

@property (assign, nonatomic) BOOL descending;

@end


@implementation RCHQuoteSortView


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
//    self.backgroundColor = newSuperview.backgroundColor;
}

- (instancetype)init
{
    self = [super init];
    
    self.descending = NO;
    
    if (self) {
        [self.nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15.0f);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(18.0f);
        }];
        
        [self.divLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameButton.mas_right).offset(0.0f);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(18.0f);
        }];
        
        [self.volumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.divLabel.mas_right).offset(0.0f);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(18.0f);
        }];
        
        [self.priceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(140.0f);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(18.0f);
        }];
        
        [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15.0f);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(18.0f);
        }];
        
        [self layoutIfNeeded];
        
    }
    return self;
}

#pragma mark -
#pragma mark - customFuction

- (RCHSortTrendType)changeButtonStatus:(UIButton *)button
{
    UIImage *image = RCHIMAGEWITHNAMED(@"arrow_fall_yellow");
    switch (button.tag) {
        case 0:
            button.tag = 1;
            [button setImage:image forState:UIControlStateNormal];
            [button setTitleColor:kYellowColor forState:UIControlStateNormal];
            return RCHSortTrendTypeDecrease;
            break;
        case 1:
            button.tag = 0;
            [button setImage:[UIImage image:image rotation:UIImageOrientationDown] forState:UIControlStateNormal];
            [button setTitleColor:kYellowColor forState:UIControlStateNormal];
            return RCHSortTrendTypeIncrease;            break;
        default:
            button.tag = 1;
            [button setImage:image forState:UIControlStateNormal];
            [button setTitleColor:kYellowColor forState:UIControlStateNormal];
            return RCHSortTrendTypeDecrease;
            break;
    }

}

- (void)resetButtonStatus:(UIButton *)button
{
    button.tag = 0;
    [button setImage:nil forState:UIControlStateNormal];
    [button setTitleColor:kTextUnselectColor forState:UIControlStateNormal];
}

- (void)changeNameVolumeStatus
{
    if (self.volumeButton.tag == 0) {
        [self changeButtonStatus:self.volumeButton];
        [self resetButtonStatus:self.nameButton];
        [self resetButtonStatus:self.priceButton];
        [self resetButtonStatus:self.changeButton];
        self.volumeButton.tag = 1;
        !self.sort ?: self.sort(RCHSortTypeVolume, RCHSortTrendTypeDecrease);
    } else if (self.volumeButton.tag == 1) {
        [self changeButtonStatus:self.nameButton];
        [self resetButtonStatus:self.volumeButton];
        [self resetButtonStatus:self.priceButton];
        [self resetButtonStatus:self.changeButton];
        self.volumeButton.tag = 2;
        !self.sort ?: self.sort(RCHSortTypeName, RCHSortTrendTypeDecrease);
    } else {
        [self resetButtonStatus:self.nameButton];
        [self resetButtonStatus:self.volumeButton];
        [self resetButtonStatus:self.priceButton];
        [self resetButtonStatus:self.changeButton];
        self.volumeButton.tag = 0;
        !self.sort ?: self.sort(RCHSortTypeDefault, RCHSortTrendTypeDecrease);
    }
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)nameButtonClick:(id)sender
{
    [self changeNameVolumeStatus];
}

- (void)volumeButtonClick:(id)sender
{
    [self changeNameVolumeStatus];
}

- (void)priceButtonClick:(id)sender
{
    RCHSortTrendType trend = [self changeButtonStatus:self.priceButton];
    [self resetButtonStatus:self.nameButton];
    [self resetButtonStatus:self.volumeButton];
    [self resetButtonStatus:self.changeButton];
    !self.sort ?: self.sort(RCHSortTypePrice, trend);
}

- (void)changeButtonClick:(id)sender
{
    RCHSortTrendType trend = [self changeButtonStatus:self.changeButton];
    [self resetButtonStatus:self.nameButton];
    [self resetButtonStatus:self.volumeButton];
    [self resetButtonStatus:self.priceButton];
    !self.sort ?: self.sort(RCHSortTypeChange, trend);
}

#pragma mark -
#pragma mark - getter

- (UILabel *)divLabel
{
    if(!_divLabel)
    {
        UILabel *divLabel = [[UILabel alloc] init];
        divLabel.textAlignment = NSTextAlignmentCenter;
        divLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.f];
        divLabel.textColor = kTextUnselectColor;
        divLabel.text = @"/";
        [divLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:divLabel];
        
        _divLabel = divLabel;
    }
    return _divLabel;
}


- (UIButton *)nameButton
{
    if(!_nameButton)
    {
        UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nameButton addTarget:self action:@selector(nameButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [nameButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [nameButton setTitleColor:kTextUnselectColor forState:UIControlStateNormal];
        [nameButton setTitleColor:kYellowColor forState:UIControlStateSelected];
        [nameButton setTitle:NSLocalizedString(@"名称", nil) forState:UIControlStateNormal];
        nameButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        [self addSubview:nameButton];
        
        nameButton.adjustsImageWhenHighlighted = NO;
        
//        // button标题的偏移量
//        nameButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -113.0f, 0.0f, 0.0f);
//        // button图片的偏移量
//        nameButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 135.0f, 0.0f, 0.0f);
        
        _nameButton = nameButton;
    }
    return _nameButton;
}

- (UIButton *)volumeButton
{
    if(!_volumeButton)
    {
        UIButton *volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [volumeButton addTarget:self action:@selector(volumeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [volumeButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [volumeButton setTitleColor:kTextUnselectColor forState:UIControlStateNormal];
        [volumeButton setTitleColor:kYellowColor forState:UIControlStateSelected];
        [volumeButton setTitle:NSLocalizedString(@"24h量", nil) forState:UIControlStateNormal];
        volumeButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        [self addSubview:volumeButton];
        
        volumeButton.adjustsImageWhenHighlighted = NO;
//        // button标题的偏移量
//        volumeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -113.0f, 0.0f, 0.0f);
//        // button图片的偏移量
//        volumeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 135.0f, 0.0f, 0.0f);
        
        _volumeButton = volumeButton;
    }
    return _volumeButton;
}

- (UIButton *)priceButton
{
    if(!_priceButton)
    {
        UIButton *priceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [priceButton addTarget:self action:@selector(priceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [priceButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [priceButton setTitleColor:kTextUnselectColor forState:UIControlStateNormal];
        [priceButton setTitleColor:kYellowColor forState:UIControlStateSelected];
        [priceButton setTitle:NSLocalizedString(@"最新价", nil) forState:UIControlStateNormal];
        priceButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        [self addSubview:priceButton];
        
        priceButton.tag = 0;
        priceButton.adjustsImageWhenHighlighted = NO;
        
//        // button标题的偏移量
//        priceButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -113.0f, 0.0f, 0.0f);
//        // button图片的偏移量
//        priceButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 135.0f, 0.0f, 0.0f);
        
        _priceButton = priceButton;
    }
    return _priceButton;
}

- (UIButton *)changeButton
{
    if(!_changeButton)
    {
        UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [changeButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [changeButton setTitleColor:kTextUnselectColor forState:UIControlStateNormal];
        [changeButton setTitleColor:kYellowColor forState:UIControlStateSelected];
        [changeButton setTitle:NSLocalizedString(@"24h涨跌", nil) forState:UIControlStateNormal];
        changeButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        [self addSubview:changeButton];
        
        changeButton.tag = 0;
        
        changeButton.adjustsImageWhenHighlighted = NO;
        
//        [changeButton setBackgroundColor:[UIColor blueColor] forState:UIControlStateNormal];
//        // button标题的偏移量
//        changeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -113.0f, 0.0f, 0.0f);
//        // button图片的偏移量
//        changeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 135.0f, 0.0f, 0.0f);
        
        _changeButton = changeButton;
    }
    return _changeButton;
}

@end
