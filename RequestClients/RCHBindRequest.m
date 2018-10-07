//
//  RCHBindRequest.m
//  richcore
//
//  Created by WangDong on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHBindRequest.h"

@implementation RCHBindRequest


- (void)bind:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters
{
    [self POST:kRichcoreBindUrl parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)unBind:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters
{
    [self POST:kRichcoreUnBindUrl parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
