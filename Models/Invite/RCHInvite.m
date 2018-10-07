//
//  RCHInvite.m
//  richcore
//
//  Created by WangDong on 2018/6/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHInvite.h"

@implementation RCHInvite

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.username = nil;
    self.type = nil;
    self.amount = nil;
    self.wallet = nil;
    self.created_at = nil;
    
    return self;
}

- (void)dealloc {
    self.username = nil;
    self.type = nil;
    self.amount = nil;
    self.wallet = nil;
    self.created_at = nil;
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

@implementation RCHInviteInfo


- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.cashes = nil;
    self.code = nil;
    self.totalUser = 0;
    
    return self;
}

- (void)dealloc {
    self.cashes = nil;
    self.code = nil;
    self.totalUser = 0;
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

@implementation RCHInviteList

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.total = 0;
    self.page = 0;
    self.data = [NSArray array];
    
    return self;
}

- (void)dealloc {
    
    self.data = nil;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"data":[RCHInvite class]
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

