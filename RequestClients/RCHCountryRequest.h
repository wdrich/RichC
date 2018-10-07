//
//  RCHCountryRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDBaseRequest.h"
#import "RCHCountry.h"

@interface RCHCountryRequest : WDBaseRequest

- (void)countries:(void(^)(NSObject *response))completion;

@end
