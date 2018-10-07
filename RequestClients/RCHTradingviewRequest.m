//
//  RCHTradingviewRequest.m
//  richcore
//
//  Created by WangDong on 2018/7/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTradingviewRequest.h"

@implementation RCHTradingviewRequest

- (void)history:(void(^)(NSObject *response))completion info:(NSDictionary *)info
{
    NSString *urlString = [NSString stringWithFormat:@"%@/history", kRichcoreTradingviewUrl];
    [self GET:urlString parameters:info completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:response.responseObject];
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *dic in dics) {
                RCHKlineItem *item = [RCHKlineItem mj_objectWithKeyValues:dic];
                [items addObject:item];
            }
            completion((NSArray *)items);
        } else {
            completion(response);
        }
        
    }];
}

@end
