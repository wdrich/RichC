//
//  RCHNavigationBar.m
//  richcore
//
//  Created by Dong Wang on 2018/1/25.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "RCHNavigationBar.h"

#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define kDefaultNavBarHeight ([UIApplication sharedApplication].statusBarFrame.size.height + 44.0)

#define kSmallTouchSizeHeight 44.0

#define kLeftRightViewSizeMinWidth 60.0

#define kLeftMargin 9.0

#define kRightMargin 9.0

#define kNavBarCenterY(H) ((self.frame.size.height - kStatusBarHeight - H) * 0.5 + kStatusBarHeight)

#define kViewMargin 5.0

@implementation RCHNavigationBar

#pragma mark - system

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupRCHNavigationBarUIOnce];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupRCHNavigationBarUIOnce];
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.superview bringSubviewToFront:self];
    
    self.leftView.frame = CGRectMake(kLeftMargin, kStatusBarHeight, self.leftView.width, self.leftView.height);
    
    self.rightView.frame = CGRectMake(self.width - self.rightView.width - kRightMargin, kStatusBarHeight, self.rightView.width, self.rightView.height);
    
    self.titleView.frame = CGRectMake(0, kStatusBarHeight + (44.0 - self.titleView.height) * 0.5, MIN(self.width - MAX(self.leftView.width, self.rightView.width) * 2 - kViewMargin * 2, self.titleView.width), self.titleView.height);
    
    self.titleView.left = (self.width * 0.5 - self.titleView.width * 0.5);
    
    self.bottomBlackLineView.frame = CGRectMake(0, self.height, self.width, 0.5);
    
}



#pragma mark - Setter
- (void)setTitleView:(UIView *)titleView
{
    [_titleView removeFromSuperview];
    [self addSubview:titleView];
    
    _titleView = titleView;
    
    __block BOOL isHaveTapGes = NO;
    
    [titleView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[UITapGestureRecognizer class]]) {
            
            isHaveTapGes = YES;
            
            *stop = YES;
        }
    }];
    
    if (!isHaveTapGes) {
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleClick:)];
        
        [titleView addGestureRecognizer:tap];
    }
    
    
    [self layoutIfNeeded];
}




- (void)setTitle:(NSMutableAttributedString *)title
{
    /**头部标题*/
    UILabel *navTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width * 0.6, 44)];
    
    navTitleLabel.numberOfLines=1;//可能出现多行的标题 设置为0
    [navTitleLabel setAttributedText:title];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.userInteractionEnabled = YES;
//    navTitleLabel.lineBreakMode = NSLineBreakByClipping;
    [navTitleLabel sizeToFit];
    
    self.titleView = navTitleLabel;
}


- (void)setLeftView:(UIView *)leftView
{
    [_leftView removeFromSuperview];
    
    [self addSubview:leftView];
    
    _leftView = leftView;
    
    
    if ([leftView isKindOfClass:[UIButton class]]) {
        
        UIButton *btn = (UIButton *)leftView;
        
        [btn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self layoutIfNeeded];
    
}


- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    
    self.layer.contents = (id)backgroundImage.CGImage;
}



- (void)setRightView:(UIView *)rightView
{
    [_rightView removeFromSuperview];
    
    [self addSubview:rightView];
    
    _rightView = rightView;
    
    if ([rightView isKindOfClass:[UIButton class]]) {
        
        UIButton *btn = (UIButton *)rightView;
        
        [btn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self layoutIfNeeded];
}



- (void)setDataSource:(id<RCHNavigationBarDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self setupDataSourceUI];
}


#pragma mark - getter

- (UIView *)bottomBlackLineView
{
    if(!_bottomBlackLineView)
    {
        CGFloat height = 0.5;
        UIView *bottomBlackLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height , self.frame.size.width, height)];
        [self addSubview:bottomBlackLineView];
        _bottomBlackLineView = bottomBlackLineView;
        bottomBlackLineView.backgroundColor = [UIColor lightGrayColor];
    }
    return _bottomBlackLineView;
}

#pragma mark - event

- (void)leftBtnClick:(UIButton *)btn
{
    if ([self.rchDelegate respondsToSelector:@selector(leftButtonEvent:navigationBar:)]) {
        
        [self.rchDelegate leftButtonEvent:btn navigationBar:self];
        
    }
    
}


- (void)rightBtnClick:(UIButton *)btn
{
    if ([self.rchDelegate respondsToSelector:@selector(rightButtonEvent:navigationBar:)]) {
        
        [self.rchDelegate rightButtonEvent:btn navigationBar:self];
        
    }
    
}


-(void)titleClick:(UIGestureRecognizer*)Tap
{
    UILabel *view = (UILabel *)Tap.view;
    if ([self.rchDelegate respondsToSelector:@selector(titleClickEvent:navigationBar:)]) {
        
        [self.rchDelegate titleClickEvent:view navigationBar:self];
        
    }
}



#pragma mark - custom

- (void)setupDataSourceUI
{
    
    /** 导航条的高度 */
    
    if ([self.dataSource respondsToSelector:@selector(RCHNavigationHeight:)]) {
        
        self.size = CGSizeMake(kScreenWidth, [self.dataSource RCHNavigationHeight:self]);
        
    }else
    {
        self.size = CGSizeMake(kScreenWidth, kDefaultNavBarHeight);
    }
    
    /** 是否显示底部黑线 */
    if ([self.dataSource respondsToSelector:@selector(RCHNavigationIsHideBottomLine:)]) {
        
        if ([self.dataSource RCHNavigationIsHideBottomLine:self]) {
            self.bottomBlackLineView.hidden = YES;
        }
        
    }
    
    /** 背景图片 */
    if ([self.dataSource respondsToSelector:@selector(RCHNavigationBarBackgroundImage:)]) {
        
        self.backgroundImage = [self.dataSource RCHNavigationBarBackgroundImage:self];
    }
    
    /** 背景色 */
    if ([self.dataSource respondsToSelector:@selector(RCHNavigationBackgroundColor:)]) {
        self.backgroundColor = [self.dataSource RCHNavigationBackgroundColor:self];
    }
    
    
    /** 导航条中间的 View */
    if ([self.dataSource respondsToSelector:@selector(RCHNavigationBarTitleView:)]) {
        
        self.titleView = [self.dataSource RCHNavigationBarTitleView:self];
        
    }else if ([self.dataSource respondsToSelector:@selector(RCHNavigationBarTitle:)])
    {
        /**头部标题*/
        self.title = [self.dataSource RCHNavigationBarTitle:self];
    }
    
    
    /** 导航条的左边的 view */
    /** 导航条左边的按钮 */
    if ([self.dataSource respondsToSelector:@selector(RCHNavigationBarLeftView:)]) {
        
        self.leftView = [self.dataSource RCHNavigationBarLeftView:self];
        
    }else if ([self.dataSource respondsToSelector:@selector(RCHNavigationBarLeftButtonImage:navigationBar:)])
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kSmallTouchSizeHeight, kSmallTouchSizeHeight)];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        
        UIImage *image = [self.dataSource RCHNavigationBarLeftButtonImage:btn navigationBar:self];
        
        if (image) {
            [btn setImage:image forState:UIControlStateNormal];
        }
        
        self.leftView = btn;
    }
    
    /** 导航条右边的 view */
    /** 导航条右边的按钮 */
    if ([self.dataSource respondsToSelector:@selector(RCHNavigationBarRightView:)]) {
        
        self.rightView = [self.dataSource RCHNavigationBarRightView:self];
        
    }else if ([self.dataSource respondsToSelector:@selector(RCHNavigationBarRightButtonImage:navigationBar:)])
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kLeftRightViewSizeMinWidth, kSmallTouchSizeHeight)];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        
        UIImage *image = [self.dataSource RCHNavigationBarRightButtonImage:btn navigationBar:self];
        
        if (image) {
            [btn setImage:image forState:UIControlStateNormal];
        }
        
        self.rightView = btn;
    }
    
}


- (void)setupRCHNavigationBarUIOnce
{
    self.backgroundColor = [UIColor whiteColor];
}


@end
