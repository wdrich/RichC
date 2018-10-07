//
//  RCHDevice.h
//  richcore
//
//  Created by WangDong on 2018/5/8.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#ifndef RCHDevice_h
#define RCHDevice_h

// main screen's scale
#ifndef kScreenScale
#define kScreenScale YYScreenScale()
#endif

// main screen's size (portrait)
#ifndef kScreenSize
#define kScreenSize YYScreenSize()
#endif

// main screen's width (portrait)
#ifndef kScreenWidth
#define kScreenWidth YYScreenSize().width
#endif

// main screen's height (portrait)
#ifndef kScreenHeight
#define kScreenHeight YYScreenSize().height
#endif

#define kMainScreenWidth    ([UIScreen mainScreen].bounds).size.width //应用程序的宽度
#define kMainScreenHeight   ([UIScreen mainScreen].bounds).size.height //应用程序的高度
#define kMainStatusBarHeight    [UIApplication sharedApplication].statusBarFrame.size.height //状态栏高度
#define isRetina                ([UIScreen instancesRespondToSelector:@selector(currentMode)] && [[UIScreen mainScreen] currentMode].size.width == 640)
#define is_iPhoneX          ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO) //是否是iPhone X

#define kWalletIconPath                         @"/img/coin/"
#define kRageFilePath                           PATH_AT_DOCDIR(@"/rates.json")
#define kMarketsFileDir                         PATH_AT_DOCDIR(@"/markets")
#define kTabBarHeight                           (is_iPhoneX ? 83.0f : 49.0f) //tabbar高度
#define TabbarSafeBottomMargin                  (is_iPhoneX ? 34.0f : 0.0f)
#define TabbarMiniSafeBottomMargin              (is_iPhoneX ? 19.0f : 0.0f)
#define kNavigationBarHeight                    44.0f //NavigationBar高度
#define kToolBarHeight                          44.0f //NavigationBar高度
#define kAppOriginY                             (kMainStatusBarHeight + kNavigationBarHeight) //NavigationBar高度
#define pageMenuHeight                          36.0f //切换滑动栏高度

#endif /* RCHDevice_h */
