//
//  RCHNavigationBar.h
//  richcore
//
//  Created by Dong Wang on 2018/1/25.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

@class RCHNavigationBar;
// 主要处理导航条
@protocol  RCHNavigationBarDataSource<NSObject>

@optional

/**头部标题*/
- (NSMutableAttributedString*)RCHNavigationBarTitle:(RCHNavigationBar *)navigationBar;

/** 背景图片 */
- (UIImage *)RCHNavigationBarBackgroundImage:(RCHNavigationBar *)navigationBar;
/** 背景色 */
- (UIColor *)RCHNavigationBackgroundColor:(RCHNavigationBar *)navigationBar;
/** 是否显示底部黑线 */
- (BOOL)RCHNavigationIsHideBottomLine:(RCHNavigationBar *)navigationBar;
/** 导航条的高度 */
- (CGFloat)RCHNavigationHeight:(RCHNavigationBar *)navigationBar;


/** 导航条的左边的 view */
- (UIView *)RCHNavigationBarLeftView:(RCHNavigationBar *)navigationBar;
/** 导航条右边的 view */
- (UIView *)RCHNavigationBarRightView:(RCHNavigationBar *)navigationBar;
/** 导航条中间的 View */
- (UIView *)RCHNavigationBarTitleView:(RCHNavigationBar *)navigationBar;
/** 导航条左边的按钮 */
- (UIImage *)RCHNavigationBarLeftButtonImage:(UIButton *)leftButton navigationBar:(RCHNavigationBar *)navigationBar;
/** 导航条右边的按钮 */
- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar;
@end


@protocol RCHNavigationBarDelegate <NSObject>

@optional
/** 左边的按钮的点击 */
-(void)leftButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar;
/** 右边的按钮的点击 */
-(void)rightButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar;
/** 中间如果是 label 就会有点击 */
-(void)titleClickEvent:(UILabel *)sender navigationBar:(RCHNavigationBar *)navigationBar;
@end


@interface RCHNavigationBar : UIView

/** 底部的黑线 */
@property (weak, nonatomic) UIView *bottomBlackLineView;

/** <#digest#> */
@property (weak, nonatomic) UIView *titleView;

/** <#digest#> */
@property (weak, nonatomic) UIView *leftView;

/** <#digest#> */
@property (weak, nonatomic) UIView *rightView;

/** <#digest#> */
@property (nonatomic, copy) NSMutableAttributedString *title;

/** <#digest#> */
@property (weak, nonatomic) id<RCHNavigationBarDataSource> dataSource;

/** <#digest#> */
@property (weak, nonatomic) id<RCHNavigationBarDelegate> rchDelegate;

/** <#digest#> */
@property (weak, nonatomic) UIImage *backgroundImage;

@end
