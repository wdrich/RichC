//
//  RCHPayReq.m
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import "RCHPayReq.h"

@implementation RCHPayReq

+ (RCHPayReq *)reqWithTarget:(NSString *)target
                         key:(NSString *)key
                       refNo:(NSString *)refNo
                      amount:(NSString *)amount
                     comment:(NSString *)comment
                   returnUrl:(NSString *)returnUrl
                   notifyUrl:(NSString *)notifyUrl
                   signature:(NSString *)signature
{
    RCHPayReq *req = [[RCHPayReq alloc] init];
    req.target_ = target;
    req.key = key;
    req.refNo = refNo;
    req.rawAmount = amount;
    req.amount = [NSDecimalNumber decimalNumberWithString:amount];
    req.comment = comment;
    req.returnUrl = returnUrl;
    req.notifyUrl = notifyUrl;
    req.signature = signature;
    return req.valid ? req : nil;
}

- (RCHPayTarget)target {
    if ([self.target_ isEqualToString:@"freeze"]) {
        return RCHPayTargetFreeze;
    }
    return RCHPayTargetDeduct;
}

- (BOOL)valid {
    if (self.key == nil ||
        self.refNo == nil ||
        !self.amount ||
        [self.amount compare:[NSDecimalNumber zero]] != NSOrderedDescending ||
        self.comment == nil ||
        self.returnUrl == nil ||
        self.notifyUrl == nil ||
        self.signature == nil)
        return NO;
    return YES;
}

- (NSDictionary *)dispose {
    return @{@"pay_info": @{
                     @"refNo": self.refNo,
                     @"amount": self.rawAmount,
                     @"comment": self.comment,
                     @"merchantKey": self.key,
                     @"signature": self.signature,
                     @"returnUrl": self.returnUrl,
                     @"notifyUrl": self.notifyUrl
                     }};
}

@end
