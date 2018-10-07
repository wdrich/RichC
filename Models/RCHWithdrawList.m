//
//  RCHWithdrawList.m
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWithdrawList.h"

@implementation RCHWithdrawList

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.total = 0;
    self.page = 0;
    self.records = [NSArray array];
    
    return self;
}

- (void)dealloc {
    
    self.records = nil;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"records":[RCHWithdraw class]
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
