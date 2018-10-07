//
//  RCHTransaction.h
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHTransaction : NSObject

@property (nonatomic, assign) NSInteger *transaction_id;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSNumber *fee;
@property (nonatomic, copy) NSString *created_at;

- (NSDecimalNumber *)volume;

@end
