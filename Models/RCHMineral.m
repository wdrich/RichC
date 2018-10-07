//
//  RCHMineral.m
//  richcore
//
//  Created by Apple on 2018/7/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMineral.h"

@implementation RCHMineral

- (id)init {
    self = [super init];
    if(!self) return nil;
    self.coin = nil;
    return self;
}

- (void)dealloc {
    
    self.coin = nil;
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
