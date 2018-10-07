//
//  RCHStateRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHState.h"

@interface RCHStateRequest : WDBaseRequest

- (void)state:(void(^)(NSObject *response))completion coin:(NSString *)coin;

@end
