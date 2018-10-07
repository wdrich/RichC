//
//  RCHPaging.m
//  richcore
//
//  Created by Apple on 2018/7/5.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHPaging.h"

Class _recordModel = nil;

@implementation RCHPaging

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.total = 0;
    self.page = 0;
    self.records = [NSArray array];
    
    return self;
}

- (void)dealloc {
    
    self.records = nil;
}

- (RCHPaging *)merge:(RCHPaging *)paging {
    RCHPaging *newPaging = [[RCHPaging alloc] init];
    newPaging.total = paging.total;
    newPaging.page = paging.page;
    newPaging.records = [self.records arrayByAddingObjectsFromArray:paging.records];
    return newPaging;
}

+ (RCHPaging *)mj_objectWithKeyValues:(id)object model:(Class)model
{
    _recordModel = model;
    return [RCHPaging mj_objectWithKeyValues:object];
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"records":_recordModel
             };
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
