//
//  RCHForgotRequest.m
//  richcore
//
//  Created by WangDong on 2018/6/14.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHForgotRequest.h"

@implementation RCHForgotRequest

- (void)checkEmail:(void(^)(NSError *error, WDBaseResponse *response))completion email:(NSString *)email
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"email"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/valid/email", kRichcoreForgetUrl];
    [self POST:urlString parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)getMember:(void(^)(NSObject *response))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@/verificate", kRichcoreForgetUrl];
    [self GET:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        if (!response.error) {
            RCHMember *member = [RCHMember mj_objectWithKeyValues:response.responseObject];
            completion(member);
        } else {
            completion(response);
        }
        
    }];
}

- (void)verify:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters
{
    NSString *urlString = [NSString stringWithFormat:@"%@/verificate", kRichcoreForgetUrl];
    [self POST:urlString parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)emailVerify:(void(^)(NSError *error, WDBaseResponse *response))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@/email/code", kRichcoreForgetUrl];
    [self POST:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)mobileVerify:(void(^)(NSError *error, WDBaseResponse *response))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@/mobile/code", kRichcoreForgetUrl];
    [self POST:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}


- (void)change:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters
{
    NSString *urlString = [NSString stringWithFormat:@"%@/change/password", kRichcoreForgetUrl];
    [self POST:urlString parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
