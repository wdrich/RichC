//
//  RCHUrls.h
//  richcore
//
//  Created by WangDong on 2018/5/8.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#ifndef RCHUrls_h
#define RCHUrls_h

#define     kRichcoreAPIURLDomain               @"www.richcore.com"

//Richcore API
#define     kRichcoreAPIPrefixV1                [NSString stringWithFormat:@"https://%@/api/v1",kRichcoreAPIURLDomain]                  //1版本API前缀
#define     kRichcoreRegisterUrl                [NSString stringWithFormat:@"%@/register",kRichcoreAPIPrefixV1]                         //注册
#define     kRichcoreLoginUrl                   [NSString stringWithFormat:@"%@/login",kRichcoreAPIPrefixV1]                            //登陆
#define     kRichcoreLogoutUrl                  [NSString stringWithFormat:@"%@/logout",kRichcoreAPIPrefixV1]                           //登出
#define     kRichcoreMemberUrl                  [NSString stringWithFormat:@"%@/member",kRichcoreAPIPrefixV1]                           //用户信息
#define     kCountryUrl                         [NSString stringWithFormat:@"%@/countries",kRichcoreAPIPrefixV1]                        //获取国家信息
#define     kRichcoreWalletsUrl                 [NSString stringWithFormat:@"%@/wallets",kRichcoreAPIPrefixV1]                          //钱包接口
#define     kRichcoreSharesUrl                  [NSString stringWithFormat:@"%@/shares",kRichcoreAPIPrefixV1]  
#define     kRichcoreAgenciesUrl                [NSString stringWithFormat:@"%@/agencies",kRichcoreAPIPrefixV1]                         //交易接口
#define     kRichcoreMarketsUrl                 [NSString stringWithFormat:@"%@/markets",kRichcoreAPIPrefixV1]                          //交易对详情
#define     kRichcoreWithdrawUrl                [NSString stringWithFormat:@"%@/withdraws",kRichcoreAPIPrefixV1]                        //提币记录
#define     kRichcoreFlowUrl                    [NSString stringWithFormat:@"%@/wallets_flow",kRichcoreAPIPrefixV1]                     //充值记录
#define     kRichcoreSecurityCodeUrl            [NSString stringWithFormat:@"%@/verify",kRichcoreAPIPrefixV1]                           //验证码邮件
#define     kRichcoreInviteUrl                  [NSString stringWithFormat:@"%@/brokerage_record",kRichcoreAPIPrefixV1]                 //奖励记录
#define     kRichcoreTradingviewUrl             [NSString stringWithFormat:@"%@/tradingview",kRichcoreAPIPrefixV1]                      //K线历史数据
#define     kRichcoreInviteInfoUrl              [NSString stringWithFormat:@"%@/brokerage_info",kRichcoreAPIPrefixV1]                   //奖励记录详情
#define     kRichcoreGoogleAuthUrl              [NSString stringWithFormat:@"%@/member/google",kRichcoreAPIPrefixV1]                    //谷歌验证
#define     kRichcoreRatesAuthUrl               [NSString stringWithFormat:@"%@/rates",kRichcoreAPIPrefixV1]                     //谷歌验证
#define     kRichcoreBindUrl                    [NSString stringWithFormat:@"%@/member/bind/phone",kRichcoreAPIPrefixV1]                //绑定手机
#define     kRichcoreUnBindUrl                  [NSString stringWithFormat:@"%@/member/phone/unbind",kRichcoreAPIPrefixV1]              //解绑手机
#define     kRichcoreVerifyPhoneUrl             [NSString stringWithFormat:@"%@/member/phone/code", kRichcoreAPIPrefixV1]
#define     kRichcoreVerifyEmailUrl             [NSString stringWithFormat:@"%@/member/email/code", kRichcoreAPIPrefixV1]
#define     kRichcoreForgetUrl                  [NSString stringWithFormat:@"%@/forget", kRichcoreAPIPrefixV1]                          //忘记密码
#define     kRichcoreStatesUrl                  @"wss://www.richcore.com/subscribe"                                                     //交易对列表websocket
#define     kRichcoreKlineUrl                   @"wss://www.richcore.com/stream"                                                        //kline websocket
#define     kWithdrawalHelpUrl                  @"http://www.meiaoju.com/m/withdraw/"                                                   //提现帮助
#define     kRegisterHelpUrl                    @"https://www.richcore.com/m/about/terms"                                               //注册协议
#define     kPrivacyUrl                         @"https://www.richcore.com/m/about/privacy"                                             //隐私协议

#define     kSoftwareUpdateUrl                  [NSString stringWithFormat:@"http://112.124.20.226:9100/software/profile"]              //版本升级

//网站主部署的用于验证登录的接口 (api_1)
#define api_1 @"https://www.richcore.com/api/v1/geetest/captcha?_format=json&client_type=web"
//网站主部署的二次验证的接口 (api_2)
#define api_2 @"https://www.richcore.com/api/v1/geetest/captcha?_format=json&client_type=web"


#endif /* RCHUrls_h */
