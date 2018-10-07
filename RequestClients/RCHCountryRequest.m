//
//  RCHCountryRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHCountryRequest.h"

@implementation RCHCountryRequest

- (void)countries:(void(^)(NSObject *response))completion
{
    [self GET:kCountryUrl parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:response.responseObject];
            NSMutableArray *countris = [NSMutableArray array];
            for (NSDictionary *dic in dics) {
                RCHCountry *county = [RCHCountry mj_objectWithKeyValues:dic];
                [countris addObject:county];
            }
            completion(countris);
        } else {
            completion(response);
        }
        
    }];
}

@end
