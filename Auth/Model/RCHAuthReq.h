//
//  RCHAuthReq.h
//  richcore
//
//  Created by Apple on 2018/5/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHAuthReq : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *nonce;

+ (RCHAuthReq *)reqWithKey:(NSString *)key signature:(NSString *)signature nonce:(NSString *)nonce;
- (NSDictionary *)dispose;

@end
