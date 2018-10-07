//
//  RCHShare.m
//  richcore
//
//  Created by Apple on 2018/7/4.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHShare.h"

@implementation RCHShare

- (NSDecimalNumber *)remain {
    return [[NSDecimalNumber decimalNumberWithDecimal:[self.total decimalValue]] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[self.unlocked decimalValue]]];
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

@end
