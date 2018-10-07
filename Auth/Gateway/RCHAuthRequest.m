//
//  RCHAuthRequest.m
//  richcore
//
//  Created by Apple on 2018/5/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAuthRequest.h"
#import "RCHAuthResp.h"

#define kRichcoreAuthUrl         [NSString stringWithFormat:@"%@/officials/auth", kRichcoreAPIPrefixV1]

@implementation RCHAuthRequest

- (void)authWithReq:(RCHAuthReq *)req completion:(void(^)(NSObject *response))completion
{
    [self.requestManager.requestSerializer setValue:req.key forHTTPHeaderField:@"X-OFFICIAL-KEY"];
    [self.requestManager.requestSerializer setValue:req.signature forHTTPHeaderField:@"X-OFFICIAL-SIGNATURE"];
    [self PUT:kRichcoreAuthUrl parameters:[req dispose] completion:^(WDBaseResponse *response) {
        if (!response.error) {
            RCHAuthResp *resp = [RCHAuthResp mj_objectWithKeyValues:response.responseObject];
            completion(resp);
        } else {
            completion(response);
        }
    }];
}

@end
