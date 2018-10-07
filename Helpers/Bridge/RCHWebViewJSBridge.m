//
//  RCHWebViewJSBridge.m
//  richcore
//
//  Created by Apple on 2018/5/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWebViewJSBridge.h"
#import "MallBridge_JS.h"

@interface RCHWebViewJSBridge()<WKScriptMessageHandler> {
    BOOL _ready;
    NSMutableDictionary *_handlers;
}
@end

@implementation RCHWebViewJSBridge

+ (RCHWebViewJSBridge *)bridgeWebView:(WKWebView *)webview
{
    RCHWebViewJSBridge *bridge = [[RCHWebViewJSBridge alloc] init];
    bridge.webview = webview;
    return bridge;
}

- (id)init
{
    self = [super init];
    if (self) {
        _ready = NO;
        _handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setWebview:(WKWebView *)webview
{
    _webview = webview;
    if (webview.configuration && webview.configuration.userContentController) {
        [_webview.configuration.userContentController addScriptMessageHandler:self name:@"observe"];
    }
}

- (void)didFinishLoad:(WKWebView *)webview
{
    if (webview != _webview) return;
    
    [_webview evaluateJavaScript:MallBridge_js() completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            self->_ready = YES;
        }
    }];
}

- (void)registerHandler:(NSString *)handlerName handler:(JBHandler)handler
{
    _handlers[handlerName] = [handler copy];
}

- (void)callHandler:(NSString *)handlerName data:(__nullable id)data callback:(JBHandlerCallback)callback
{
    if (!_ready) return;
    
    NSString *messageJSON = [self _serializeMessage:[NSDictionary dictionaryWithObjectsAndKeys:handlerName, @"handlerName", data, @"data", nil] pretty:NO];
    [self dispatch:messageJSON];
}

- (void)dispatch:(NSString *)json
{
    [_webview evaluateJavaScript:[NSString stringWithFormat:@"window.MallBridge._handleMessageFromObjC('%@')", json]
               completionHandler:nil];
}

- (NSString *)_serializeMessage:(NSDictionary *)message pretty:(BOOL)pretty{
    NSString *messageJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    return messageJSON;
}

- (NSDictionary *)_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"observe"]) {
        NSDictionary *messageDictionary = [self _deserializeMessageJSON:message.body];
        JBHandler handler = _handlers[messageDictionary[@"handlerName"]];
        if (!handler) return;
        JBHandlerCallback callback = ^(id data) {
            [self dispatch:[self _serializeMessage:data pretty:NO]];
        };
        handler( messageDictionary[@"data"], callback );
    }
}

@end
