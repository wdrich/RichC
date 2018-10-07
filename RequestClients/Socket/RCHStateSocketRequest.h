//
//  RCHStateSocketRequest.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@protocol RCHStateSocketRequestDelegate;

@interface RCHStateSocketRequest : NSObject <SRWebSocketDelegate>
{
    SRWebSocket *_webSocket;
    NSTimer *_timer;
    BOOL _isReconnect;
    NSString *_symbol;
}

@property (nonatomic, assign) id<RCHStateSocketRequestDelegate> delegate;

- (id)initWithSymbol:(NSString *)symbol;
- (void)reconnect;
- (void)close;
- (void)sendMessage:(NSString *)message;

@end

    @protocol RCHStateSocketRequestDelegate <NSObject>
@optional

- (void)keepAliveSocketDidOpen:(SRWebSocket *)webSocket;
- (void)keepAliveSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)keepAliveSocket:(SRWebSocket *)webSocket didReceiveNotifications:(id)result event:(NSString *)event;
- (void)keepAliveSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;

@end
