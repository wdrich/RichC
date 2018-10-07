//
//  RCHPayRequest.h
//  richcore
//
//  Created by Apple on 2018/5/19.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHPayReq.h"
#import "RCHPayInfo.h"

@interface RCHPayRequest : WDBaseRequest

- (void)verifyWithReq:(RCHPayReq *)req completion:(void(^)(NSObject *response))completion;
- (void)sendVerifyCodeWithMethod:(RCHPayVerifyMethod)verifyMethod completion:(void(^)(NSObject *response))completion;
- (void)payWithReq:(RCHPayReq *)req verifyCode:(NSString *)verifyCode completion:(void(^)(NSObject *response))completion;

@end
