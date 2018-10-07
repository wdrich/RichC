//
//  RCHOrder.h
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHMarket.h"
#import "RCHTransaction.h"

@interface RCHOrder : NSObject

@property (nonatomic, assign) NSInteger order_id;
@property (nonatomic, copy) NSString *aim;
@property (nonatomic, copy) NSString *created_at; //创建时间
@property (nonatomic, copy) NSString *resolved_at; //成交时间
@property (nonatomic, copy) NSString *revoked_at; //撤销时间
@property (nonatomic, copy) NSString *_dtype;

@property (nonatomic, strong) RCHMarket *market;
@property (nonatomic, strong) NSArray *transactions;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *amount;

- (NSString *)status;
- (NSDecimalNumber *)filledAmount;
- (NSDecimalNumber *)filledVolume;
- (NSDecimalNumber *)filledPercent;
- (NSDecimalNumber *)averagePrice;
- (NSDecimalNumber *)fee;

@end
