//
//  MJLModifyPasswordRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/22.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"

@interface RCHModifyPasswordRequest : WDBaseRequest

- (void)changePassword:(void(^)(NSError *error, WDBaseResponse *response))completion password:(NSDictionary *)password;

@end
