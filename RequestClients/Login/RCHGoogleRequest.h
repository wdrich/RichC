//
//  RCHGoogleRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHGoogleRequest : WDBaseRequest

- (void)getVerify:(void(^)(NSObject *response))completion;

- (void)postVerify:(void(^)(NSError *error, WDBaseResponse *response))completion verifyCode:(NSString *)verifyCode;
- (void)putVerify:(void(^)(NSError *error, WDBaseResponse *response))completion verifyCode:(NSString *)verifyCode;

- (void)revokeAuth:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters;

@end
