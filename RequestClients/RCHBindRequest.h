//
//  RCHBindRequest.h
//  richcore
//
//  Created by WangDong on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHBindRequest : WDBaseRequest

- (void)bind:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters;
- (void)unBind:(void(^)(NSError *error, WDBaseResponse *response))completion parameters:(NSDictionary *)parameters;

@end
