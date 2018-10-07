//
//  WDRequestManager.h
//  uber
//
//  Created by Dong Wang on 2018/1/23.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "WDBaseResponse.h"

typedef NSString RCHDataName;

typedef enum : NSInteger {
    // 自定义错误码
    WDRequestManagerStatusCodeCustomDemo = -10000,
} WDRequestManagerStatusCode;

typedef WDBaseResponse *(^ResponseFormat)(WDBaseResponse *response);

@interface WDRequestManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

//本地数据模式
@property (assign, nonatomic) BOOL isLocal;

//预处理返回的数据
@property (copy, nonatomic) ResponseFormat responseFormat;

//当前请求
@property (strong, nonatomic) NSURLSessionDataTask *currentTask;

// https 验证
@property (nonatomic, copy) NSString *cerFilePath;

- (NSURLSessionDataTask *)PUT:(NSString *)urlString parameters:(id)parameters completion:(void (^)(WDBaseResponse *))completion;

- (NSURLSessionDataTask *)POST:(NSString *)urlString parameters:(id)parameters completion:(void (^)(WDBaseResponse *))completion;

- (NSURLSessionDataTask *)GET:(NSString *)urlString parameters:(id)parameters completion:(void (^)(WDBaseResponse *))completion;

- (NSURLSessionDataTask *)DELETE:(NSString *)urlString parameters:(id)parameters completion:(void (^)(WDBaseResponse *))completion;
/*
 上传
 data 数据对应的二进制数据
 RCHDataName data对应的参数
 */
- (void)upload:(NSString *)urlString parameters:(id)parameters formDataBlock:(NSDictionary<NSData *, RCHDataName *> *(^)(id<AFMultipartFormData> formData, NSMutableDictionary<NSData *, RCHDataName *> *needFillDataDict))formDataBlock progress:(void (^)(NSProgress *progress))progress completion:(void (^)(WDBaseResponse *response))completion;


@end
