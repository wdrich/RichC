//
//  RCHRefreshTableViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRefreshTableViewController.h"

@interface RCHRefreshTableViewController ()

@end

@implementation RCHRefreshTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.mj_footer.hidden = YES;
    
    RCHWeak(self);
    self.tableView.mj_header = [RCHNormalRefreshHeader headerWithRefreshingBlock:^{
        [weakself loadIsMore:NO];
    }];
    self.tableView.mj_footer = [RCHAutoRefreshFooter footerWithRefreshingBlock:^{
        [weakself loadIsMore:YES];
    }];
}


// 内部方法
- (void)loadIsMore:(BOOL)isMore
{
    // 控制只能下拉或者上拉
    if (isMore) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
            return;
        }
        self.tableView.mj_header.hidden = YES;
        self.tableView.mj_footer.hidden = NO;
    }else
    {
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
            return;
        }
        self.tableView.mj_header.hidden = NO;
        self.tableView.mj_footer.hidden = YES;
    }
    [self loadMore:isMore];
}

// 结束刷新
- (void)endHeaderFooterRefreshing
{
    // 结束刷新状态
    ![self.tableView.mj_header isRefreshing] ?: [self.tableView.mj_header endRefreshing];
    ![self.tableView.mj_footer isRefreshing] ?: [self.tableView.mj_footer endRefreshing];
    self.tableView.mj_header.hidden = NO;
    self.tableView.mj_footer.hidden = YES;
} 

// 子类需要调用调用
- (void)loadMore:(BOOL)isMore
{

}


@end
