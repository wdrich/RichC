//
//  RCHVerifyRequest.m
//  richcore
//
//  Created by WangDong on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHVerifyRequest.h"

@implementation RCHVerifyRequest

- (void)phoneVerify:(void(^)(NSError *error, WDBaseResponse *response))completion
{
    [self GET:kRichcoreVerifyPhoneUrl parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}


- (void)emailVerify:(void(^)(NSError *error, WDBaseResponse *response))completion
{
    [self GET:kRichcoreVerifyEmailUrl parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
