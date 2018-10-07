//
//  RCHModifyPasswordRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/22.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHModifyPasswordRequest.h"

@implementation RCHModifyPasswordRequest

- (void)changePassword:(void(^)(NSError *error, WDBaseResponse *response))completion password:(NSDictionary *)password
{
    NSString *urlString = [NSString stringWithFormat:@"%@/password", kRichcoreMemberUrl];
    [self PUT:urlString parameters:password completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
