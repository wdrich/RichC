//
//  RCHOrderFilterView.h
//  richcore
//
//  Created by WangDong on 2018/7/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RCHFilterStatus) {
    RCHFilterStatusAll,
    RCHFilterStatusResolved,
    RCHFilterStatusRevoked
};

@interface RCHOrderFilterView : UIView

@property (nonatomic, copy) void(^filter)(NSDictionary *filter);
@property (nonatomic, copy) void(^changeCoin)(void);

- (void)setDefaultFilter:(NSDictionary *)filter;
- (void)setCurrency:(NSString *)currency;

@end
