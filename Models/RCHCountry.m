//
//  RCHCountry.m
//  MeiBe
//
//  Created by WangDong on 2018/3/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHCountry.h"

@implementation RCHCountry

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.countryId = 0;
    self.code = nil;
    self.name_cn = nil;
    self.name_en = nil;
    
    return self;
}

- (void)dealloc {
    self.code = nil;
    self.name_cn = nil;
    self.name_en = nil;
}


+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"countryId" : @"id"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

@end
