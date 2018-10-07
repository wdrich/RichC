//
//  RCHFlow.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHFlow.h"

@implementation RCHFlow

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.coin = nil;
    self.coin_code = nil;
    self.quantity = nil;
    self._dtype = nil;
    self.created_at = nil;
    self.hash_string = nil;
    
    return self;
}

- (void)dealloc {
    self.coin = nil;
    self.coin_code = nil;
    self.quantity = nil;
    self._dtype = nil;
    self.created_at = nil;
    self.hash_string = nil;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"hash_string" : @"hash"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}


@end
