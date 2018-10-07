//
//  RCHWalletReques.m
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWalletReques.h"

@implementation RCHWalletReques

- (void)wallet:(void(^)(NSObject *response))completion coin:(NSString *)coin
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kRichcoreWalletsUrl, coin];
    [self GET:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            RCHWallet *wallet = [RCHWallet mj_objectWithKeyValues:response.responseObject];
            completion(wallet);
        } else {
            completion(response);
        }
        
    }];
}

@end
