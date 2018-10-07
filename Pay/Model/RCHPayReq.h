//
//  RCHPayReq.h
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RCHPayTarget) {
    RCHPayTargetDeduct,
    RCHPayTargetFreeze
};

@interface RCHPayReq : NSObject

@property (nonatomic, copy) NSString *target_;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *refNo;
@property (nonatomic, copy) NSString *rawAmount;
@property (nonatomic, strong) NSDecimalNumber *amount;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *returnUrl;
@property (nonatomic, copy) NSString *notifyUrl;

+ (RCHPayReq *)reqWithTarget:(NSString *)target
                         key:(NSString *)key
                       refNo:(NSString *)refNo
                      amount:(NSString *)amount
                     comment:(NSString *)comment
                   returnUrl:(NSString *)returnUrl
                   notifyUrl:(NSString *)notifyUrl
                   signature:(NSString *)signature;
- (BOOL)valid;
- (RCHPayTarget)target;
- (NSDictionary *)dispose;

@end
