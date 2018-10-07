//
//  RCHRatesRequest.h
//  richcore
//
//  Created by WangDong on 2018/7/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHRatesRequest : WDBaseRequest

- (void)rates:(void(^)(NSObject *response))completion;

@end
