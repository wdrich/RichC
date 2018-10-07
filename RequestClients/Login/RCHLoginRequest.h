//
//  RCHLoginRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHLoginRequest : WDBaseRequest

- (void)login:(void(^)(NSError *error, WDBaseResponse *response))completion user:(NSDictionary *)user;

@end
