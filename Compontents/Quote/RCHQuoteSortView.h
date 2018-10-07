//
//  RCHQuoteSortView.h
//  richcore
//
//  Created by WangDong on 2018/8/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCHQuoteSortView : UIView

@property (nonatomic, copy) void(^sort)(RCHSortType sort, RCHSortTrendType trend);

@end
