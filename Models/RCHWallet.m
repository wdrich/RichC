//
//  RCHWallet.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWallet.h"

@implementation RCHWallet

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.icon = nil;
    self.address = nil;
    self.coin = nil;
    self.freeze = nil;
    self.ebtc = nil;
    self.ecny = nil;
    self.balance = nil;
    
    return self;
}

- (void)dealloc {
    
    self.balance = nil;
    self.coin = nil;
    self.address = nil;
    self.freeze = nil;
    self.ebtc = nil;
    self.ecny = nil;
    self.balance = nil;
}

- (NSDecimalNumber *)available {
    if (!self.balance || !self.freeze) return [NSDecimalNumber zero];
    
    return [[NSDecimalNumber decimalNumberWithDecimal:[self.balance decimalValue]] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[self.freeze decimalValue]]];
}


+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

- (void)mj_keyValuesDidFinishConvertingToObject
{
    NSLog(@"finish");
//    self.ebtc = [RCHHelper mul:[NSNumber numberWithString:[RCHHelper getRate:self.coin.code :@"BTC"]] and:self.balance];
    NSString *usdtRate = [RCHHelper getRate:self.coin.code :@"USDT"];
    NSString *cnyRate = [RCHHelper getRate:@"USDT" :@"CNY"];
    NSNumber *rate = [RCHHelper mul:[NSNumber numberWithString:usdtRate] and:[NSNumber numberWithString:cnyRate]];
    self.ecny = [RCHHelper mul:rate and:self.balance];
    NSLog(@"coin:%@",self.coin.code);
    
}


@end
