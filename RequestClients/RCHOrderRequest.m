//
//  RCHTradeOrderRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHOrderRequest.h"

@implementation RCHOrderRequest

- (void)createOrder:(void(^)(NSObject *response))completion info:(NSDictionary *)info type:(NSString *)type
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kRichcoreAgenciesUrl, type];
    self.requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self POST:urlString parameters:info completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
//        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        if (!response.error) {
            if ([response.responseObject respondsToSelector:@selector(objectFromJSONData)]) {
                NSDictionary *resultDictionary = [response.responseObject objectFromJSONData];
                RCHOrder *order = [RCHOrder mj_objectWithKeyValues:resultDictionary];
                completion(order);
                return;
            }
            RCHOrder *order = [RCHOrder mj_objectWithKeyValues:response.responseObject];
            completion(order);
        } else {
            completion(response);
        }
        [self.requestManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }];
}

- (void)revokeOrder:(void(^)(NSError *error, WDBaseResponse *response))completion orderId:(NSInteger)orderId
{ 
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@", kRichcoreAgenciesUrl,[NSNumber numberWithInteger:orderId]];
//    self.requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self DELETE:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)orders:(void(^)(NSObject *response))completion info:(NSDictionary *)info
{
    [self GET:kRichcoreAgenciesUrl parameters:info completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            NSObject *result = [RCHOrderList mj_objectWithKeyValues:response.responseObject];        
            completion(result);
        } else {
            completion(response);
        }
        
    }];
}

@end
