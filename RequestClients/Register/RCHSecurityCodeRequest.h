//
//  RCHSecurityCodeRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHSecurityCodeRequest : WDBaseRequest

- (void)sendVerifyCode:(void(^)(NSError *error, WDBaseResponse *response))completion email:(NSString *)email;
- (void)sendVerifyCode:(void(^)(NSError *error, WDBaseResponse *response))completion mobile:(NSString *)mobile prefix:(NSInteger)prefix;

@end
