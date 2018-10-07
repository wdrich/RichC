//
//  RCHHistoryFlowsController.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRefreshTableViewController.h"

typedef NS_ENUM(NSInteger, RCHFlowsType) {
    RCHFlowsTypeRecharge        = 0, //充值
    RCHFlowsTypeShareUnlock     = 1
};

@interface RCHHistoryFlowsController : RCHRefreshTableViewController

- (id)initWithFlowsType:(RCHFlowsType)type;

@end
