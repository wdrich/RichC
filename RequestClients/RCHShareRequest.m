//
//  RCHShareRequest.m
//  richcore
//
//  Created by Apple on 2018/7/4.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHShareRequest.h"

@implementation RCHShareRequest

- (void)shares:(void(^)(NSObject *response))completion
{
    [self GET:kRichcoreSharesUrl parameters:nil completion:^(WDBaseResponse *response) {
        if (!response.error) {
            NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:response.responseObject];
            NSMutableArray *shares = [NSMutableArray array];
            for (NSDictionary *dic in dics) {
                RCHShare *share = [RCHShare mj_objectWithKeyValues:dic];
                [shares addObject:share];
            }
            completion(shares);
        } else {
            completion(response);
        }
        
    }];
}
- (void)shareWithCoinCode:(NSString *)coinCode completion:(void(^)(NSObject *response))completion
{
    [self GET:[NSString stringWithFormat:@"%@/%@", kRichcoreSharesUrl, coinCode] parameters:nil completion:^(WDBaseResponse *response) {
        if (!response.error) {
            RCHShare *share = [RCHShare mj_objectWithKeyValues:response.responseObject];
            completion(share);
        } else {
            completion(response);
        }
    }];
}

@end
