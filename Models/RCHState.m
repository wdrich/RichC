//
//  RCHState.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHState.h"

@implementation RCHState

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.state_id = 0;
    self.coin_code = nil;
    self.base_coin_code = nil;
    self.price_change = nil;
    self.price_change_percent = nil;
    self.cny_rate = nil;
    self.last_price = nil;
    self.high_price = nil;
    self.low_price = nil;
    self.volume = nil;
    self.quote_volume = nil;
    self.usdt_price = nil;
    self.symbol = nil;
    self.created_at = nil;
    self.price_amplitude = nil;
    self.overal_volume = nil;
    self.overal_quote_volume = nil;
    return self;
}

- (void)dealloc {
    
    self.coin_code = nil;
    self.base_coin_code = nil;
    self.price_change = nil;
    self.price_change_percent = nil;
    self.last_price = nil;
    self.high_price = nil;
    self.low_price = nil;
    self.cny_rate = nil;
    self.volume = nil;
    self.quote_volume = nil;
    self.usdt_price = nil;
    self.created_at = nil;
    self.price_amplitude = nil;
    self.overal_volume = nil;
    self.overal_quote_volume = nil;
}

- (NSNumber *)cny_price {
    if (self.last_price && self.cny_rate) {
        return [[NSDecimalNumber decimalNumberWithDecimal:[self.last_price decimalValue]] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.cny_rate decimalValue]]];
    } else {
        return [NSNumber numberWithString:@"0"];
    }
}

- (NSComparisonResult)amplitude {
    return self.price_amplitude == nil ? NSOrderedSame : [[NSDecimalNumber decimalNumberWithDecimal:[self.price_amplitude decimalValue]] compare:[NSDecimalNumber zero]];
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"state_id" : @"id"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}


@end
