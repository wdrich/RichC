//
//  RCHShareRequest.h
//  richcore
//
//  Created by Apple on 2018/7/4.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHShare.h"

@interface RCHShareRequest : WDBaseRequest

- (void)shares:(void(^)(NSObject *response))completion;
- (void)shareWithCoinCode:(NSString *)coinCode completion:(void(^)(NSObject *response))completion;

@end
