//
//  RCHPaging.h
//  richcore
//
//  Created by Apple on 2018/7/5.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHPaging : NSObject

@property (nonatomic, assign) NSUInteger total;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, strong) NSArray *records;

+ (RCHPaging *)mj_objectWithKeyValues:(id)object model:(Class)model;
- (RCHPaging *)merge:(RCHPaging *)paging;

@end
