//
//  RCHGoogleRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHGoogleRequest.h"

@implementation RCHGoogleRequest

- (void)getVerify:(void(^)(NSObject *response))completion
{
    [self GET:kRichcoreGoogleAuthUrl parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            completion(response.responseObject);
        } else {
            completion(response);
        }
    }];
}

- (void)postVerify:(void(^)(NSError *error, WDBaseResponse *response))completion verifyCode:(NSString *)verifyCode
{
    [self.requestManager.requestSerializer setValue:verifyCode forHTTPHeaderField:@"Verify-Code"];
    RCHWeak(self);
    NSInteger loginId = [[RCHHelper valueForKey:kCurrentGoogleLoginId] integerValue];
    [self.requestManager.requestSerializer setValue:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:loginId]] forHTTPHeaderField:@"Login-ID"];
    [self POST:kRichcoreGoogleAuthUrl parameters:nil completion:^(WDBaseResponse *response) {
        NSLog(@"header:%@", weakself.requestManager.requestSerializer.HTTPRequestHeaders);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)putVerify:(void(^)(NSError *error, WDBaseResponse *response))completion verifyCode:(NSString *)verifyCode
{
    [self.requestManager.requestSerializer setValue:verifyCode forHTTPHeaderField:@"Verify-Code"];
    [self PUT:kRichcoreGoogleAuthUrl parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}


- (void)revokeAuth:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters
{
    [self DELETE:kRichcoreGoogleAuthUrl parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
