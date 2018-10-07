//
//  RCHVerifyRequest.h
//  richcore
//
//  Created by WangDong on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHVerifyRequest : WDBaseRequest

- (void)phoneVerify:(void(^)(NSError *error, WDBaseResponse *response))completion;
- (void)emailVerify:(void(^)(NSError *error, WDBaseResponse *response))completion;

@end
