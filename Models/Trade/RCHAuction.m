//
//  RCHAuction.m
//  richcore
//
//  Created by WangDong on 2018/7/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAuction.h"

@implementation RCHAuction

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.isDraw = false;
    self.sumReward = nil;
    self.grantReward = nil;
    self.orderCount = nil;
    self.surplusCount = nil;
    self.activtedAt = nil;
    self.closedDate = nil;
    self.winProbable = nil;
    self.duration = nil;
    
    return self;
}

- (void)dealloc {
    
    self.isDraw = false;
    self.sumReward = nil;
    self.grantReward = nil;
    self.orderCount = nil;
    self.surplusCount = nil;
    self.activtedAt = nil;
    self.closedDate = nil;
    self.winProbable = nil;
    self.duration = nil;
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

- (void)mj_keyValuesDidFinishConvertingToObject
{
    NSLog(@"finish");
}
@end
