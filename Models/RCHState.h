//
//  RCHState.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHState : NSObject

@property (nonatomic, assign) NSInteger state_id;
@property (nonatomic, copy) NSString *coin_code;
@property (nonatomic, copy) NSString *base_coin_code;
@property (nonatomic, strong) NSNumber *price_change;
@property (nonatomic, strong) NSNumber *price_change_percent;
@property (nonatomic, strong) NSNumber *last_price;
@property (nonatomic, strong) NSNumber *high_price;
@property (nonatomic, strong) NSNumber *low_price;
@property (nonatomic, strong) NSNumber *cny_rate;
@property (nonatomic, strong) NSNumber *volume;
@property (nonatomic, strong) NSNumber *quote_volume;
@property (nonatomic, strong) NSNumber *usdt_price;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, strong) NSNumber *price_amplitude;
@property (nonatomic, strong) NSNumber *overal_volume;
@property (nonatomic, strong) NSNumber *overal_quote_volume;

- (NSNumber *)cny_price;
- (NSComparisonResult)amplitude;

@end
