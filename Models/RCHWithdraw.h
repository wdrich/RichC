//
//  RCHWithdraw.h
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHWithdraw : NSObject

@property (nonatomic, assign) NSInteger withdraw_id;

@property (nonatomic, copy) NSString *hash_string;
@property (nonatomic, copy) NSString *coin_code;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *confirmed_at;
@property (nonatomic, copy) NSString *resolved_at;
@property (nonatomic, copy) NSString *revoked_at;

@property (nonatomic, strong) NSNumber *arrival;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSNumber *fee;
@property (nonatomic, strong) RCHCoin *coin;

- (NSString *)status;

@end



typedef NS_ENUM(NSUInteger, RCHWithdrawVerifyType) {
    RCHWithdrawVerifyTypeNone,
    RCHWithdrawVerifyTypeAll,
    RCHWithdrawVerifyTypeGoogle,
    RCHWithdrawVerifyTypeMobile
};

@interface RCHWithdrawInfo : NSObject

@property (nonatomic, copy) NSString *verify_type;
@property (nonatomic, strong) NSNumber *min;
@property (nonatomic, strong) NSNumber *max;
@property (nonatomic, strong) NSNumber *fee;
@property (nonatomic, strong) NSNumber *was;

- (RCHWithdrawVerifyType)verifyType;

@end

@interface RCHWithdrawDraft: NSObject

- (instancetype)initWithNeedTag:(BOOL)needTag;

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, strong) NSDecimalNumber *amount;

- (BOOL)needTag;
- (BOOL)valid;
- (NSDictionary *)dispose;

@end
