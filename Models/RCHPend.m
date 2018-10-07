//
//  RCHPend.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHPend.h"

@implementation RCHPend


- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.price = nil;
    self.quantity = nil;
    self.amount = nil;
    return self;
}

- (void)dealloc {
    self.price = nil;
    self.quantity = nil;
    self.amount = nil;
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
