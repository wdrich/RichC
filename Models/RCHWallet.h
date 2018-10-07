//
//  RCHWallet.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHCoin.h"

@interface RCHWallet : NSObject

@property (nonatomic, copy) NSString *icon;//缩写
@property (nonatomic, copy) NSString *address;//地址
@property (nonatomic, strong) NSNumber *freeze;
@property (nonatomic, strong) NSNumber *ebtc;
@property (nonatomic, strong) NSNumber *ecny;
@property (nonatomic, strong) RCHCoin *coin;//地址
@property (nonatomic, strong) NSNumber *balance;//余额

- (NSDecimalNumber *)available;

@end
