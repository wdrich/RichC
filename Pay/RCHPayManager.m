//
//  RCHPayManager.m
//  richcore
//
//  Created by Apple on 2018/5/17.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import "RCHPayManager.h"
#import "RCHPayModalView.h"
#import "RCHPayRequest.h"

static RCHPayManager *payManager = nil;

@interface RCHPayManager () {
    void (^_completion)(RCHPayResp *);
    RCHPayReq *_req;
    RCHPayInfo *_payInfo;
    RCHPayModalView *_payModalView;
    
    RCHPayRequest *_payRequest;
    RCHPayResp *_resp;
}
@end

@implementation RCHPayManager

+ (void)payWithReq:(RCHPayReq *)req completion:(void (^)(RCHPayResp *))completion {
    if (!([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0)) return;
    if (!(req && req.valid)) return;
    if (payManager && ![payManager canPay]) return;
    
    if (!payManager) {
        payManager = [[RCHPayManager alloc] init];
    }
    [payManager beginWithReq:req completion:completion];
}

- (BOOL)canPay {
    return !_completion && !_req && !_payInfo && !_payModalView && !_resp;
}

- (void)beginWithReq:(RCHPayReq *)req completion:(void (^)(RCHPayResp *))completion {
    _completion = [completion copy];
    _req = req;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    _payModalView = [[RCHPayModalView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    _payModalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [window addSubview:_payModalView];
    [self loadPayInfo];
}

- (void)loadPayInfo {
    if (!_payRequest) {
        _payRequest = [[RCHPayRequest alloc] init];
    }
    
    if (_payRequest.currentTask) {
        [_payRequest.currentTask cancel];
    }
    
    [MBProgressHUD showLoadToView:_payModalView];
    [_payRequest verifyWithReq:_req completion:^(NSObject *resp) {
        [MBProgressHUD hideHUDForView:self->_payModalView animated:NO];
        if ([resp isKindOfClass:[RCHPayInfo class]] && [[(RCHPayInfo *)resp official] payable]) {
            self->_payInfo = (RCHPayInfo *)resp;
            [self displayPayView];
        } else {
            if ([[[NSJSONSerialization JSONObjectWithData:(NSData *)((WDBaseResponse *)resp).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingAllowFragments error:nil] objectForKey:@"message"] isEqualToString:@"DUPLICATE_REFNO"]) {
                [MBProgressHUD showError:@"订单已支付，请勿重复提交" ToView:self->_payModalView];
            } else {
                [MBProgressHUD showError:@"出错了" ToView:self->_payModalView];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self complete];
            });
        }
    }];
}

- (void)displayPayView {
    [_payModalView displayReq:_req
                      payInfo:_payInfo
                     onSubmit:^(NSString *verifyCode, void (^submitted)(NSString *)) {
                         if (self->_payRequest.currentTask) {
                             [self->_payRequest.currentTask cancel];
                         }
                         [self->_payRequest payWithReq:self->_req
                                            verifyCode:verifyCode
                                            completion:^(NSObject *resp){
                                                if ([resp isKindOfClass:[RCHPayResp class]]) {
                                                    self->_resp = (RCHPayResp *)resp;
                                                    submitted(nil);
                                                } else {
                                                    submitted([[NSJSONSerialization JSONObjectWithData:(NSData *)((WDBaseResponse *)resp).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingAllowFragments error:nil] objectForKey:@"message"]);
                                                }
                                            }];
                     }
                   onComplete:^() {
                       [self complete];
                   }];
}

- (UIViewController *)rootViewController {
    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }
    return root;
}

- (void)complete {
    _completion(_resp);
    [_payModalView removeFromSuperview];
    [self resetParams];
}

- (void)resetParams {
    _payModalView = nil;
    _resp = nil;
    _payInfo = nil;
    _req = nil;
    _completion = nil;
}

@end
