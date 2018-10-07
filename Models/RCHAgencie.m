//
//  RCHAgencie.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAgencie.h"

@implementation RCHAgencie

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.bids = [NSArray array];
    self.asks = [NSArray array];
    return self;
}

- (void)dealloc {
    
    self.bids = nil;
    self.asks = nil;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"bids":[NSArray class],
             @"asks":[NSArray class]
             };
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
