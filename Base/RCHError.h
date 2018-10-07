//
//  RCHError.h
//  richcore
//
//  Created by WangDong on 2018/5/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#ifndef RCHError_h
#define RCHError_h

#define kConnectionError    NSLocalizedString(@"网络不给力，请检查网络连接",nil)
#define kConnectionError500     NSLocalizedString(@"出错了，请稍后重试",nil)
#define kConnectionError400     NSLocalizedString(@"出错了，请稍后重试",nil)
#define kConnectionError401     NSLocalizedString(@"出错了，请稍后重试",nil)
#define kConnectionError404     NSLocalizedString(@"出错了，请稍后重试",nil)
#define kLoginError             NSLocalizedString(@"账号或密码错误",nil)
#define kVerifyCodeError        NSLocalizedString(@"验证码错误，请重新输入",nil)
#define kRangeError         NSLocalizedString(@"查看超出范围",nil)
#define kDataError          NSLocalizedString(@"请求数据出错了",nil)
#define kTimesError          NSLocalizedString(@"操作过于频繁，请稍后再试",nil)

#endif /* RCHError_h */
