//
//  RCHFlowRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHFlow.h"
#import "RCHPaging.h"

@interface RCHFlowRequest : WDBaseRequest

- (void)flows:(void(^)(NSObject *response))completion range:(NSString *)range;
- (void)flows:(void(^)(NSObject *response))completion range:(NSString *)range page:(NSUInteger)page size:(NSUInteger)size;

@end
