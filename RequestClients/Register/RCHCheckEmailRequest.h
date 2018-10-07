//
//  RCHCheckEmailRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHCheckEmailRequest : WDBaseRequest

- (void)checkEmail:(void(^)(NSError *error, WDBaseResponse *response))completion email:(NSString *)email;

@end
