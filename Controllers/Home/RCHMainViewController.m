//
//  RCHMainViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMainViewController.h"
#import "RCHAuthManager.h"
#import "RCHPayManager.h"

@interface RCHMainViewController ()
{
    RCHAuthReq *_authReq;
    RCHPayReq *_payReq;
    BOOL _isHome;
}
@end

@implementation RCHMainViewController

- (id)initWithHome:(BOOL)isHome {
    self = [super init];
    if (self) {
        _isHome = isHome;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessfull:) name:kLoginDidSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccessfull:) name:kLogoutDidSuccessNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.webView.frame;
    self.webView.frame = (CGRect){frame.origin, {frame.size.width, frame.size.height - (_isHome ? kTabBarHeight : 0)}};
    
    RCHWeak(self);
    
    self.webView.scrollView.mj_header = [RCHNormalRefreshHeader headerWithRefreshingBlock:^{
        [weakself.webView reload];
    }];
    
    [self _registerHandlers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - bridge

- (void)_registerHandlers {
    if (!self.bridge) return;
    
    [self.bridge registerHandler:@"login"
                         handler:^(id data, JBHandlerCallback callback) {
                             RCHAuthReq *req = [RCHAuthReq reqWithKey:data[@"key"]
                                                            signature:data[@"signature"]
                                                                nonce:data[@"nonce"]];
                             
                             if (self->_authReq) self->_authReq = nil;
                             if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
                                 [self _auth:req];
                             } else {
                                 self->_authReq = req;
                                 if ([data[@"force"] boolValue]) {
                                     [[NSNotificationCenter defaultCenter] postNotificationName:kGotoLoginNotification
                                                                                         object:nil];
                                 }
                             }
                         }];
    [self.bridge registerHandler:@"pay"
                         handler:^(id data, JBHandlerCallback callback) {
                             if (!([data[@"target"] isEqualToString:@"deduct"] || [data[@"target"] isEqualToString:@"freeze"])) return;
                             
                             RCHPayReq *req = [RCHPayReq reqWithTarget:data[@"target"]
                                                                   key:data[@"merchantKey"]
                                                                 refNo:data[@"refNo"]
                                                                amount:data[@"amount"]
                                                               comment:data[@"comment"]
                                                             returnUrl:data[@"returnUrl"]
                                                             notifyUrl:data[@"notifyUrl"]
                                                             signature:data[@"signature"]];
                             if (!req.valid) return;
                             
                             if (self->_payReq) self->_payReq = nil;
                             if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
                                 [self _pay:req];
                             } else {
                                 self->_payReq = req;
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kGotoLoginNotification
                                                                                     object:nil];
                             }
                         }];
}

#pragma mark - auth

- (void)_auth:(RCHAuthReq *)req
{
    if (!self.bridge) return;
    [RCHAuthManager authWithReq:req
                     completion:^(RCHAuthResp *resp) {
                         if (resp == nil) return;
                         [self.bridge callHandler:@"login"
                                             data:[resp dispose]
                                         callback:nil];
                     }];
}

- (void)_pay:(RCHPayReq *)req
{
    if (!self.bridge) return;
    [RCHPayManager payWithReq:req
                   completion:^(RCHPayResp *resp) {
                       if (resp == nil) return;
                       [self.bridge callHandler:@"pay"
                                           data:[resp dispose]
                                       callback:nil];
                   }];
}

#pragma mark - notification

- (void)loginSuccessfull:(NSNotification *)notification
{
    if (!self.bridge) return;
    
    if (_authReq) {
        [self _auth:_authReq];
        _authReq = nil;
    }
    if (_payReq) {
        [self _pay:_payReq];
        _payReq = nil;
    }
}

- (void)logoutSuccessfull:(NSNotification *)notification
{
    if (!self.bridge) return;
    [self.bridge callHandler:@"logout"
                        data:nil
                    callback:nil];
}

#pragma mark -
#pragma mark - WDNavUIBaseViewControllerDataSource
- (UIView *)RCHNavigationBarLeftView:(RCHNavigationBar *)navigationBar
{
    if (_isHome) {
        return nil;
    } else {
        return [super RCHNavigationBarLeftView:navigationBar];
    }
}

- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar
{
    if (_isHome) {
        return nil;
    } else {
        return [super RCHNavigationBarRightButtonImage:rightButton navigationBar:navigationBar];
    }
}

- (BOOL)webViewController:(RCHWebViewController *)webViewController webViewIsNeedAutoTitle:(WKWebView *)webView
{
    if (_isHome) {
        return NO;
    } else {
        return [super webViewController:webViewController webViewIsNeedAutoTitle:webView];
    }
}

#pragma mark -
#pragma mark - RCHWebViewControllerDataSource


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if ([navigationResponse.response.URL.absoluteString isEqualToString:self.gotoURL]) {
        self.progressView.hidden = YES;
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else {
        if (_isHome) {
            decisionHandler(WKNavigationResponsePolicyCancel);
            RCHMainViewController *webviewController = [[RCHMainViewController alloc] initWithHome:NO];
            webviewController.gotoURL = navigationResponse.response.URL.absoluteString;
            [self.navigationController pushViewController:webviewController animated:YES];
        } else {
            decisionHandler(WKNavigationResponsePolicyAllow);
        }
    }
    
}

// 默认需要, 是否需要进度条
- (BOOL)webViewController:(RCHWebViewController *)webViewController webViewIsNeedProgressIndicator:(WKWebView *)webView
{
    return YES;
}


@end
