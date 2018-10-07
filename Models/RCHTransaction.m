//
//  RCHTransaction.m
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTransaction.h"

@implementation RCHTransaction

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.transaction_id = 0;
    self.price = nil;
    self.amount = nil;
    self.fee = nil;
    self.created_at = nil;
    
    return self;
}

- (void)dealloc {
    
    self.price = nil;
    self.amount = nil;
    self.fee = nil;
    self.created_at = nil;
}

- (NSDecimalNumber *)volume {
    return [[NSDecimalNumber decimalNumberWithDecimal:[self.price decimalValue]] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.amount decimalValue]]];
}


+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"transaction_id" : @"id"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

@end
