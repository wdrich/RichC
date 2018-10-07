//
//  RCHCheckEmailRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHCheckEmailRequest.h"

@implementation RCHCheckEmailRequest

- (void)checkEmail:(void(^)(NSError *error, WDBaseResponse *response))completion email:(NSString *)email
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kRichcoreRegisterUrl, email];
    [self GET:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
