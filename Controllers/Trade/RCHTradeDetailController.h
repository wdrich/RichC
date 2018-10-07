//
//  RCHTradeDetailController.h
//  richcore
//
//  Created by WangDong on 2018/6/1.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHBaseViewController.h"
#import "RCHState.h"

@interface RCHTradeDetailController : RCHBaseViewController

@property (nonatomic, assign) BOOL canChangeMarket;

- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids;

@end

