//
//  RCHAuthReq.m
//  richcore
//
//  Created by Apple on 2018/5/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAuthReq.h"

@implementation RCHAuthReq

+ (RCHAuthReq *)reqWithKey:(NSString *)key signature:(NSString *)signature nonce:(NSString *)nonce
{
    RCHAuthReq *req = [[RCHAuthReq alloc] init];
    req.key = key;
    req.signature = signature;
    req.nonce = nonce;
    return req;
}

- (NSDictionary *)dispose {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.nonce, @"nonce", nil];
}

@end
