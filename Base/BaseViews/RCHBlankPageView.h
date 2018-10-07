//
//  RCHBlankPageView.h
//  richcore
//
//  Created by WangDong on 2018/6/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RCHBlankPageViewTypeNoDataDefault,
    RCHBlankPageViewTypeNoDataError,
    RCHBlankPageViewTypeNoDataOnlyMessage
} RCHBlankPageViewType;

@interface RCHBlankPageView : UIView
- (void)configWithType:(RCHBlankPageViewType)blankPageType hasData:(BOOL)hasData emptyMessage:(NSString *)emptyMessage reloadButtonBlock:(void(^)(UIButton *sender))block;
@end


@interface UIView (RCHConfigBlank)
- (void)configBlankPage:(RCHBlankPageViewType)blankPageType hasData:(BOOL)hasData emptyMessage:(NSString *)emptyMessage reloadButtonBlock:(void(^)(UIButton *sender))block;
@end

