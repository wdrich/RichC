//
//  RCHTradeView.h
//  richcore
//
//  Created by WangDong on 2018/7/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHAgencyFormView.h"
#import "RCHAutoAgencyFormView.h"

@interface RCHTradeView : UIView

@property (nonatomic, copy) void (^onSubmit)(RCHAgency *agency);
@property (nonatomic, copy) void (^showHelp)(void);
@property (nonatomic, copy) void (^reloadBlock)(BOOL force);

- (instancetype)initWithFrame:(CGRect)frame type:(RCHAgencyAim)aim;
- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids;
- (void)refreshPrice:(NSString *)symbol;
- (void)setCurrentWallets:(NSArray *)wallets;
- (void)changeCurrentOrders:(NSArray *)orders;

@end
