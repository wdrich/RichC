//
//  RCHStaticTableViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHStaticTableViewController.h"
#import "RCHKeyValueCell.h"

const UIEdgeInsets tableViewDefaultSeparatorInset = {0, 0, 0, 0};
const UIEdgeInsets tableViewDefaultLayoutMargins = {8, 8, 8, 8};

@interface RCHStaticTableViewController ()

@end

@implementation RCHStaticTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"self.tableView.separatorInset = %@, self.tableView.separatorInset = %@", NSStringFromUIEdgeInsets(self.tableView.separatorInset), NSStringFromUIEdgeInsets(self.tableView.layoutMargins));
    //    self.tableView.separatorInset = UIEdgeInsetsZero;
    //    self.tableView.layoutMargins = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCHKeyValueItem *item = self.sections[indexPath.section].items[indexPath.row];
    RCHKeyValueCell *cell = [RCHKeyValueCell cellWithTableView:tableView andCellStyle:UITableViewCellStyleSubtitle];
    cell.originX = 20.0f;
    cell.spaceX = 20.0f;
    
    UIView *accessoryView = [RCHHelper createAccessoryViewWithImage:RCHIMAGEWITHNAMED(@"next") rotation:UIImageOrientationUp offset:0.0f];
    if (item.accessoryView) {
        accessoryView = item.accessoryView;
    }
    
    [cell setTitle:item.title andValue:item.subTitle andHeadimageUtl:item.imageUrl placeholderImage:item.defaultImage andAccessoryView:accessoryView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RCHKeyValueItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    if (![item.title isEqualToString:NSLocalizedString(@"当前版本",nil)] && ![item.title isEqualToString:NSLocalizedString(@"帮助中心",nil)]) {
        if([RCHHelper gotoLogin]) {
            return;
        }
    }
    
    // 普通的cell
    if(item.itemOperation)
    {
        item.itemOperation(indexPath);
        return;
    }
    
    // 带箭头的cell
    if([item isKindOfClass:[RCHKeyValueArrowItem class]])
    {
        RCHKeyValueArrowItem *arrowItem = (RCHKeyValueArrowItem *)item;
        
        if(arrowItem.destVc)
        {
            UIViewController *vc = [[arrowItem.destVc alloc] init];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.navigationItem.title = arrowItem.title;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections[section].headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.sections[section].footerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = self.sections[indexPath.section].items[indexPath.row].cellHeight;
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForFooterInSection:section]];
    view.backgroundColor = kTabbleViewBackgroudColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10.0f;
    }
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:section]];
    view.backgroundColor = kTabbleViewBackgroudColor;
    return view;
}

- (NSMutableArray<RCHItemSection *> *)sections
{
    if(_sections == nil)
    {
        _sections = [NSMutableArray array];
    }
    return _sections;
}

- (RCHStaticTableViewController *(^)(RCHKeyValueItem *))addItem {
    
    RCHWeak(self);
    if (!self.sections.firstObject) {
        [self.sections addObject:[RCHItemSection sectionWithItems:@[] andHeaderTitle:nil footerTitle:nil]];
    }
    return  ^(RCHKeyValueItem *item) {
        [weakself.sections.firstObject.items addObject:item];
        return weakself;
    };
}

- (instancetype)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

@end
