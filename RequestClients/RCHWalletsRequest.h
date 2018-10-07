//
//  RCHWalletsRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHWallet.h"

@interface RCHWalletsRequest : WDBaseRequest

- (void)wallets:(void(^)(NSObject *response))completion;
- (void)walletWithCoinCode:(NSString *)coinCode completion:(void(^)(NSObject *response))completion;

@end
