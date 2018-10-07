//
//  RCHBaseViewController.h
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHNavBaseViewController.h"

@interface RCHBaseViewController : RCHNavBaseViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat offsetY;
- (instancetype)initWithTitle:(NSString *)title;
- (void)customButtonInfo:(UIButton *)button title:(NSString *)title;
@end
