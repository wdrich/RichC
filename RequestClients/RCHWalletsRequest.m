//
//  RCHWalletsRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWalletsRequest.h"

@implementation RCHWalletsRequest

- (void)wallets:(void(^)(NSObject *response))completion
{
    [self GET:kRichcoreWalletsUrl parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:response.responseObject];
            NSMutableArray *wallets = [NSMutableArray array];
            for (NSDictionary *dic in dics) {
                RCHWallet *wallet = [RCHWallet mj_objectWithKeyValues:dic];
                wallet.icon = [NSString stringWithFormat:@"https://%@%@%@.png", kRichcoreAPIURLDomain, kWalletIconPath, wallet.coin.code];
                [wallets addObject:wallet];
            }
            completion(wallets);
        } else {
            completion(response);
        }
        
    }];
}

- (void)walletWithCoinCode:(NSString *)coinCode completion:(void(^)(NSObject *response))completion
{
    [self GET:[NSString stringWithFormat:@"%@/%@", kRichcoreWalletsUrl, coinCode] parameters:nil completion:^(WDBaseResponse *response) {
        if (!response.error) {
            RCHWallet *wallet = [RCHWallet mj_objectWithKeyValues:response.responseObject];
            completion(wallet);
        } else {
            completion(response);
        }
    }];
}

@end
