//
//  RCHOfficial.m
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import "RCHOfficial.h"

@implementation RCHOfficial

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"coinCode": @"coin_code"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[@"coin"];
}

@end
