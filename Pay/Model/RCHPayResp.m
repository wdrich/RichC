//
//  RCHPayResp.m
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import "RCHPayResp.h"

@interface RCHPayResp ()
{
    NSDecimalNumber *_amount;
}
@end

@implementation RCHPayResp

- (NSDictionary *)dispose {
    return @{
             @"refNo": self.refNo,
             @"serialNumber": self.serialNumber,
             @"amount": self.rawAmount,
             @"comment": self.comment,
             @"payState": self.payState,
             @"tradeState": self.tradeState,
             @"sign": self.sign
             };
}

- (void)setRawAmount:(NSString *)rawAmount {
    _rawAmount = [rawAmount copy];
    _amount = [NSDecimalNumber decimalNumberWithString:_rawAmount];
}

- (NSDecimalNumber *)amount {
    return _amount;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"rawAmount": @"amount"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

@end
