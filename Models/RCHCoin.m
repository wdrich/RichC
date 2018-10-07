//
//  RCHCoin.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHCoin.h"

@implementation RCHCoin

- (id)init {
    self = [super init];
    if(!self) return nil;
    self.code = nil;
    self.name_cn = nil;
    self.name_en = nil;
    self.address = nil;
    self.explorer = nil;
    self.intro_link = nil;
    self.can_withdraw = nil;
    self.secondary = nil;
    self.scale = 8;
    self.commodity = false;
    return self;
}

- (void)dealloc {
    
    self.code = nil;
    self.name_cn = nil;
    self.name_en = nil;
    self.address = nil;
    self.explorer = nil;
    self.intro_link = nil;
    self.can_withdraw = nil;
    self.secondary = nil;
}

- (BOOL)canWithdraw
{
    return self.can_withdraw && [self.can_withdraw boolValue];
}

- (BOOL)isSecondary
{
    return self.secondary && [self.secondary boolValue];
}

- (NSString *)icon {
    return [NSString stringWithFormat:@"https://%@%@%@.png", kRichcoreAPIURLDomain, kWalletIconPath, self.code];
}

- (NSString *)explore:(NSString *)txid {
    return [self.explorer stringByReplacingCharactersInRange:[self.explorer rangeOfString:@"%(txId)s"] withString:txid];
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
