

#import "RCHConst.h"


NSString *const kURL_Reachability_Address = @"www.baidu.com";               //网络状态监控地址

#ifdef __RICHMALL__
NSString *const k_MAIN_URL = @"http://mall.richcore.com/";                  //网站首页地址
#elif __WINE__
NSString *const k_MAIN_URL = @"http://www.mingjiu.io/";                       //网站首页地址
#else
NSString *const k_MAIN_URL = @"http://mall.richcore.com/news/index";        //网站首页地址
#endif

NSString *const k_APPSEE_KEY = @"ae31f4783e9e4d5b9df86e6ec9a2b272";         //APPSee Key
