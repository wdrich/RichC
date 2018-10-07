//
//  RCHStatus.m
//  uber
//
//  Created by WangDong on 2018/1/21.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "RCHStatus.h"

@implementation RCHStatus

- (id)initWithCode:(NSInteger)code message:(NSString *)message
{
    if(self = [super init]) {
        _code = code;
        _message = message;
    }
    
    return self;
}

+ (id)statusWithCode:(NSInteger)code message:(NSString *)message
{
    return [[RCHStatus alloc] initWithCode:code message:message];
}


- (void)dealloc {
    self.code = 0;
    self.message = nil;
}


@end
