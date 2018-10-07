//
//  RCHInvite.h
//  richcore
//
//  Created by WangDong on 2018/6/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHWallet.h"

@interface RCHInvite : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, strong) RCHWallet *wallet;
@property (nonatomic, copy) NSString *created_at;

@end

@interface RCHInviteInfo : NSObject

@property (nonatomic, copy) NSString *cashes;
@property (nonatomic, assign) NSInteger totalUser;
@property (nonatomic, copy) NSString *code;

@end


@interface RCHInviteList : NSObject

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSArray *data;

@end
