//
//  RCHStaticTableViewController.h
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTableViewController.h"
#import "RCHKeyValueItem.h"
#import "RCHItemSection.h"
#import "RCHKeyValueArrowItem.h"

@interface RCHStaticTableViewController : RCHTableViewController

// 需要把组模型添加到数据中
@property (nonatomic, strong) NSMutableArray<RCHItemSection *> *sections;


// 自定义某一行cell的时候调用super, 返回为空
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (RCHStaticTableViewController *(^)(RCHKeyValueItem *item))addItem;
@end

UIKIT_EXTERN const UIEdgeInsets tableViewDefaultSeparatorInset;
UIKIT_EXTERN const UIEdgeInsets tableViewDefaultLayoutMargins;

