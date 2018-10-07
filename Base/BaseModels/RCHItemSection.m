//
//  RCHItemSection.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHItemSection.h"

@implementation RCHItemSection

+ (instancetype)sectionWithItems:(NSArray<RCHKeyValueItem *> *)items andHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle
{
    RCHItemSection *item = [[self alloc] init];
    if (items.count) {
        [item.items addObjectsFromArray:items];
    }
    
    item.headerTitle = headerTitle;
    item.footerTitle = footerTitle;
    
    return item;
}

- (NSMutableArray<RCHKeyValueItem *> *)items
{
    if(!_items)
    {
        _items = [NSMutableArray array];
    }
    return _items;
}


@end
