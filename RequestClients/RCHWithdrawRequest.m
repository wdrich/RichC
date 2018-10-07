//
//  RCHWithdrawRequest.m
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWithdrawRequest.h"

@implementation RCHWithdrawRequest

- (void)withdraws:(void(^)(NSObject *response))completion parameters:(NSDictionary *)parameters
{
    [self GET:kRichcoreWithdrawUrl parameters:parameters completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            RCHWithdrawList *result = [RCHWithdrawList mj_objectWithKeyValues:response.responseObject];
            completion(result);
        } else {
            completion(response);
        }
    }];
}


- (void)revokeWithdraw:(void(^)(NSError *error, WDBaseResponse *response))completion withdrawId:(NSInteger)withdrawId
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@", kRichcoreWithdrawUrl,[NSNumber numberWithInteger:withdrawId]];
    [self DELETE:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)getInfoWithCoinCode:(NSString *)coinCode completion:(void(^)(NSObject *response))completion
{
    [self GET:[NSString stringWithFormat:@"%@/%@/info", kRichcoreWithdrawUrl, coinCode] parameters:nil completion:^(WDBaseResponse *response) {
        if (!response.error) {
            RCHWithdrawInfo *info = [RCHWithdrawInfo mj_objectWithKeyValues:response.responseObject];
            completion(info);
        } else {
            completion(response);
        }
    }];
}

- (void)withdraw:(RCHWithdrawDraft *)draft
        coinCode:(NSString *)coinCode
       checkOnly:(BOOL)checkOnly
    verifyMethod:( NSString * _Nullable )verifyMethod
      verifyCode:( NSString * _Nullable )verifyCode
      completion:(void(^)(NSObject *response))completion
{
    if (!checkOnly && verifyMethod != nil && verifyCode != nil) {
        [self.requestManager.requestSerializer setValue:verifyMethod forHTTPHeaderField:@"Verify-Method"];
        [self.requestManager.requestSerializer setValue:verifyCode forHTTPHeaderField:@"Verify-Code"];
    }
    self.requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self POST:[NSString stringWithFormat:@"%@/%@?checkOnly=%@", kRichcoreWithdrawUrl, coinCode, (checkOnly ? @"true" : @"false")] parameters:[draft dispose] completion:^(WDBaseResponse *response) {
        if (!response.error) {
            completion(nil);
        } else {
            completion(response);
        }
    }];
}

@end
