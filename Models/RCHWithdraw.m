//
//  RCHWithdraw.m
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWithdraw.h"
#import "RCHCoin.h"

@implementation RCHWithdraw

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.withdraw_id = 0;
    
    self.hash_string = nil;
    self.coin_code = nil;
    self.address = nil;
    self.tag = nil;
    self.created_at = nil;
    self.confirmed_at = nil;
    self.resolved_at = nil;
    self.revoked_at = nil;
    
    self.arrival = nil;
    self.amount = nil;
    self.fee = nil;
    
    self.coin = [[RCHCoin alloc] init];
    
    return self;
}

- (void)dealloc {

    self.hash_string = nil;
    self.coin_code = nil;
    self.address = nil;
    self.tag = nil;
    self.created_at = nil;
    self.confirmed_at = nil;
    self.resolved_at = nil;
    self.revoked_at = nil;
    
    self.arrival = nil;
    self.amount = nil;
    self.fee = nil;
    self.coin = nil;
}

- (NSString *)status {
    if (self.revoked_at) return @"已取消";
    if (self.resolved_at) return @"已完成";
    if (self.confirmed_at) return @"进行中";
    return @"待确认";
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"withdraw_id": @"id",
             @"hash_string" : @"hash"
             };
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}

@end




@implementation RCHWithdrawInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        self.verify_type = nil;
    }
    return self;
}

- (RCHWithdrawVerifyType)verifyType
{
    if (self.verify_type == nil) return RCHWithdrawVerifyTypeNone;
    if ([self.verify_type isEqualToString:@"all"]) return RCHWithdrawVerifyTypeAll;
    if ([self.verify_type isEqualToString:@"google"]) return RCHWithdrawVerifyTypeGoogle;
    if ([self.verify_type isEqualToString:@"mobile"]) return RCHWithdrawVerifyTypeMobile;
    return RCHWithdrawVerifyTypeNone;
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

@interface RCHWithdrawDraft()
{
    BOOL _needTag;
}
@end

@implementation RCHWithdrawDraft

- (instancetype)initWithNeedTag:(BOOL)needTag
{
    self = [super init];
    if (self) {
        _needTag = needTag;
    }
    return self;
}

- (BOOL)needTag
{
    return _needTag;
}

- (BOOL)valid
{
    if (self.address != nil && [self.address length] > 0 && (!_needTag || (self.tag != nil && [self.tag length] > 0)) && self.amount != nil && [self.amount compare:[NSDecimalNumber zero]] == NSOrderedDescending) return YES;
    return NO;
}

- (NSDictionary *)dispose
{
    NSMutableDictionary *withdraw = [NSMutableDictionary dictionary];
    [withdraw setObject:self.address forKey:@"address"];
    if (self.tag != nil && [self.tag length] > 0) {
        [withdraw setObject:self.tag forKey:@"tag"];
    }
    [withdraw setObject:[NSString stringWithFormat:@"%.8f", [self.amount doubleValue]] forKey:@"amount"];
    return [NSDictionary dictionaryWithObject:withdraw forKey:@"withdraw"];
}

@end

