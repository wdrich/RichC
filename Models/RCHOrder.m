//
//  RCHOrder.m
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHOrder.h"

@implementation RCHOrder

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.order_id = 0;
    self.aim = nil;
    self.created_at = nil;
    self.resolved_at = nil;
    self.revoked_at = nil;
    self._dtype = nil;
    self.market = nil;
    self.price = nil;
    self.amount = nil;
    self.transactions = [NSArray array];
    
    return self;
}

- (void)dealloc {
    
    self.aim = nil;
    self.created_at = nil;
    self.resolved_at = nil;
    self.revoked_at = nil;
    self._dtype = nil;
    self.market = nil;
    self.price = nil;
    self.amount = nil;
    self.transactions = nil;
}

- (NSString *)status
{
    if ([self._dtype isEqualToString:@"market"]) return @"已成交";
    NSDecimalNumber *filledAmount = [self filledAmount];
    if (self.revoked_at) {
        if ([filledAmount compare:[NSDecimalNumber zero]] == NSOrderedDescending) return @"部分成交";
        return @"已撤单";
    }
    if (self.resolved_at) {
        return @"已成交";
    }
    return @"";
}

- (NSDecimalNumber *)filledAmount {
    if (![self.transactions isKindOfClass:[NSArray class]]) return [NSDecimalNumber zero];
    NSDecimalNumber *amount = [NSDecimalNumber zero];
    for ( RCHTransaction *transaction in self.transactions ) {
        amount = [amount decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[transaction.amount decimalValue]]];
    }
    return amount;
}

- (NSDecimalNumber *)filledVolume {
    if (![self.transactions isKindOfClass:[NSArray class]]) return [NSDecimalNumber zero];
    NSDecimalNumber *volume = [NSDecimalNumber zero];
    for ( RCHTransaction *transaction in self.transactions ) {
        volume = [volume decimalNumberByAdding:transaction.volume];
    }
    return volume;
}

- (NSDecimalNumber *)filledPercent {
    if ([self._dtype isEqualToString:@"market"] && [self.aim isEqualToString:@"buy"]) return nil;
    NSDecimalNumber *filledAmount = [self filledAmount];
    if ([filledAmount compare:[NSDecimalNumber zero]] != NSOrderedDescending) return nil;
    return [filledAmount decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.amount decimalValue]]];
}

- (NSDecimalNumber *)averagePrice {
    NSDecimalNumber *filledVolume = [self filledVolume];
    NSDecimalNumber *filledAmount = [self filledAmount];
    if ([filledAmount compare:[NSDecimalNumber zero]] != NSOrderedDescending) return [NSDecimalNumber zero];
    return [filledVolume decimalNumberByDividingBy:filledAmount];
}

- (NSDecimalNumber *)fee {
    if (![self.transactions isKindOfClass:[NSArray class]]) return [NSDecimalNumber zero];
    NSDecimalNumber *fee = [NSDecimalNumber zero];
    for ( RCHTransaction *transaction in self.transactions ) {
        fee = [fee decimalNumberByAdding:([self.aim isEqualToString:@"sell"] ? [[NSDecimalNumber decimalNumberWithDecimal:[transaction.price decimalValue]] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[transaction.fee decimalValue]]] : [NSDecimalNumber decimalNumberWithDecimal:[transaction.fee decimalValue]])];
    }
    return fee;
}


- (BOOL)isEqualToOrder:(RCHOrder *)order {
    if (!order) {
        return NO;
    }
    
    BOOL isEquelOrderId = (!self.order_id && !order.order_id) || (self.order_id == order.order_id);
//    BOOL isEquelFilledAmount = [self.filledAmount compare:order.filledAmount] == NSOrderedSame;
    BOOL isEquelFilledAmount = YES;
    return isEquelOrderId && isEquelFilledAmount;
}


#pragma mark -
#pragma mark - 重载isEqual方法

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[RCHOrder class]]) {
        return NO;
    }
    
    return [self isEqualToOrder:(RCHOrder *)object];

    
}

#pragma mark -
#pragma mark - mj_object

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"transactions":[RCHTransaction class]
             };
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"order_id" : @"id"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

@end
