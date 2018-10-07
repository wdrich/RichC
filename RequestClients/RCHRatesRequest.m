//
//  RCHRatesRequest.m
//  richcore
//
//  Created by WangDong on 2018/7/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRatesRequest.h"

@implementation RCHRatesRequest

- (void)rates:(void(^)(NSObject *response))completion
{
    [self GET:kRichcoreRatesAuthUrl parameters:nil completion:^(WDBaseResponse *response) {
//        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
//        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
//        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            NSObject *result = [NSArray mj_objectArrayWithKeyValuesArray:response.responseObject];
            completion(result);
        } else {
            completion(response);
        }
        
    }];
}

@end
