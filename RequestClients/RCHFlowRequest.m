//
//  RCHFlowRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHFlowRequest.h"

@implementation RCHFlowRequest

- (void)flows:(void(^)(NSObject *response))completion range:(NSString *)range
{
    [self flows:completion range:range page:0 size:0];
}

- (void)flows:(void(^)(NSObject *response))completion range:(NSString *)range page:(NSUInteger)page size:(NSUInteger)size
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:(range ?: @"all") forKey:@"range"];
    if (page > 0 && size > 0) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%ld", size] forKey:@"size"];
    }
    
    [self GET:kRichcoreFlowUrl parameters:parameters completion:^(WDBaseResponse *response) {
        if (!response.error) {
            if (page > 0 && size > 0) {
                completion([RCHPaging mj_objectWithKeyValues:response.responseObject model:[RCHFlow class]]);
            } else {
                NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:response.responseObject];
                NSMutableArray *flows = [NSMutableArray array];
                for (NSDictionary *dic in dics) {
                    RCHFlow *flow = [RCHFlow mj_objectWithKeyValues:dic];
                    [flows addObject:flow];
                }
                completion((NSArray *)flows);
            }
        } else {
            completion(response);
        }
        
    }];
}

@end
