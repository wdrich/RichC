//
//  RCHKlineItem.m
//  richcore
//
//  Created by WangDong on 2018/7/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHKlineItem.h"

@implementation RCHKlineItem


- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.open = nil;
    self.high = nil;
    self.low = nil;
    self.close = nil;
    self.volume = nil;
    
    self.timestamp = [[NSDate date] timeIntervalSinceNow];
    
    return self;
}

- (void)dealloc {
    
    self.open = nil;
    self.high = nil;
    self.low = nil;
    self.close = nil;
    self.volume = nil;
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
