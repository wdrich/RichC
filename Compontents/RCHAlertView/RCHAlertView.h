//
//  RCHAlertView.h
//  MeiBe
//
//  Created by WangDong on 2018/3/12.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHAlertTableview.h"

typedef NS_ENUM(NSInteger, RCHAlertViewType) {
    RCHAlertViewDefault     = 0, //默认样式
    RCHAlertViewInfo        = 1,
    RCHAlertViewNotice      = 2,
    RCHAlertViewList        = 3
};

@interface RCHAlertView : UIView

+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description imageName:(NSString *)imageName;
+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description imageName:(NSString *)imageName type:(RCHAlertViewType)type;
+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description imageName:(NSString *)imageName buttonTitle:(NSString *)buttonTitle type:(RCHAlertViewType)type;
+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description items:(NSMutableArray *)items type:(RCHAlertViewType)type;
+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description items:(NSMutableArray *)items detailHeight:(CGFloat)height type:(RCHAlertViewType)type;

@end
