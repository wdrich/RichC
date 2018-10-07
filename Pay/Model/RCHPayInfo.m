//
//  RCHPayInfo.m
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import "RCHPayInfo.h"

@implementation RCHPayVerifyInfo

- (RCHPayVerifyMethod)method
{
    if ([self.method_ isEqualToString:@"mobile"]) {
        return RCHPayVerifyMethodMobile;
    }
    if ([self.method_ isEqualToString:@"google"]) {
        return RCHPayVerifyMethodGoogle;
    }
    return RCHPayVerifyMethodEmail;
}

@end

@implementation RCHPayInfo

- (NSDecimalNumber *)available {
    if (!self.balance || !self.freeze) return nil;
    return [[NSDecimalNumber decimalNumberWithDecimal:[self.balance decimalValue]] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[self.freeze decimalValue]]];
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"verifyInfo": @"verify_info"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

@end
