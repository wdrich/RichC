//
//  RCHRegisterRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHRegisterRequest : WDBaseRequest

- (void)registers:(void(^)(NSError *error, WDBaseResponse *response))completion user:(NSDictionary *)user verifyCode:(NSString *)verifyCode;

@end
