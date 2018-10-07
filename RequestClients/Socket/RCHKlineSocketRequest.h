//
//  RCHKlineSocketRequest.h
//  richcore
//
//  Created by WangDong on 2018/7/12.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@protocol RCHKlineSocketRequestDelegate;

@interface RCHKlineSocketRequest : NSObject <SRWebSocketDelegate>
{
    SRWebSocket *_webSocket;
    NSTimer *_timer;
    BOOL _isReconnect;
    NSString *_symbol;
    NSString *_filter;
}

@property (nonatomic, assign) id<RCHKlineSocketRequestDelegate> delegate;

- (id)initWithSymbol:(NSString *)symbol filter:(NSString *)filter;
- (void)reconnect;
- (void)close;
- (void)sendMessage:(NSString *)message;

@end

@protocol RCHKlineSocketRequestDelegate <NSObject>
@optional

- (void)klineSocketDidOpen:(SRWebSocket *)webSocket;
- (void)klineSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)klineSocket:(SRWebSocket *)webSocket didReceiveNotifications:(id)result;
- (void)klineSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;

@end
