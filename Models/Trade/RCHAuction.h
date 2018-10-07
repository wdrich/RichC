//
//  RCHAuction.h
//  richcore
//
//  Created by WangDong on 2018/7/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHAuction : NSObject

@property (nonatomic, assign) BOOL isDraw;
@property (nonatomic, copy) NSString *sumReward;
@property (nonatomic, copy) NSString *grantReward;
@property (nonatomic, copy) NSString *orderCount;
@property (nonatomic, copy) NSString *surplusCount;
@property (nonatomic, copy) NSString *activtedAt;
@property (nonatomic, copy) NSString *closedDate;
@property (nonatomic, copy) NSString *winProbable;
@property (nonatomic, copy) NSString *duration;


@end
