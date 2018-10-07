//
//  RCHSendMobileCodeRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHSendMobileCodeRequest.h"

@implementation RCHSendMobileCodeRequest

- (void)getVerify:(void(^)(NSError *error, WDBaseResponse *response))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@/phone/code", kRichcoreMemberUrl];
    [self GET:urlString parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

- (void)sendVerify:(void(^)(NSError *error, WDBaseResponse *response))completion verifyCode:(NSString *)verifyCode
{
    NSString *urlString = [NSString stringWithFormat:@"%@/phone", kRichcoreMemberUrl];
    [self.requestManager.requestSerializer setValue:verifyCode forHTTPHeaderField:@"Verify-Code"];
    NSInteger loginId = [[RCHHelper valueForKey:kCurrentGoogleLoginId] integerValue];
    if (loginId > 0) {
        [self.requestManager.requestSerializer setValue:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:loginId]] forHTTPHeaderField:@"Login-ID"];
    }
    [self POST:urlString parameters:nil completion:^(WDBaseResponse *response) {
        NSLog(@"header:%@", self.requestManager.requestSerializer.HTTPRequestHeaders);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        completion(response.error, response);
    }];
}

@end
