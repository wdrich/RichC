//
//  RCHWebViewJSBridge.h
//  richcore
//
//  Created by Apple on 2018/5/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JBHandlerCallback)(id data);
typedef void (^JBHandler)(id data, __nullable JBHandlerCallback callback);

@interface RCHWebViewJSBridge : NSObject

@property (nonatomic, strong) WKWebView *webview;

+ (RCHWebViewJSBridge *)bridgeWebView:(WKWebView *)webview;
- (void)didFinishLoad:(WKWebView *)webview;
- (void)registerHandler:(NSString *)handlerName handler:(JBHandler)handler;
- (void)callHandler:(NSString *)handlerName data:(id)data callback:(__nullable JBHandlerCallback)callback;

@end
