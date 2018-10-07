//
//  RCHAuthResp.h
//  richcore
//
//  Created by Apple on 2018/5/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHAuthResp : NSObject

@property (nonatomic, copy) NSString *openId;
@property (nonatomic, copy) NSString *nonce;
@property (nonatomic, copy) NSString *signature;

- (NSDictionary *)dispose;

@end
