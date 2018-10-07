//
//  RCHAuthResp.m
//  richcore
//
//  Created by Apple on 2018/5/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAuthResp.h"

@implementation RCHAuthResp

- (NSDictionary *)dispose {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.openId, @"open_id", self.nonce, @"nonce", self.signature, @"signature", nil];
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"openId": @"open_id"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

@end
