//
//  RCHBlankPageView.m
//  richcore
//
//  Created by WangDong on 2018/6/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHBlankPageView.h"

@interface RCHBlankPageView()
/** 加载按钮 */
@property (weak, nonatomic) UIButton *reloadBtn;
/** 图片 */
@property (weak, nonatomic) YYAnimatedImageView *imageView;
/** 提示 label */
@property (weak, nonatomic) UILabel *tipLabel;
/** 按钮点击 */
@property (nonatomic, copy) void(^reloadBlock)(UIButton *sender);
@end

@implementation RCHBlankPageView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = newSuperview.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.left.right.equalTo(self.imageView);
            make.top.mas_offset(frame.size.height * 0.2);
        }];

        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(10);
            make.centerX.offset(0);
        }];

        [self.reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.mas_equalTo(self.imageView.mas_bottom).offset(10);
            //            make.width.mas_equalTo(@94);
            make.height.mas_equalTo(44);
        }];
    }
    return self;
}

- (void)configWithType:(RCHBlankPageViewType)blankPageType hasData:(BOOL)hasData emptyMessage:(NSString *)emptyMessage reloadButtonBlock:(void(^)(UIButton *sender))block
{
    if (hasData) {
        [self removeFromSuperview];
        return;
    }
    
    self.reloadBtn.hidden = YES;
    self.tipLabel.hidden = YES;
    self.imageView.hidden = YES;
    self.reloadBlock = block;
    
    if (blankPageType == RCHBlankPageViewTypeNoDataOnlyMessage) {
        self.reloadBtn.hidden = NO;
        self.tipLabel.hidden = YES;
        self.imageView.hidden = YES;
        
        [self.reloadBtn setTitle:emptyMessage ?: @"暂无相关信息" forState:UIControlStateNormal];
        [self.reloadBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.centerY.offset(0);
            make.height.mas_equalTo(44);
        }];
        
    } else {
        [self.imageView setImage:[UIImage imageNamed:@""]];
        self.tipLabel.text = emptyMessage ?: @"暂无相关信息";
        self.reloadBtn.hidden = NO;
        self.tipLabel.hidden = NO;
        self.imageView.hidden = NO;
    }
}

- (void)reloadClick:(UIButton *)btn
{
    !self.reloadBlock ?: self.reloadBlock(btn);
}

- (UIButton *)reloadBtn
{
    if(!_reloadBtn)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        _reloadBtn = btn;
        
        [btn setTitleColor:kFontLightGrayColor forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [btn setTitle:@"点击重新加载" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = kFontLightGrayColor;
        [btn addTarget:self action:@selector(reloadClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadBtn;
}

- (YYAnimatedImageView *)imageView
{
    if(!_imageView)
    {
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
        imageView.autoPlayAnimatedImage = YES;
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (UILabel *)tipLabel
{
    if(!_tipLabel)
    {
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        _tipLabel = label;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = kFontLightGrayColor;
    }
    return _tipLabel;
}

@end



static void *BlankPageViewKey = &BlankPageViewKey;

@implementation UIView (RCHConfigBlank)

- (void)setBlankPageView:(RCHBlankPageView *)blankPageView{
    objc_setAssociatedObject(self, BlankPageViewKey,
                             blankPageView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RCHBlankPageView *)blankPageView{
    return objc_getAssociatedObject(self, BlankPageViewKey);
}

- (void)configBlankPage:(RCHBlankPageViewType)blankPageType hasData:(BOOL)hasData emptyMessage:(NSString *)emptyMessage reloadButtonBlock:(void(^)(UIButton *sender))block
{
    if (hasData) {
        if (self.blankPageView) {
            self.blankPageView.hidden = YES;
            [self.blankPageView removeFromSuperview];
        }
    }else{
        if (!self.blankPageView) {
            CGFloat height = self.k_height;
            if ([self isKindOfClass:[UITableView class]]) {
                height -= 44.0f;
            }
            self.blankPageView = [[RCHBlankPageView alloc] initWithFrame:CGRectMake(0, 0, self.k_width, height)];
        }
        self.blankPageView.hidden = NO;
        [self addSubview:self.blankPageView];
        [self.blankPageView configWithType:blankPageType hasData:NO emptyMessage:emptyMessage reloadButtonBlock:block];
    }
}

@end
