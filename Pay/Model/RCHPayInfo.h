//
//  RCHPayInfo.h
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHOfficial.h"

typedef NS_ENUM(NSUInteger, RCHPayVerifyMethod) {
    RCHPayVerifyMethodMobile,
    RCHPayVerifyMethodGoogle,
    RCHPayVerifyMethodEmail
};

@interface RCHPayVerifyInfo: NSObject

@property (nonatomic, copy) NSString *method_;
@property (nonatomic, copy) NSString *identifier;

- (RCHPayVerifyMethod)method;

@end

@interface RCHPayInfo : NSObject

@property (nonatomic, strong) RCHOfficial *official;
@property (nonatomic, strong) NSNumber *balance;
@property (nonatomic, strong) NSNumber *freeze;
@property (nonatomic, strong) RCHPayVerifyInfo *verifyInfo;

- (NSDecimalNumber *)available;

@end
