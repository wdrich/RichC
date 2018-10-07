//
//  RCHAlert.m
//  MeiBe
//
//  Created by WangDong on 2018/3/30.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAlert.h"

@implementation RCHAlert

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.title = nil;
    self.subTitle = nil;
    self.value = nil;
    self.icon = nil;
    
    return self;
}

- (void)dealloc {
    self.title = nil;
    self.value = nil;
    self.icon = nil;
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
