//
//  RCHNotifications.h
//  richcore
//
//  Created by WangDong on 2018/5/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#ifndef RCHNotifications_h
#define RCHNotifications_h

#define kRegisterDidSuccessNotification         @"kRegisterDidSuccessNotification" //用户注册成功发送消息通知
#define kLoginDidSuccessNotification            @"kLoginDidSuccessNotification" //用户登录成功发送消息通知
#define kGetRichcoreMemberNotification          @"kGetRichcoreMemberNotification" //用户自动登录
#define kLogoutDidSuccessNotification           @"kLogoutDidSuccessNotification" //用户登出成功发送消息通知
#define kGotoLoginNotification                  @"kGotoLoginNotification" //弹出登录界面

#define kAutoUpdateNotification                 @"kAutoUpdateNotification" // 自动检查更新
#define kManualUpdateNotification               @"kManualUpdateNotification" // 手动检查更新
#define kGetMemverNotification                  @"kGetMemverNotification" // 获取用户信息

#define kGetMarketsNotification                 @"kGetMarketsNotification" // 获取交易对信息
#define kStopMarketsNotification                @"kStopMarketsNotification" // 停止获取交易对信息
#define kGetMarketsSuccessNotification          @"kGetMarketsSuccessNotification" // 获取交易对信息成功
#define kGetMarketsFailedNotification           @"kGetMarketsFailedNotification" // 获取交易对信息失败
#define kAgencyAimNotification                  @"kAgencyAimNotification" // 交易对买卖类型

#define kStartWebsocketeNotification            @"kStartWebsocketeNotification" // 开始websocket
#define kStopWebsocketeNotification             @"kStopWebsocketeNotification" // 停止websocket
#define kReconnectWebsocketeNotification        @"kReconnectWebsocketeNotification" // 重新建立 websocket

#define kStartKlineWebsocketeNotification       @"kStartKlineWebsocketeNotification" // 开始Kline websocket
#define kStopKlineWebsocketeNotification        @"kStopKlineWebsocketeNotification" // 停止Kline websocket
#define kReceiveKlineMessageNotification        @"kReceiveKlineMessageNotification" //接收到kline更新的数据
#define kChangeResolutionChangedNotification    @"kChangeResolutionChangedNotification" //切换kline websocket 时间间隔


#define kCurrentMarketChangedNotification       @"kCurrentMarketChangedNotification"
#define kTickerUpdatedNotification              @"kTickerUpdatedNotification"
#define kReceiveMessageNotification             @"kReceiveMessageNotification"

#define kReceiveCurrentOrderNotification        @"kReceiveCurrentOrderNotification" //当前订单消息

#endif /* RCHNotifications_h */
