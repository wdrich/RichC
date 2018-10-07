//
//  RCHApp.h
//  richcore
//
//  Created by WangDong on 2018/5/8.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#ifndef RCHApp_h
#define RCHApp_h

#define kNextVersion                            @"kNextVersion" //更新后的版本号 可能和当前的版本号不一样
#define kUpgradeVersion                         @"kUpgradeVersion"//强制升级的版本号
#define kIsFirstTimeUse                         @"kIsFirstTimeUse" //软件第一次使用
#define kCanShowCreateOrderNotice               @"kCanShowCreateOrderNotice" //是否显示提示信息
#define kIsShowMineHeadImage                    @"kIsShowMineHeadImage" //是否显示自己的头像
#define kNextVersion                            @"kNextVersion" //更新后的版本号 可能和当前的版本号不一样
#define kCurrentVersion                         @"kCurrentVersion"//当前的版本号
#define kCurrentBuiltVersion                    @"kCurrentBuiltVersion"//当前的Built版本号
#define kDeviceToken                            @"kDeviceToken"// 得到的diviceToken
#define kShowBalance                            @"kShowBalance" //收否显示余额
#define kCurrentVersion                         @"kCurrentVersion"//当前的版本号
#define kNextVersion                            @"kNextVersion" //更新后的版本号 可能和当前的版本号不一样
#define kCurrentMarket                          @"kCurrentMarket" //当前市场信息
#define kCurrentTradeType                       @"kCurrentTradeType" //当前交易类型

#define defaultConttollerIndex                   1 //默认启动页
#define defaultPrecision                         8 //默认精度
#define SOFTWARE_VERSION ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"])
#define SOFTWARE_BUILT_VERSION ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"])
#define SOFTWARE_IDENTIFIER ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"])


#endif /* RCHApp_h */
