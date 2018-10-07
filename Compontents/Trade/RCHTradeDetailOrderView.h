//
//  RCHTradeDetailOrderView.h
//  richcore
//
//  Created by WangDong on 2018/7/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCHTradeDetailOrderView : UIView

@property (nonatomic, strong) RCHMarket *market;
@property (nonatomic, copy) void (^precisionChanged)(NSString *text);

- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids;

@end
