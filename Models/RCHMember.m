//
//  RCHMember.m
//  richcore
//
//  Created by WangDong on 2018/5/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMember.h"

@implementation RCHMember

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.member_id = 0;
    self.grade = 0;
    self.google_auth = false;
    self.second_security_tip = false;
    self.is_kyc_authed = false;
    self.mobile = nil;
    self.mobile_raw = nil;
    self.email = nil;
    self.short_email = nil;
    self.email_raw = nil;
    self.security_level = nil;
    self.roles = [NSArray array];
    
    self.country = [NSDictionary dictionary];
    self.mobile_country = [NSDictionary dictionary];
    self.referral = [NSDictionary dictionary];
    
    return self;
}

- (void)dealloc {
    self.member_id = 0;
    self.grade = 0;
    self.mobile = nil;
    self.mobile_raw = nil;
    self.google_auth = false;
    self.second_security_tip = false;
    self.is_kyc_authed = false;
    self.email = nil;
    self.short_email = nil;
    self.email_raw = nil;
    self.security_level = nil;
    self.roles = nil;    
    self.country = nil;
    self.mobile_country = nil;
    self.referral = nil;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"member_id" : @"id"};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

@end
