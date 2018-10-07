//
//  RCHPayManager.h
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHPayReq.h"
#import "RCHPayResp.h"

@interface RCHPayManager : NSObject

+ (void)payWithReq:(RCHPayReq *)req completion:(void (^)(RCHPayResp *))completion;

@end
