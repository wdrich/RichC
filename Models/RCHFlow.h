//
//  RCHFlow.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHFlow : NSObject

@property (nonatomic, strong) RCHCoin *coin;
@property (nonatomic, copy) NSString *coin_code;
@property (nonatomic, copy) NSString *created_at;//创建时间
@property (nonatomic, strong) NSNumber *quantity;//充值数量
@property (nonatomic, copy) NSString *_dtype;//充值类型
@property (nonatomic, copy) NSString *hash_string;//充值类型

@end
