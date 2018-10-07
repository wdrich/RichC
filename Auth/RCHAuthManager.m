//
//  RCHAuthManager.m
//  richcore
//
//  Created by Apple on 2018/5/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAuthManager.h"
#import "RCHAuthRequest.h"

static RCHAuthManager *authManager = nil;

@interface RCHAuthManager () {
    void (^_completion)(RCHAuthResp *);
    RCHAuthReq *_req;
    
    RCHAuthRequest *_authRequest;
    RCHAuthResp *_resp;
}
@end

@implementation RCHAuthManager

+ (void)authWithReq:(RCHAuthReq *)req completion:(void (^)(RCHAuthResp *))completion {
    if (!([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0)) return;
    if (!(req && req.key && req.signature && req.nonce)) return;
    if (authManager && ![authManager canAuth]) return;
    
    if (!authManager) {
        authManager = [[RCHAuthManager alloc] init];
    }
    [authManager beginWithReq:req completion:completion];
}

- (BOOL)canAuth {
    return !_completion && !_req && !_resp;
}

- (void)beginWithReq:(RCHAuthReq *)req completion:(void (^)(RCHAuthResp *))completion {
    if (!_authRequest) {
        _authRequest = [[RCHAuthRequest alloc] init];
    }
    
    if (_authRequest.currentTask) {
        [_authRequest.currentTask cancel];
    }
    
    [_authRequest authWithReq:req completion:^(NSObject *resp) {
        if ([resp isKindOfClass:[RCHAuthResp class]]) {
            self->_completion = [completion copy];
            self->_req = req;
            
            self->_resp = (RCHAuthResp *)resp;
            
            [self complete];
        } else {
            completion(nil);
        }
    }];
}

- (void)complete {
    self->_completion(self->_resp);
    
    self->_resp = nil;
    self->_req = nil;
    self->_completion= nil;
}

@end
