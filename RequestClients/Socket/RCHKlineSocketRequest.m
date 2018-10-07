//
//  RCHKlineSocketRequest.m
//  richcore
//
//  Created by WangDong on 2018/7/12.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHKlineSocketRequest.h"
#import "JSONKit.h"

#define errorCountNumber 20

@implementation RCHKlineSocketRequest

- (id)initWithSymbol:(NSString *)symbol filter:(NSString *)filter
{
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self = [super init];
    if (self) {
        _isReconnect = YES;
        _symbol = symbol;
        _filter = filter;
        [self reconnect];
    }
    return self;
}

- (void)reconnect
{
    [self stopTimer];
    _webSocket.delegate = nil;
    [_webSocket close];
    
    NSString *urlString = kRichcoreKlineUrl;
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@?streams=%@@kline_%@", urlString, _symbol, _filter];
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
    [_webSocket setRequestCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]]];
    _webSocket.delegate = self;
    [_webSocket open];
    
}

- (void)close
{
    [self stopTimer];
    _isReconnect = NO;
    [_webSocket close];
}

- (void)sendMessage:(NSString *)message
{
    [_webSocket send:message];
}

- (void)dealloc
{
    _webSocket.delegate = nil;
    _webSocket = nil;
}

#pragma mark -
#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Websocket Connected");
    if ([_delegate respondsToSelector:@selector(klineSocketDidOpen:)])
    {
        [_delegate klineSocketDidOpen:_webSocket];
    }
}

static int errorCount = 0;
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if (errorCount >= errorCountNumber) {
        errorCount = 0;
        _isReconnect = NO;
        if ([_delegate respondsToSelector:@selector(klineSocket:didFailWithError:)])
        {
            [_delegate klineSocket:_webSocket didFailWithError:nil];
        }
    } else {
        [self reconnect];
        errorCount ++;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    errorCount = 0;
    NSDictionary *resultDictionary = [message objectFromJSONString];
    if (resultDictionary) {
        if ([_delegate respondsToSelector:@selector(klineSocket:didReceiveNotifications:)])
        {
            [_delegate klineSocket:_webSocket didReceiveNotifications:resultDictionary];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"WebSocket closed");
    if (_isReconnect) {
        [self reconnect];
    }
}

#pragma mark -
#pragma mark - CustomFuction
//启动定时器
- (void)startTimer:(NSString *)message withInterval:(float)interval {
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(webSocketSendMessage:) userInfo:[NSDictionary dictionaryWithObject:message forKey:@"session"] repeats:YES];
}

//停止定时器
- (void)stopTimer{
    if (_timer && _timer.isValid){
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)webSocketSendMessage:(NSTimer *)timer
{
    NSString *session = [[timer userInfo] objectForKey:@"session"];
    [_webSocket send:session];
}

@end
