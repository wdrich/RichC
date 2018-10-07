//
//  RCHMemberRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMemberRequest.h"

@implementation RCHMemberRequest

- (void)member:(void(^)(NSObject *response))completion
{
    [self GET:kRichcoreMemberUrl parameters:nil completion:^(WDBaseResponse *response) {
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

@end
