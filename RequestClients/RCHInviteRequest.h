//
//  RCHInviteRequest.h
//  richcore
//
//  Created by WangDong on 2018/6/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHInviteRequest : WDBaseRequest

- (void)invites:(void(^)(NSObject *response))completion info:(NSDictionary *)info;
- (void)inviteInfo:(void(^)(NSObject *response))completion;

@end
