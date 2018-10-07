//
//  RCHAlertTableview.h
//  MeiBe
//
//  Created by WangDong on 2018/3/30.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHAlertCell.h"

@interface RCHAlertTableview : UITableView <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) NSMutableArray *items;

@end
