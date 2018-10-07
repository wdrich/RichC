//
//  RCHSendMobileCodeRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHSendMobileCodeRequest : WDBaseRequest

- (void)getVerify:(void(^)(NSError *error, WDBaseResponse *response))completion;

- (void)sendVerify:(void(^)(NSError *error, WDBaseResponse *response))completion verifyCode:(NSString *)verifyCode;

@end
