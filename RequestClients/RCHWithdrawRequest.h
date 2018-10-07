//
//  RCHWithdrawRequest.h
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHWithdrawList.h"

@interface RCHWithdrawRequest : WDBaseRequest

- (void)withdraws:(void(^)(NSObject *response))completion parameters:(NSDictionary *)parameters;
- (void)revokeWithdraw:(void(^)(NSError *error, WDBaseResponse *response))completion withdrawId:(NSInteger)withdrawId;
- (void)getInfoWithCoinCode:(NSString *)coinCode completion:(void(^)(NSObject *response))completion;
- (void)withdraw:(RCHWithdrawDraft *)draft
        coinCode:(NSString *)coinCode
       checkOnly:(BOOL)checkOnly
    verifyMethod:( NSString * _Nullable )verifyMethod
      verifyCode:( NSString * _Nullable )verifyCode
      completion:(void(^)(NSObject *response))completion;
@end
