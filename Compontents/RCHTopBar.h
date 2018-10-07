//
//  RCHTopBar.h
//  MeiBe
//
//  Created by WangDong on 2018/3/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    PiecewiseInterfaceTypeMobileLine = 1,
    PiecewiseInterfaceTypeBackgroundChange,
    PiecewiseInterfaceTypeCustom
}PiecewiseInterfaceType;

@class RCHTopBar;
@protocol RCHTopBarDelegate <NSObject>

/**
 *  按钮点击事件
 */
- (void)piecewiseView:(RCHTopBar *)piecewiseView button:(UIButton *)button index:(NSInteger)index;

@end

@interface  RCHTopBar: UIView

/**
 *  按钮标题 如果PiecewiseInterfaceTypeCustom titleArray为结构体 {@"title", @"image"}
 */
@property(nonatomic,strong)NSArray *titleArray;

/**
 *  按钮结构
 */
@property(nonatomic,strong)NSArray *objecArray;

/**
 *  选中状态背景颜色
 */
@property(nonatomic,strong)UIColor *backgroundSeletedColor;

/**
 *  默认状态背景颜色
 */
@property(nonatomic,strong)UIColor *backgroundNormalColor;

/**
 *  下划线的颜色
 */
@property(nonatomic,strong)UIColor *linColor;

/**
 *  文字大小
 */
@property(nonatomic,strong)UIFont *textFont;

/**
 *  文字默认状态颜色
 */
@property(nonatomic,strong)UIColor *textNormalColor;

/**
 *  文字选中状态颜色
 */
@property(nonatomic,strong)UIColor *textSeletedColor;

/**
 *  下划线高度
 */
@property(nonatomic,assign)CGFloat lineHeight;

/**
 *  下划线宽度
 */
@property(nonatomic,assign)CGFloat lineWidth;

/**
 *  单元间隔 如果不设置则按照等分间隔 只有PiecewiseInterfaceTypeCustom的时候才会生效
 */
@property(nonatomic,assign)CGFloat itemPadding;

/**
 *  是否适配文字长短
 */
@property(nonatomic,assign)BOOL isFitTextWidth;

/**
 *  显示类型
 */
@property (nonatomic, assign) PiecewiseInterfaceType type;


/**
 *  只有一个按钮否起作用
 */
@property (nonatomic, assign) BOOL lastButtonActive;

@property(assign, nonatomic) id<RCHTopBarDelegate> delegate;


/**
 *  加载标题显示的方法
 */
- (void)loadTitleArray:(NSArray *)titleArray;
- (void)loadTitleArray:(NSArray *)titleArray selectedIndex:(NSUInteger)selectedIndex;

/**
 *  加载自定义图片的方法，如果不需要选中显示图片传nil。自定义按钮显示的数量和顺序是根据传入的图片名称数组的顺序和数量来显示的
 */
- (void)loadNormalImage:(NSArray *)normalImages seletedImage:(NSArray *)seletedImage;

@end
