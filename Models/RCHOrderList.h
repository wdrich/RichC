//
//  RCHOrderList.h
//  MeiBe
//
//  Created by WangDong on 2018/3/24.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHOrder.h"

@interface RCHOrderList : NSObject

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSArray *data;

@end
