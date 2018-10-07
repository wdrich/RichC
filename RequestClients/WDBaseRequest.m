//
//  WDBaseRequest.m
//  uber
//
//  Created by Dong Wang on 2018/1/23.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "WDBaseRequest.h"

@implementation WDBaseRequest


- (void)GET:(NSString *)URLString parameters:(id)parameters completion:(void(^)(WDBaseResponse *response))completion
{
    
    RCHWeak(self);
//    _requestManager = [WDRequestManager sharedManager];
    self.currentTask = [self.requestManager GET:URLString parameters:parameters completion:^(WDBaseResponse *response) {
        if (!weakself) {
            return ;
        }
        !completion ?: completion(response);
    }];
}

- (void)POST:(NSString *)URLString parameters:(id)parameters completion:(void(^)(WDBaseResponse *response))completion
{
    RCHWeak(self);
//    _requestManager = [WDRequestManager sharedManager];
    self.currentTask = [self.requestManager POST:URLString parameters:parameters completion:^(WDBaseResponse *response) {
        
        if (!weakself) {
            return ;
        }
        !completion ?: completion(response);
    }];
}

- (void)PUT:(NSString *)URLString parameters:(id)parameters completion:(void(^)(WDBaseResponse *response))completion
{
    RCHWeak(self);
//    _requestManager = [WDRequestManager sharedManager];
    self.currentTask = [self.requestManager PUT:URLString parameters:parameters completion:^(WDBaseResponse *response) {
        if (!weakself) {
            return ;
        }
        !completion ?: completion(response);
    }];
}

- (void)DELETE:(NSString *)URLString parameters:(id)parameters completion:(void(^)(WDBaseResponse *response))completion
{
    RCHWeak(self);
    //    _requestManager = [WDRequestManager sharedManager];
    self.currentTask = [self.requestManager DELETE:URLString parameters:parameters completion:^(WDBaseResponse *response) {
        if (!weakself) {
            return ;
        }
        !completion ?: completion(response);
    }];
}


- (WDRequestManager *)requestManager
{
    if(_requestManager == nil)
    {
        _requestManager = [WDRequestManager sharedManager];
    }
    return _requestManager;
}



@end
