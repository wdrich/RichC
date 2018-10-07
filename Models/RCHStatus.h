//
//  RCHStatus.h
//  uber
//
//  Created by WangDong on 2018/1/21.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHStatus : NSObject

@property (nonatomic, assign) NSInteger code; //状态码 0表示没有错误
@property (nonatomic, copy) NSString *message; //状态提示信息 code为0时 message为空

- (id)initWithCode:(NSInteger)code message:(NSString *)message;
+ (id)statusWithCode:(NSInteger)code message:(NSString *)message;


@end
