//
//  RCHWithdrawList.h
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHWithdraw.h"

@interface RCHWithdrawList : NSObject

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSArray *records;

@end
