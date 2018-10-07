//
//  RCHNumberEditView.h
//  MeiBe
//
//  Created by WangDong on 2018/3/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHNumberTextField.h"

@interface RCHNumberEditView : UIView

/// 减少按钮
@property (nonatomic, strong) UIButton *reduceButton;
/// 减少图标（默认无）
@property (nonatomic, strong) UIImage *reduceImageNormal;
/// 减少高亮图标（默认无）
@property (nonatomic, strong) UIImage *reduceImageHighlight;
/// 减少按钮标题（默认-）
@property (nonatomic, strong) NSString *reduceTitleNormal;
/// 减少按钮高亮标题（默认-）
@property (nonatomic, strong) NSString *reduceTitleHighlight;
/// 减少按钮字体大小（默认12）
@property (nonatomic, strong) UIFont *reduceFont;
/// 减少按钮字体颜色（默认黑色）
@property (nonatomic, strong) UIColor *reduceTitleColorNormal;
/// 减少按钮字体高亮颜色（默认黑色）
@property (nonatomic, strong) UIColor *reduceTitleColorHighlight;

/// 增加按钮
@property (nonatomic, strong) UIButton *addButton;
/// 增加图标（默认无）
@property (nonatomic, strong) UIImage *addImageNormal;
/// 增加高亮图标（默认无）
@property (nonatomic, strong) UIImage *addImageHighlight;
/// 增加按钮标题（默认+）
@property (nonatomic, strong) NSString *addTitleNormal;
/// 增加按钮高亮标题（默认+）
@property (nonatomic, strong) NSString *addTitleHighlight;
/// 增加按钮字体大小（默认12）
@property (nonatomic, strong) UIFont *addFont;
/// 增加按钮字体颜色（默认黑色）
@property (nonatomic, strong) UIColor *addTitleColorNormal;
/// 增加按钮字体高亮颜色（默认黑色）
@property (nonatomic, strong) UIColor *addTitleColorHighlight;


/// 字体大小（默认12）
@property (nonatomic, strong) UIFont *textFont;
/// 字体颜色（默认黑色）
@property (nonatomic, strong) UIColor *textColor;

/// 数量值（默认0）
@property (nonatomic, assign) NSDecimalNumber *number;
/// 最大数量值（默认无限大）
@property (nonatomic, assign) NSInteger numberMax;

/// 数量回调
@property (nonatomic, copy) void (^numberEdit)(NSString *string);

/// 完成输入回调
@property (nonatomic, copy) void (^finishEdit)(NSString *string);

/// 开始输入回调
@property (nonatomic, copy) void (^beginEdit)(NSString *string);

/// 是否显示边框（默认不显示）
@property (nonatomic, assign) BOOL borderShow;
/// 边框颜色（默认黑色）
@property (nonatomic, strong) UIColor *borderColor;
/// 边框大小（默认0.5，0.5~2.0）
@property (nonatomic, assign) CGFloat borderWidth;
/// 边框圆角
@property (nonatomic, assign) CGFloat borderCornerRadius;

/// 按钮Width
@property (nonatomic, assign) CGFloat buttonWidth;
/// 按钮Height
@property (nonatomic, assign) CGFloat buttonHeight;

@property (nonatomic, strong) RCHNumberTextField *textField;

/// 步长
@property (nonatomic, copy) NSString *step;

/// 宽小于高的三倍时，自动适应
- (instancetype)initWithFrame:(CGRect)frame;


@end
