//
//  RCHTradeOrderRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHOrder.h"
#import "RCHOrderList.h"

@interface RCHOrderRequest : WDBaseRequest

- (void)createOrder:(void(^)(NSObject *response))completion info:(NSDictionary *)info type:(NSString *)type;

- (void)revokeOrder:(void(^)(NSError *error, WDBaseResponse *response))completion orderId:(NSInteger)orderId;

- (void)orders:(void(^)(NSObject *response))completion info:(NSDictionary *)info;

@end
