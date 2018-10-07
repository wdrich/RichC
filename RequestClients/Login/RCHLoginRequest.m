
//
//  RCHLoginRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHLoginRequest.h"

@implementation RCHLoginRequest

- (void)login:(void(^)(NSError *error, WDBaseResponse *response))completion user:(NSDictionary *)user
{
    [self POST:kRichcoreLoginUrl parameters:user completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
