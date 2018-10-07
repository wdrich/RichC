//
//  WDBaseRequest.h
//  uber
//
//  Created by Dong Wang on 2018/1/23.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDBaseResponse;

@interface WDBaseRequest : NSObject

@property (strong, nonatomic) WDRequestManager *requestManager;
//当前请求
@property (strong, nonatomic) NSURLSessionDataTask *currentTask;

- (void)GET:(NSString *)URLString parameters:(id)parameters completion:(void(^)(WDBaseResponse *response))completion;

- (void)POST:(NSString *)URLString parameters:(id)parameters completion:(void(^)(WDBaseResponse *response))completion;

- (void)PUT:(NSString *)URLString parameters:(id)parameters completion:(void(^)(WDBaseResponse *response))completion;

- (void)DELETE:(NSString *)URLString parameters:(id)parameters completion:(void(^)(WDBaseResponse *response))completion;

@end
