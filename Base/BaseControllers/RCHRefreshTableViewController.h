//
//  RCHRefreshTableViewController.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTableViewController.h"
#import "RCHAutoRefreshFooter.h"
#import "RCHNormalRefreshHeader.h"

@interface RCHRefreshTableViewController : RCHTableViewController

- (void)loadMore:(BOOL)isMore;

// 结束刷新, 子类请求报文完毕调用
- (void)endHeaderFooterRefreshing;


@end
