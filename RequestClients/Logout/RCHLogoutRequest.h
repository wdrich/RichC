//
//  RCHLogoutRequest.h
//  richcore
//
//  Created by WangDong on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHLogoutRequest : WDBaseRequest

- (void)logout:(void(^)(NSError *error, WDBaseResponse *response))completion;

@end
