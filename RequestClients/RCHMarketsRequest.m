//
//  RCHMarketsRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMarketsRequest.h"

@implementation RCHMarketsRequest

- (void)markets:(void(^)(NSObject *response))completion
{
    [self GET:kRichcoreMarketsUrl parameters:nil completion:^(WDBaseResponse *response) {
        if (!response.error) {
            NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:response.responseObject];
            NSMutableArray *markets = [NSMutableArray array];
            for (NSDictionary *dic in dics) {
                RCHMarket *market = [RCHMarket mj_objectWithKeyValues:dic];
                [markets addObject:market];
            }
            completion(markets);
        } else {
            completion(response);
        }
        
    }];
}

@end
