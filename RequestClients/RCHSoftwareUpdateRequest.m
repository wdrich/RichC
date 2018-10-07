//
//  RCHSoftwareUpdateRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHSoftwareUpdateRequest.h"

@implementation RCHSoftwareUpdateRequest

- (void)checkUpdate:(void(^)(NSObject *response))completion info:(NSDictionary *)info
{
    [self POST:kSoftwareUpdateUrl parameters:info completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.error.code], response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        if (!response.error) {
            if ([[response.responseObject mj_keyValues] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dics = [[response.responseObject mj_keyValues] objectForKey:@"profile"];
                RCHVersion *version = [RCHVersion mj_objectWithKeyValues:dics];
                completion(version);
            } else {
                completion(response);
            }
            
        } else {
            completion(response);
        }
    }];
}


@end
