//
//  RCHAuthManager.h
//  richcore
//
//  Created by Apple on 2018/5/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHAuthReq.h"
#import "RCHAuthResp.h"

@interface RCHAuthManager : NSObject

+ (void)authWithReq:(RCHAuthReq *)req completion:(void (^)(RCHAuthResp *))completion;

@end
