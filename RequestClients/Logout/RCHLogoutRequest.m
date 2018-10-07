//
//  RCHLogoutRequest.m
//  richcore
//
//  Created by WangDong on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHLogoutRequest.h"

@implementation RCHLogoutRequest

- (void)logout:(void(^)(NSError *error, WDBaseResponse *response))completion
{
    [self POST:kRichcoreLogoutUrl parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
