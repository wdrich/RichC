//
//  RCHKlineView.h
//  richcore
//
//  Created by WangDong on 2018/7/5.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,KlineModelType)
{
    KlineModelTypeDefault = 0,
    KlineModelTypeWeek = -1, //周线图
    KlineModelTypeDay  = -2//日线图
};

@interface RCHKlineView : UIView

@property (nonatomic, copy) void(^reloadBlock)(NSInteger resolution);
@property (nonatomic, copy) void (^onChanged)(NSString *text);
@property (nonatomic, copy) void (^fullScreen)(void);

@property (nonatomic, strong) NSMutableArray *datas;

@end
