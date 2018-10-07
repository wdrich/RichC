//
//  RCHOrderList.m
//  MeiBe
//
//  Created by WangDong on 2018/3/24.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHOrderList.h"

@implementation RCHOrderList

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
             @"data":[RCHOrder class]
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
