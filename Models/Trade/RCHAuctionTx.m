//
//  RCHAuctionTx.m
//  richcore
//
//  Created by WangDong on 2018/8/3.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAuctionTx.h"

@implementation RCHAuctionTx

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.tx_id = 0;
    self.fee = nil;
    self.amount = nil;
    self.price = nil;
    self.created_at = nil;
    
    return self;
}

- (void)dealloc {
    
    self.fee = nil;
    self.amount = nil;
    self.price = nil;
    self.created_at = nil;
}



+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"tx_id" : @"id"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

- (void)mj_keyValuesDidFinishConvertingToObject
{
    NSLog(@"finish");
    
}

@end
