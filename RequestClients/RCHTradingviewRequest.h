//
//  RCHTradingviewRequest.h
//  richcore
//
//  Created by WangDong on 2018/7/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHKlineItem.h"

@interface RCHTradingviewRequest : WDBaseRequest

- (void)history:(void(^)(NSObject *response))completion info:(NSDictionary *)info;

@end
