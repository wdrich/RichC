//
//  RCHStateRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHStateRequest.h"

@implementation RCHStateRequest

- (void)state:(void(^)(NSObject *response))completion coin:(NSString *)coin
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/state", kRichcoreMarketsUrl, coin];
    [self GET:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            RCHState *state = [RCHState mj_objectWithKeyValues:response.responseObject];
            completion(state);
        } else {
            completion(response);
        }
        
    }];
}

@end
