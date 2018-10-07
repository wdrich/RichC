//
//  RCHMarketQuotesViewController.h
//  richcore
//
//  Created by Apple on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRefreshTableViewController.h"

@interface RCHMarketQuotesViewController : RCHRefreshTableViewController

- (instancetype)initWithOnRefresh:( void (^ _Nonnull )(NSDictionary *))onRefresh;
- (void)reloadWithMarketGroup:( NSDictionary * _Nonnull )marketGroup;

@end
