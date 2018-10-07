//
//  RCHSoftwareUpdateRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHVersion.h"

@interface RCHSoftwareUpdateRequest : WDBaseRequest

- (void)checkUpdate:(void(^)(NSObject *response))completion info:(NSDictionary *)info;

@end
