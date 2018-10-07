//
//  RCHAuctionView.h
//  richcore
//
//  Created by WangDong on 2018/7/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHAuction.h"
#import "RCHAuctionTx.h"

@interface RCHAuctionView : UIView

@property (nonatomic, copy) void (^countFinish)(void);

- (void)updateInfo;
- (void)setAuctionInfo:(RCHAuction *)auction;
- (void)setAuctionTxInfo:(RCHAuctionTx *)auctionTx;

@end
