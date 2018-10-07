//
//  RCHForgotRequest.h
//  richcore
//
//  Created by WangDong on 2018/6/14.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHForgotRequest : WDBaseRequest

- (void)checkEmail:(void(^)(NSError *error, WDBaseResponse *response))completion email:(NSString *)email;
- (void)getMember:(void(^)(NSObject *response))completion;
- (void)verify:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters;
- (void)emailVerify:(void(^)(NSError *error, WDBaseResponse *response))completion;
- (void)mobileVerify:(void(^)(NSError *error, WDBaseResponse *response))completion;
- (void)change:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters;

@end
