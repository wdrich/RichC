//
//  RCHVersion.m
//  richcore
//
//  Created by WangDong on 2018/5/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHVersion.h"

@implementation RCHVersion

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.isMustUpdate = NO;
    self.version = nil;
    self.downloadUrl = nil;
    self.updateInfo = nil;
    return self;
}

- (void)dealloc {
    
    self.version = nil;
    self.downloadUrl = nil;
    self.updateInfo = nil;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{};
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"updateInfo" : @"new_features",
             @"downloadUrl" : @"download_url",
             @"isMustUpdate" : @"must_update"
             };
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}


@end
