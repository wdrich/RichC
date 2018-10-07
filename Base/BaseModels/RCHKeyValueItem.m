//
//  RCHKeyValueItem.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHKeyValueItem.h"

#define defaultCellHeight 56.0f

@implementation RCHKeyValueItem

+ (instancetype)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    RCHKeyValueItem *item = [[self alloc] init];
    item.subTitle = subTitle;
    item.title = title;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle itemOperation:(void(^)(NSIndexPath *indexPath))itemOperation {
    RCHKeyValueItem *item = [self itemWithTitle:title subTitle:subTitle];
    item.itemOperation = itemOperation;
    return item;
}

- (instancetype)init
{
    if (self = [super init]) {
        _titleColor = [UIColor blackColor];
        _subTitleColor = [UIColor blackColor];
        //        _cellHeight = AdaptedWidth(50);
        _titleFont = AdaptedFontSize(16);
        _subTitleFont = AdaptedFontSize(16);
        _subTitleNumberOfLines = 2;
        
        _cellHeight = 0;
    }
    
    return self;
}

- (CGFloat)cellHeight {
    return defaultCellHeight;
}


@end
