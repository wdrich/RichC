//
//  RCHAutoAgency.m
//  richcore
//
//  Created by WangDong on 2018/6/19.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAutoAgency.h"

@implementation RCHAutoAgency

- (id)initWithType:(RCHAgencyType)type market:(RCHMarket *)market aim:(RCHAgencyAim)aim stepPrice:(NSDecimalNumber *)stepPrice
{
    self = [super init];
    if (self) {
        self.type = type;
        self.market = market;
        self.aim = aim;
        self.price = type == RCHAgencyTypeMarket || !market || !market.state ? nil : [NSDecimalNumber decimalNumberWithDecimal:[market.state.last_price decimalValue]];
        self.stepPrice = type == RCHAgencyTypeMarket || !market ? nil : [NSDecimalNumber decimalNumberWithDecimal:[market.price_step decimalValue]];
        if (stepPrice) {
            self.stepPrice = stepPrice;
        }
        self.amount = type == RCHAgencyTypeMarket || !market || !market.state ? nil : [NSDecimalNumber decimalNumberWithDecimal:[market.min_amount decimalValue]];
        [self initPriceRange];
    }
    return self;
}

- (BOOL)valid {
    return !(!self.market || !self.amount || [self.amount compare:[NSDecimalNumber notANumber]] == NSOrderedSame || (self.type == RCHAgencyTypeLimit && !self.total));
}

- (NSDecimalNumber *)total {
    if (!self.price || !self.amount) return nil;
    if ([self.price compare:[NSDecimalNumber notANumber]] == NSOrderedSame || [self.amount compare:[NSDecimalNumber notANumber]] == NSOrderedSame) return nil;
    NSDecimalNumber *total = [self.price decimalNumberByMultiplyingBy:self.amount];
    if ([total compare:[NSDecimalNumber zero]] == NSOrderedSame) return nil;
    return total;
}

- (NSDecimalNumber *)priceCNY {
    if (!self.price || !self.market || !self.market.state) return nil;
    if ([self.price compare:[NSDecimalNumber notANumber]] == NSOrderedSame) return nil;
    return [self.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.market.state.cny_rate decimalValue]]];
}

- (NSDecimalNumber *)price_CNY:(NSDecimalNumber *)price
{
    if (!price || !self.market || !self.market.state) return nil;
    if ([price compare:[NSDecimalNumber notANumber]] == NSOrderedSame) return nil;
    return [price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.market.state.cny_rate decimalValue]]];
}

- (void)initPriceRange
{
    if (!self.market) return;
    _miniPrice = [self price_mini];
    _buyPrice = [self price_buy];
    _maxPrice = [self price_max];
    _sellPrice = [self price_sell];
}

- (void)resetPriceRange
{
    if (!self.market) return;
    _buyPrice = [self price_buy];
    _sellPrice = [self price_sell];
}

- (NSDecimalNumber *)price_mini {
    if (!self.price) return nil;
    if ([self.price compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        return  nil;
    }
    NSDecimalNumber *miniPrice = [NSDecimalNumber decimalNumberWithDecimal:[[RCHHelper mul:self.price and:[NSNumber numberWithString:@"0.9"]] decimalValue]];;
    return miniPrice;
}

- (NSDecimalNumber *)price_max {
    if (!self.price) return nil;
    if ([self.price compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        return  nil;
    }
    NSDecimalNumber *maxPrice = [NSDecimalNumber decimalNumberWithDecimal:[[RCHHelper mul:self.price and:[NSNumber numberWithString:@"1.1"]] decimalValue]];;
    return maxPrice;
}


- (NSDecimalNumber *)price_buy {
    if (!self.price || !self.stepPrice ) return nil;
    if ([self.price compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        return  nil;
    }
    if ([self.stepPrice compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        return  nil;
    }
    
    NSDecimalNumber *buyPrice = [NSDecimalNumber decimalNumberWithDecimal:[[RCHHelper sub:self.price and:self.stepPrice] decimalValue]];;
    return buyPrice;
}

- (NSDecimalNumber *)price_sell {
    if (!self.price || !self.stepPrice ) return nil;
    if ([self.price compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        return  nil;
    }
    if ([self.stepPrice compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        return  nil;
    }
    NSDecimalNumber *sellPrice = [NSDecimalNumber decimalNumberWithDecimal:[[RCHHelper sum:self.price and:self.stepPrice] decimalValue]];;
    return sellPrice;
}

- (NSString *)dtype {
    return self.type == RCHAgencyTypeMarket ? @"market" : @"limit";
}

- (NSString *)_aim {
    return self.aim == RCHAgencyAimBuy ? @"buy" : @"sell";
}

- (NSDictionary *)dispose {
    NSNumberFormatter *formatter = [RCHHelper getNumberFormatterFractionDigits:8];
    
    NSMutableDictionary *agency = [NSMutableDictionary dictionary];
    [agency setObject:self.market.symbol forKey:@"market"];
    [agency setObject:self._aim forKey:@"aim"];
    if (self.type == RCHAgencyTypeLimit) {
        [agency setObject:[formatter stringFromNumber:self.price] forKey:@"price"];
    }
    [agency setObject:[formatter stringFromNumber:self.amount] forKey:@"amount"];
    return [NSDictionary dictionaryWithObject:agency forKey:@"agency"];
}


@end
