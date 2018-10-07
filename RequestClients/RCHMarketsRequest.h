//
//  RCHMarketsRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHMarket.h"

@interface RCHMarketsRequest : WDBaseRequest

- (void)markets:(void(^)(NSObject *response))completion;

@end
