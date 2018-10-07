//
//  RCHTradeController.h
//  richcore
//
//  Created by WangDong on 2018/7/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRefreshTableViewController.h"

@interface RCHTradeController : RCHRefreshTableViewController

- (id)initWithType:(RCHAgencyAim)aim;
- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids;

@end
