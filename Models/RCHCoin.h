//
//  RCHCoin.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHCoin : NSObject

@property (nonatomic, copy) NSString *code;//缩写
@property (nonatomic, copy) NSString *name_cn;//中文名字
@property (nonatomic, copy) NSString *name_en;//英文名字
@property (nonatomic, copy) NSString *address;//地址
@property (nonatomic, copy) NSString *explorer;
@property (nonatomic, copy) NSString *intro_link;
@property (nonatomic, strong) NSNumber *can_withdraw;
@property (nonatomic, strong) NSNumber *secondary;
@property (nonatomic, assign) NSInteger scale;
@property (nonatomic, assign) BOOL commodity;

- (BOOL)canWithdraw;
- (BOOL)isSecondary;
- (NSString *)icon;
- (NSString *)explore:(NSString *)txid;

@end
