//
//  RCHPayResp.h
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHPayResp : NSObject

@property (nonatomic, copy) NSString *refNo;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic, copy) NSString *rawAmount;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *payState;
@property (nonatomic, copy) NSString *tradeState;
@property (nonatomic, copy) NSString *sign;

- (NSDecimalNumber *)amount;
- (NSDictionary *)dispose;

@end
