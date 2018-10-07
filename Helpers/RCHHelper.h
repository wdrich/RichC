//
//  MCHelper.h
//  uber
//
//  Created by WangDong on 2018/1/21.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

#import "RCHMember.h"

@interface RCHHelper : NSObject

//存取键值对
+ (void)setValue:(id)value forKey:(NSString *)key; //将键值对存储到NSUserDefault中
+ (id)valueForKey:(NSString *)key; //从NSUserDefault中得到key对应的value

//机密信息存取
+ (void)savePassword:(NSString *)password forUserName:(NSString *)userName; //将用户密码存储到keychain中
+ (NSString *)getPasswordForUserName:(NSString *)userName; //从keychain中，根据用户名得到密码

//用户信息
+ (NSString *)getCountryCode:(NSString *)countryCode;
+ (void)saveUserInfo:(RCHMember *)member;
+ (void)emptyUserInfo;
+ (BOOL)gotoLogin;
+ (BOOL)isValidateMobile:(NSString *)mobile;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)checkPassword:(NSString*) password;
+ (BOOL)isNeedUpdate;
+ (NSString *)getRate:(NSString *)src :(NSString *)dis;

//隐藏用户名
+ (NSString *)confusedSting:(NSString *)way;//手机号码加＊

//获得retina数值 用于一像素线条绘制
+ (CGFloat)retinaFloat:(CGFloat)f;
+ (CGFloat)retinaFloatOffset:(CGFloat)f;
+ (CGFloat)getMainViewHeightExcepTopAndBottomView:(UINavigationController *)navigationController;

//倒计时按钮
+ (void)startLableTimer:(id)sender second:(NSInteger)second timer:(dispatch_source_t)timer; //启动倒计时
+ (void)startLableTimer:(id)sender second:(NSInteger)second timer:(dispatch_source_t)timer title:(NSString *)title; //启动倒计时,自定义button文字

+ (UIView *)createAccessoryViewWithImage:(UIImage *)image rotation:(UIImageOrientation)rotation;//返回cell的accessoryView，并且指定图片
+ (UIView *)createAccessoryViewWithImage:(UIImage *)image rotation:(UIImageOrientation)rotation offset:(CGFloat)offset;

+ (void)presentModalViewRootController:(UIViewController *)rootViewController toViewController:(UIViewController *)presentViewController Animated:(BOOL)animated;

//MutableAttributedString 方法
+ (NSMutableAttributedString *)getMutableAttributedStringe:(NSString *)title Font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment;
+ (NSString *)getNSDecimalString:(NSNumber *)number;
+ (NSString *)getNSDecimalString:(NSNumber *)number defaultString:(NSString *)defaultString;
+ (NSString *)getNSDecimalString:(NSNumber *)number defaultString:(NSString *)defaultString precision:(NSInteger)precision;
+ (NSString *)getNSDecimalString:(NSNumber *)number step:(NSNumber *)step;
+ (NSString *)getNSDecimalString:(NSNumber *)number defaultString:(NSString *)defaultString step:(NSNumber *)step;
+ (NSString *)getNSDecimalString:(NSNumber *)number defaultString:(NSString *)defaultString precision:(NSInteger)precision fractionDigitsPadded:(BOOL)isPadded;

+ (NSInteger)getPrecision:(NSNumber *)number;
+ (NSNumberFormatter *)getNumberFormatterFractionDigits:(NSInteger)FractionDigit;
+ (NSNumberFormatter *)getNumberFormatterFractionDigits:(NSInteger)FractionDigit fractionDigitsPadded:(BOOL)isPadded;
+ (NSString *)getValueWithDefaultString:(NSString *)defaultString value:(NSString *)value;

//time format
+ (NSString *)transTimeString:(NSDate *)date;
+ (NSString *)transTimeString:(NSDate *)date format:(NSString *)format;
+ (NSString *)transTimeStringFormat:(NSString *)formatString;
+ (NSString *)getStempString:(NSString *)formatString;
+ (NSString *)getTimestampFromString:(NSString *)formatString;

//NSDecimalNumber
+ (NSNumber *)sum:(NSNumber *)number1 and:(NSNumber *)number2;
+ (NSNumber *)sub:(NSNumber *)number1 and:(NSNumber *)number2;
+ (NSNumber *)mul:(NSNumber *)number1 and:(NSNumber *)number2;

//cookie相关
+ (NSMutableString *)getCookiesString; //获取cookie字符串
+ (void)makeCookies; //设置cookie
+ (void)deleteCookies; //清除cookie

//网络相关
+ (void)showRequestErrorCode:(NSInteger)statusCode url:(NSString *)url; //网络错误提示

@end
