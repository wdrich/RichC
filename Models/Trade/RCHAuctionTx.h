//
//  RCHAuctionTx.h
//  richcore
//
//  Created by WangDong on 2018/8/3.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHAuctionTx : NSObject

@property (nonatomic, assign) NSInteger tx_id;
@property (nonatomic, copy) NSString *fee;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *created_at;

@end
