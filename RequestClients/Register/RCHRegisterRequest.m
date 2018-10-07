//
//  RCHRegisterRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRegisterRequest.h"

@implementation RCHRegisterRequest

- (void)registers:(void(^)(NSError *error, WDBaseResponse *response))completion user:(NSDictionary *)user verifyCode:(NSString *)verifyCode
{
    [self.requestManager.requestSerializer setHTTPShouldHandleCookies:YES];
    [self.requestManager.requestSerializer setValue:verifyCode forHTTPHeaderField:@"Verify-Code"];
    [self POST:kRichcoreRegisterUrl parameters:user completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
