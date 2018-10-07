//
//  RCHAuthRequest.h
//  richcore
//
//  Created by Apple on 2018/5/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHAuthReq.h"

@interface RCHAuthRequest : WDBaseRequest

- (void)authWithReq:(RCHAuthReq *)req completion:(void(^)(NSObject *response))completion;

@end
