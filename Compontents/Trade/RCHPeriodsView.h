//
//  RCHPeriodsView.h
//  richcore
//
//  Created by WangDong on 2018/7/5.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCHPeriodsView : UIView

@property (strong, nonatomic) NSArray *titles;
@property (nonatomic, copy) void (^onChanged)(UIButton *sender);

@end
