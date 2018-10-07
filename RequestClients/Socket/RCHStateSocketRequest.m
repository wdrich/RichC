//
//  RCHStateSocketRequest.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHStateSocketRequest.h"
#import "JSONKit.h"
#import "RCHState.h"
#import "RCHOrder.h"
#import "RCHPend.h"
#import "RCHAgencie.h"
#import "RCHWallet.h"
#import "RCHAuction.h"
#import "RCHAuctionTx.h"

#define errorCountNumber 20

@implementation RCHStateSocketRequest


- (id)initWithSymbol:(NSString *)symbol
{
    self = [super init];
    if (self) {
        _isReconnect = YES;
        _symbol = [symbol copy];
        [self reconnect];
    }
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    return self;
}

- (void)reconnect
{
    [self stopTimer];
    _webSocket.delegate = nil;
    [_webSocket close];
    
    NSString *urlString = kRichcoreStatesUrl;
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@/%@", urlString, _symbol];
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
    [_webSocket setRequestCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:kRichcoreStatesUrl]]];
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
    if ([_delegate respondsToSelector:@selector(keepAliveSocketDidOpen:)])
    {
        [_delegate keepAliveSocketDidOpen:_webSocket];
    }
}

static int errorCount = 0;
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if (errorCount >= errorCountNumber) {
        errorCount = 0;
        _isReconnect = NO;
        if ([_delegate respondsToSelector:@selector(keepAliveSocket:didFailWithError:)])
        {
            [_delegate keepAliveSocket:_webSocket didFailWithError:nil];
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
    NSString *event = [resultDictionary objectForKey:@"event"];
    
//    NSLog(@"socket:%@", event);
    
    if ([event isEqualToString:@"TICKER"]) {
        RCHState *state = [RCHState mj_objectWithKeyValues:[resultDictionary objectForKey:@"data"]];
        if ([_delegate respondsToSelector:@selector(keepAliveSocket:didReceiveNotifications:event:)])
        {
            [_delegate keepAliveSocket:_webSocket didReceiveNotifications:state event:event];
        }
    } else if ([event isEqualToString:@"DEPTH"]) {
        NSDictionary *result = [resultDictionary objectForKey:@"data"];
        if ([_delegate respondsToSelector:@selector(keepAliveSocket:didReceiveNotifications:event:)] && [result objectForKey:@"asks"] && [[result objectForKey:@"asks"] isKindOfClass:[NSArray class]] && [result objectForKey:@"bids"] && [[result objectForKey:@"bids"] isKindOfClass:[NSArray class]])
        {
            [_delegate keepAliveSocket:_webSocket didReceiveNotifications:result event:event];
        }
    } else if ([event isEqualToString:@"WALLET"]) {
        NSArray *wallets = [NSArray mj_objectArrayWithKeyValuesArray:[resultDictionary objectForKey:@"data"]];
        if ([wallets count] != 2) return;
        if ([_delegate respondsToSelector:@selector(keepAliveSocket:didReceiveNotifications:event:)])
        {
            [_delegate keepAliveSocket:_webSocket
               didReceiveNotifications:@[[RCHWallet mj_objectWithKeyValues:wallets[0]],
                                         [RCHWallet mj_objectWithKeyValues:wallets[1]]]
                                 event:event];
        }
    } else if ([event isEqualToString:@"CURRENT_AGENCY"]){
//        NSLog(@"CURRENT_AGENCY:%@", resultDictionary);
        NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:[resultDictionary objectForKey:@"data"]];
        NSMutableArray *orders = [NSMutableArray array];
        for (NSDictionary *dic in dics) {
            RCHOrder *order = [RCHOrder mj_objectWithKeyValues:dic];
            [orders addObject:order];
        }
        if ([_delegate respondsToSelector:@selector(keepAliveSocket:didReceiveNotifications:event:)])
        {
            [_delegate keepAliveSocket:_webSocket didReceiveNotifications:orders event:event];
        }
        
    } else if ([event isEqualToString:@"RECENT_AGENCY"]){
//        NSLog(@"RECENT_AGENCY:%@", resultDictionary);
        NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:[resultDictionary objectForKey:@"data"]];
        NSMutableArray *orders = [NSMutableArray array];
        for (NSDictionary *dic in dics) {
            RCHOrder *order = [RCHOrder mj_objectWithKeyValues:dic];
            [orders addObject:order];
        }
        if ([_delegate respondsToSelector:@selector(keepAliveSocket:didReceiveNotifications:event:)])
        {
            [_delegate keepAliveSocket:_webSocket didReceiveNotifications:orders event:event];
        }
    } else if ([event isEqualToString:@"READY"]){
        
    } else if ([event isEqualToString:@"AUCTION_SUMMARY"]){
        RCHAuction *auction = [RCHAuction mj_objectWithKeyValues:[resultDictionary objectForKey:@"data"]];
        if ([_delegate respondsToSelector:@selector(keepAliveSocket:didReceiveNotifications:event:)])
        {
            [_delegate keepAliveSocket:_webSocket didReceiveNotifications:auction event:event];
        }
    } else if ([event isEqualToString:@"AUCTION_TXS"]){
        NSArray *dics = [NSArray mj_objectArrayWithKeyValuesArray:[resultDictionary objectForKey:@"data"]];
        
        if (dics.count > 0) {
            RCHAuctionTx *auctionTx = [RCHAuctionTx mj_objectWithKeyValues:dics[0]];
            if ([_delegate respondsToSelector:@selector(keepAliveSocket:didReceiveNotifications:event:)])
            {
                [_delegate keepAliveSocket:_webSocket didReceiveNotifications:auctionTx event:event];
            }
        }
    } else {
        
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
