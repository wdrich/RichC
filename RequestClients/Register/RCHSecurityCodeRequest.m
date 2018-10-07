//
//  RCHSecurityCodeRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHSecurityCodeRequest.h"

@implementation RCHSecurityCodeRequest

- (void)sendVerifyCode:(void(^)(NSError *error, WDBaseResponse *response))completion email:(NSString *)email
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"email"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/email", kRichcoreSecurityCodeUrl];
    
    [self POST:urlString parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)sendVerifyCode:(void(^)(NSError *error, WDBaseResponse *response))completion mobile:(NSString *)mobile prefix:(NSInteger)prefix
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:mobile forKey:@"mobile"];
    [parameters setObject:[NSString stringWithFormat:@"%ld", (long)prefix] forKey:@"prefix"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/mobile", kRichcoreSecurityCodeUrl];
    
    [self POST:urlString parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
