//
//  RCHMemberRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHMember.h"

@interface RCHMemberRequest : WDBaseRequest

- (void)member:(void(^)(NSObject *response))completion;

@end
