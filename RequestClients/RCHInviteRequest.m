//
//  RCHInviteRequest.m
//  richcore
//
//  Created by WangDong on 2018/6/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHInviteRequest.h"
#import "RCHInvite.h"

@implementation RCHInviteRequest

- (void)invites:(void(^)(NSObject *response))completion info:(NSDictionary *)info
{
    [self GET:kRichcoreInviteUrl parameters:info completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            NSObject *result = [RCHInviteList mj_objectWithKeyValues:response.responseObject];
            completion(result);
        } else {
            completion(response);
        }
        
    }];
}

- (void)inviteInfo:(void(^)(NSObject *response))completion
{
    [self GET:kRichcoreInviteInfoUrl parameters:nil completion:^(WDBaseResponse *response) {
        DEBUG_REQUEST_INFO([NSNumber numberWithInteger:response.statusCode], response.headers);
        DEBUG_REQUEST_INFO(response.error, response.errorMsg);
        DEBUG_REQUEST_INFO(response.responseObject, response.urlString);
        
        if (!response.error) {
            NSObject *result = [RCHInviteInfo mj_objectWithKeyValues:response.responseObject];
            completion(result);
        } else {
            completion(response);
        }
        
    }];
}

@end
