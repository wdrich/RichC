//
//  RCHPayRequest.m
//  richcore
//
//  Created by Apple on 2018/5/19.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import "RCHPayRequest.h"
#import "RCHPayResp.h"

#define kRichcorePayVerifyUrl     [NSString stringWithFormat:@"%@/pay/verify", kRichcoreAPIPrefixV1]
#define kRichcorePayUrl           [NSString stringWithFormat:@"%@/pay", kRichcoreAPIPrefixV1]

@implementation RCHPayRequest

- (void)verifyWithReq:(RCHPayReq *)req completion:(void(^)(NSObject *response))completion {
    [self POST:kRichcorePayVerifyUrl parameters:[req dispose] completion:^(WDBaseResponse *response) {
        if (!response.error) {
            RCHPayInfo *payInfo = [RCHPayInfo mj_objectWithKeyValues:response.responseObject];
            completion(payInfo);
        } else {
            completion(response);
        }
    }];
}

- (void)sendVerifyCodeWithMethod:(RCHPayVerifyMethod)verifyMethod completion:(void(^)( NSObject * _Nullable response))completion {
    [self GET:(verifyMethod == RCHPayVerifyMethodMobile ? kRichcoreVerifyPhoneUrl : kRichcoreVerifyEmailUrl) parameters:nil completion:^(WDBaseResponse *response) {
        if (!response.error) {
            completion(nil);
        } else {
            completion(response);
        }
    }];
}

- (void)payWithReq:(RCHPayReq *)req verifyCode:(NSString *)verifyCode completion:(void(^)(NSObject *response))completion {
    [self.requestManager.requestSerializer setValue:verifyCode forHTTPHeaderField:@"Verify-Code"];
    [self POST:[NSString stringWithFormat:@"%@/%@", kRichcorePayUrl, req.target_] parameters:[req dispose] completion:^(WDBaseResponse *response) {
        if (!response.error) {
            RCHPayResp *resp = [RCHPayResp mj_objectWithKeyValues:response.responseObject];
            completion(resp);
        } else {
            completion(response);
        }
    }];
}

@end
