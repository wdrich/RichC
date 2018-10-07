//
//  MCHelper.m
//  uber
//
//  Created by WangDong on 2018/1/21.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "RCHHelper.h"
#import "STKeychain.h"
#import "UIImage_WD.h"

#define SINGLE_LINE_LENGTH          (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)

#define kSignKeyChainPassword @"kSignKeyChainPassword"
#define kSignKeyChainPayPassword @"kSignKeyChainPayPassword"
#define kUUID @"uuid_created"
#define PI 3.1415926

@implementation RCHHelper


+ (void)setValue:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)valueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+ (void)savePassword:(NSString *)password forUserName:(NSString *)userName {
    [STKeychain storeUsername:userName
                  andPassword:password
               forServiceName:kSignKeyChainPassword
               updateExisting:YES
                        error:nil];
}

+ (NSString *)getPasswordForUserName:(NSString *)userName {
    return [STKeychain getPasswordForUsername:userName
                               andServiceName:kSignKeyChainPassword
                                        error:nil];
}

+ (NSString *)getCountryCode:(NSString *)countryCode
{
    NSString *defaultString = @"+86";
    if (!RCHIsEmpty(countryCode)) {
        NSString * regExpStr = @"[1-9]+";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExpStr options:0 error:NULL];
        
        NSMutableString *result = [NSMutableString string];
        [result appendString:@"+"];
        NSRange range = [regex rangeOfFirstMatchInString:countryCode options:0 range:NSMakeRange(0, countryCode.length)];
        NSString *code = [countryCode substringWithRange:(NSRange){range.location, countryCode.length - range.location}];
        
        if (code) {
            [result appendString:code];
            return result;
        } else {
            return defaultString;
        }
    } else {
        return defaultString;
    }
}

+ (void)saveUserInfo:(RCHMember *)member
{
    [RCHHelper setValue:[NSNumber numberWithInteger:member.member_id] forKey:kCurrentUserId];
    [RCHHelper setValue:[NSNumber numberWithInteger:member.grade] forKey:kCurrentUserGrade];
    [RCHHelper setValue:[NSNumber numberWithBool:member.google_auth] forKey:kCurrentUserGoogleAuth];
    [RCHHelper setValue:member.email_raw forKey:kCurrentUserName];
    [RCHHelper setValue:member.email_raw forKey:kCurrentRememberName];
    [RCHHelper setValue:member.email_raw forKey:kCurrentUserEmail];
    [RCHHelper setValue:member.email forKey:kCurrentHideEmail];
    [RCHHelper setValue:member.mobile_raw forKey:kCurrentUserMobile];
    [RCHHelper setValue:member.mobile forKey:kCurrentHideMobile];
    [RCHHelper setValue:member.roles forKey:kCurrentUserRoles];
    [RCHHelper setValue:[member.mobile_country objectForKey:@"code"] forKey:kCurrentMobileCode];
    
    [RCHHelper setValue:member.security_level forKey:kCurrentUserSecurityLevel];
    [RCHHelper setValue:[NSNumber numberWithInteger:[[member.country objectForKey:@"id"] integerValue]] forKey:kCurrentCountyId];
    [RCHHelper setValue:[member.country objectForKey:@"code"] forKey:kCurrentCountyCode];
    [RCHHelper setValue:[member.country objectForKey:@"name_cn"] forKey:kCurrentCountyNameCN];
    [RCHHelper setValue:[member.country objectForKey:@"name_en"] forKey:kCurrentCountyNameEN];
    
    if ([RCHHelper valueForKey:kCurrentUserEmail]) {
        [Appsee setUserID:[RCHHelper valueForKey:kCurrentUserEmail]];
    }
    
}


+ (void)emptyUserInfo
{
    [RCHHelper savePassword:nil forUserName:kCurrentUserName];
    [RCHHelper setValue:nil forKey:kCurrentUserName];
    [RCHHelper setValue:[NSNumber numberWithInteger:0] forKey:kCurrentUserId];
    [RCHHelper setValue:[NSNumber numberWithInteger:0] forKey:kCurrentUserGrade];
    [RCHHelper setValue:[NSNumber numberWithInteger:0] forKey:kCurrentCountyId];
    [RCHHelper setValue:[NSNumber numberWithInteger:0] forKey:kCurrentGoogleLoginId];
    [RCHHelper setValue:[NSNumber numberWithBool:NO] forKey:kCurrentUserGoogleAuth];
    
    [RCHHelper setValue:nil forKey:kCurrentUserMobile];
    [RCHHelper setValue:nil forKey:kCurrentHideMobile];
    [RCHHelper setValue:nil forKey:kCurrentMobileCode];
    
    [RCHHelper setValue:nil forKey:kCurrentUserSecurityLevel];
    [RCHHelper setValue:nil forKey:kCurrentAuthType];
    [RCHHelper setValue:nil forKey:kCurrentCookie];
    [RCHHelper setValue:nil forKey:kCurrentCountyCode];
    [RCHHelper setValue:nil forKey:kCurrentUserRoles];
    [RCHHelper setValue:nil forKey:kCurrentCountyNameCN];
    [RCHHelper setValue:nil forKey:kCurrentCountyNameEN];
    [RCHHelper setValue:@"" forKey:kCurrentToken];
    [RCHHelper setValue:@"" forKey:kCurrentDeviceId];
    [RCHHelper setValue:[NSNumber numberWithInteger:10] forKey:kCurrentInterval];
    [RCHHelper setValue:@"" forKey:kCurrentUserEmail];
    [RCHHelper deleteCookies];
    
    UITabBarController *tabbarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    for (UIViewController *controller in tabbarController.viewControllers) {
        controller.tabBarItem.badgeValue = nil;
    }
    
    NSLog(@"empty userinfo successful!");
}

+ (BOOL)gotoLogin
{
    if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
        return NO;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGotoLoginNotification object:nil];
        return YES;
    }
}

+ (BOOL)isValidateMobile:(NSString *)mobile
{
    //手机号以13、15、18开头，八个\d数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
    
}

+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


+ (BOOL)checkPassword:(NSString*) password
{
    NSString*pattern =@"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,50}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

+ (BOOL)isNeedUpdate;
{
    NSDecimalNumber *current_version = [NSDecimalNumber decimalNumberWithString:[RCHHelper valueForKey:kCurrentVersion]];
    NSDecimalNumber *next_version = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[RCHHelper valueForKey:kNextVersion]]];
    if ([current_version compare:next_version] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+ (NSString *)getRate:(NSString *)src :(NSString *)dis
{
    NSString *rate;
    NSData *data = [NSData dataWithContentsOfFile:kRageFilePath];//获取指定路径的data文件
    if (!data) {
        return nil;
    }
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]; //获取到json文件的跟数据
    rate = [RCHHelper findRsc:src dis:dis in:results rate:@"1"];
    return rate;
}

+ (NSString *)findRsc:(NSString *)src dis:(NSString *)dis in:(NSArray *)coins rate:(NSString *)rate
{
    NSString *currentRate = nil;
    if (!rate) {
        return currentRate;
    }
    NSMutableArray *newCoins = [NSMutableArray array];
    if (coins.count) {
        if ([src isEqualToString:dis]) {
            currentRate = [NSString stringWithFormat:@"%@", [RCHHelper mul:[NSNumber numberWithString:@"1"] and:[NSNumber numberWithString:rate]]];
        }
        
        if (!currentRate) {
            for (NSArray *r in coins) {
                if ([r count] > 3 && ([[r objectAtIndex:0] isEqualToString:src] || [[r objectAtIndex:1] isEqualToString:src])) {
                    if ([[r objectAtIndex:1] isEqualToString:dis]) {
                        currentRate = [NSString stringWithFormat:@"%@", [RCHHelper mul:[NSNumber numberWithString:[r objectAtIndex:2]] and:[NSNumber numberWithString:rate]]];
                        break;
                    } else if ([[r objectAtIndex:0] isEqualToString:dis]) {
                        currentRate = [NSString stringWithFormat:@"%@", [RCHHelper div:[NSNumber numberWithString:rate] and:[NSNumber numberWithString:[r objectAtIndex:2]]]];
                        break;
                    } else {
                        [newCoins addObject:r];
                    }
                }
            }
        }
        
        newCoins = [newCoins valueForKeyPath:@"@distinctUnionOfObjects.self"]; //数组去重
        if (!currentRate) {
            for (NSArray *n in newCoins) {
                NSString *ca;
                ca = [NSString stringWithFormat:@"%@", [RCHHelper mul:[NSNumber numberWithString:[n objectAtIndex:2]] and:[NSNumber numberWithString:rate]]];
                
                if ([[n objectAtIndex:1] isEqualToString:src]) {
                    //防止多个相同换算对 进入循环
                    continue;
                } else {
                    currentRate = [NSString stringWithFormat:@"%@", [RCHHelper findRsc:[n objectAtIndex:1] dis:dis in:coins rate:ca]];
                }
                
                if (currentRate) {
                    break;
                }
                
            }
        } else {
            return currentRate;
        }
    }
    return currentRate;
}


+ (CGFloat)retinaFloat:(CGFloat)f
{
    CGFloat rf = f;
    rf = SINGLE_LINE_LENGTH;
    return rf;
}

+ (CGFloat)retinaFloatOffset:(CGFloat)f
{
    if (((NSInteger)f % 2) == 1) {
        CGFloat rf = f;
        rf = SINGLE_LINE_ADJUST_OFFSET;
        return rf;
    } else {
        return 0.0f;
    }
}

+ (CGFloat)getMainViewHeightExcepTopAndBottomView:(UINavigationController *)navigationController
{
    if (navigationController.viewControllers.count > 1) {
        return kMainScreenHeight - kAppOriginY;
    } else {
        return kMainScreenHeight - kAppOriginY - kTabBarHeight;
    }
}

+ (NSString *)confusedSting:(NSString *)way
{
    if ([way length] <= 7) {
        return way;
    }
    
    NSString *result;
    if ([way containsString:@"@"]) {
        NSArray *array = [way componentsSeparatedByString:@"@"];
        NSString *sub1;
        NSString *sub2;
        if ([array count] >= 2) {
            sub1 = [array objectAtIndex:0];
            sub2 = [array objectAtIndex:1];
            result = [sub1 confusedOnlyFirstLetterUnit:@"*" confusedLength:4];
            
            return [NSString stringWithFormat:@"%@@%@", result, sub2];
        } else {
            result = [way confusedOnlyFirstLetterUnit:@"*" confusedLength:4];
            return result;
        }
    } else {
        if ([way length] <7) {
            return way;
        } else {
            return [way stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        }
    }
}

+ (void)startLableTimer:(id)sender second:(NSInteger)second timer:(dispatch_source_t)timer
{
    [RCHHelper startLableTimer:sender second:second timer:timer title:@"发验证码"];
}

+ (void)startLableTimer:(id)sender second:(NSInteger)second timer:(dispatch_source_t)timer title:(NSString *)title
{
    __block NSInteger timeout = second; //倒计时时间
    UIButton *button = (UIButton *)sender;
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [button setTitle:title forState:UIControlStateNormal];
                button.userInteractionEnabled = YES;
                [button setEnabled:YES];
                //                button.backgroundColor = kBottomGrayColor;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                NSLog(@"____%@",strTime);
                [button setTitle:[NSString stringWithFormat:@"%@秒",strTime] forState:UIControlStateNormal];
                button.userInteractionEnabled = NO;
                //                button.backgroundColor = kFontLightGrayColor;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(timer);
}


+ (UIView *)createAccessoryViewWithImage:(UIImage *)image rotation:(UIImageOrientation)rotation
{
    return [RCHHelper createAccessoryViewWithImage:image rotation:rotation offset:10.0f];
}

+ (UIView *)createAccessoryViewWithImage:(UIImage *)image rotation:(UIImageOrientation)rotation offset:(CGFloat)offset
{
    UIImage *arrowImage = [UIImage image:image rotation:rotation];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[arrowImage stretchableImageWithLeftCapWidth:(arrowImage.size.width - 1) topCapHeight:arrowImage.size.width / 2]];
    arrowImageView.frame = CGRectMake(0, 0, arrowImage.size.width + offset, arrowImage.size.height);
    return arrowImageView;
}

+ (void)presentModalViewRootController:(UIViewController *)rootViewController toViewController:(UIViewController *)presentViewController Animated:(BOOL)animated {
    if ([rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [rootViewController  presentViewController:presentViewController animated:animated completion:nil];
    }
}

//time format

+ (NSString *)transTimeString:(NSDate *)date
{
    return [RCHHelper transTimeString:date format:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *)transTimeString:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = format;
    return [fmt stringFromDate:date];
}

+ (NSString *)transTimeStringFormat:(NSString *)formatString
{
    return [[NSDate dateWithISOFormatString:formatString] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *)getStempString:(NSString *)formatString
{
    return [[NSDate dateWithISOFormatString:formatString] stringWithFormat:@"MM-dd HH:mm:ss"];
}


+ (NSString *)getTimestampFromString:(NSString *)formatString
{
    // 转换为时间戳
    NSDate* date = [NSDate dateWithISOFormatString:formatString];
    NSString *stemp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return stemp;
}


//NSDecimalNumber

+ (NSNumber *)sum:(NSNumber *)number1 and:(NSNumber *)number2
{
    NSDecimalNumber *decimaNumber1;
    if (number1) {
        decimaNumber1 = [NSDecimalNumber decimalNumberWithDecimal:[number1 decimalValue]];
    } else {
        decimaNumber1 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber *decimaNumber2;
    if (number2) {
        decimaNumber2 = [NSDecimalNumber decimalNumberWithDecimal:[number2 decimalValue]];
    } else {
        decimaNumber2 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber *sum = [decimaNumber1 decimalNumberByAdding:decimaNumber2];
    
    return sum;
}

+ (NSNumber *)sub:(NSNumber *)number1 and:(NSNumber *)number2
{
    NSDecimalNumber *decimaNumber1;
    if (number1) {
        decimaNumber1 = [NSDecimalNumber decimalNumberWithDecimal:[number1 decimalValue]];
    } else {
        decimaNumber1 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber *decimaNumber2;
    if (number2) {
        decimaNumber2 = [NSDecimalNumber decimalNumberWithDecimal:[number2 decimalValue]];
    } else {
        decimaNumber2 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber *sub = [decimaNumber1 decimalNumberBySubtracting:decimaNumber2];
    
    return sub;
}

+ (NSNumber *)mul:(NSNumber *)number1 and:(NSNumber *)number2
{
    NSDecimalNumber *decimaNumber1;
    if (number1) {
        decimaNumber1 = [NSDecimalNumber decimalNumberWithDecimal:[number1 decimalValue]];
    } else {
        decimaNumber1 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber *decimaNumber2;
    if (number2) {
        decimaNumber2 = [NSDecimalNumber decimalNumberWithDecimal:[number2 decimalValue]];
    } else {
        decimaNumber2 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber *mul = [decimaNumber1 decimalNumberByMultiplyingBy:decimaNumber2];
    
    return mul;
}

+ (NSNumber *)div:(NSNumber *)number1 and:(NSNumber *)number2
{
    NSDecimalNumber *decimaNumber1;
    if (number1) {
        decimaNumber1 = [NSDecimalNumber decimalNumberWithDecimal:[number1 decimalValue]];
    } else {
        decimaNumber1 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber *decimaNumber2;
    if (number2) {
        decimaNumber2 = [NSDecimalNumber decimalNumberWithDecimal:[number2 decimalValue]];
    } else {
        return [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber *mul = [decimaNumber1 decimalNumberByDividingBy:decimaNumber2];
    
    return mul;
}


#pragma mark - MutableAttributedString Function
//MutableAttributedString 方法

+ (NSMutableAttributedString *)getMutableAttributedStringe:(NSString *)title Font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment
{
    if (!title) {
        title = @"0";
    }
    
    if (!font) {
        font = [UIFont systemFontOfSize:13.0f];
    }
    
    if (!color) {
        color = [UIColor whiteColor];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:1];
    [paragraphStyle setAlignment:alignment];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [title length])];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [title length])];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [title length])];;
    return attributedString;
}

+ (NSString *)getNSDecimalString:(NSNumber *)number
{
    return  [RCHHelper getNSDecimalString:number defaultString:@"--"];
}


+ (NSString *)getNSDecimalString:(NSNumber *)number defaultString:(NSString *)defaultString
{
    NSInteger precision = [RCHHelper getPrecision:number];
    return  [RCHHelper getNSDecimalString:number defaultString:defaultString precision:precision];
}

+ (NSString *)getNSDecimalString:(NSNumber *)number step:(NSNumber *)step
{
    return [RCHHelper getNSDecimalString:number defaultString:@"--" step:step];
}

+ (NSString *)getNSDecimalString:(NSNumber *)number defaultString:(NSString *)defaultString step:(NSNumber *)step
{
    NSInteger precision = [RCHHelper getPrecision:step];
    return [RCHHelper getNSDecimalString:number defaultString:defaultString precision:precision];
}

+ (NSString *)getNSDecimalString:(NSNumber *)number defaultString:(NSString *)defaultString precision:(NSInteger)precision
{
    return [RCHHelper getNSDecimalString:number defaultString:defaultString precision:precision fractionDigitsPadded:NO];
}

+ (NSString *)getNSDecimalString:(NSNumber *)number defaultString:(NSString *)defaultString precision:(NSInteger)precision fractionDigitsPadded:(BOOL)isPadded
{
    NSNumberFormatter *format = [RCHHelper getNumberFormatterFractionDigits:precision fractionDigitsPadded:isPadded];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    if ([decimalNumber compare:[NSDecimalNumber notANumber]] == NSOrderedSame || RCHIsEmpty(number)) {
        return defaultString;
    }
     NSString *result = [format stringFromNumber:number];
    return result;
}

+ (NSInteger)getPrecision:(NSNumber *)number
{
    NSInteger precision = 0;
    if ([number compare:[NSDecimalNumber notANumber]] == NSOrderedSame || [number compare:[NSDecimalNumber zero]] == NSOrderedSame) {
        return precision;
    }
    NSDecimalNumber *step = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    NSDecimalNumber *unit = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];

    while ([step compare:[NSDecimalNumber one]] == NSOrderedAscending) { //大于等于1 则退出循环
        step = [step decimalNumberByMultiplyingBy:unit];
        precision += 1;
    }
    return precision;
}

//+ (NSInteger)getPrecision:(NSNumber *)number
//{
//    NSInteger precision = 3;
//    NSDecimalNumber *decimaNumber = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
//    if ([decimaNumber compare:[NSDecimalNumber one]] == NSOrderedAscending) { //生序排序 比1小
//        precision = 8;
//    }
//    return precision;
//}

+ (NSNumberFormatter *)getNumberFormatterFractionDigits:(NSInteger)FractionDigit
{
    return  [RCHHelper getNumberFormatterFractionDigits:FractionDigit fractionDigitsPadded:NO];
}

+ (NSNumberFormatter *)getNumberFormatterFractionDigits:(NSInteger)FractionDigit fractionDigitsPadded:(BOOL)isPadded
{
    if (FractionDigit > 8) {
        FractionDigit = 8;
    }
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    [format setPositiveFormat:@"####.##"];
    [format setMaximumFractionDigits:FractionDigit];
    if (isPadded) {
        //不足的位置补齐
        [format setMinimumFractionDigits:FractionDigit];
    }
    return format;
}

+ (NSString *)getValueWithDefaultString:(NSString *)defaultString value:(NSString *)value
{
    if (!value) {
        return defaultString;
    } else {
        return value;
    }
}


//cookie相关

//获取cookie字符串
+ (NSMutableString *)getCookiesString
{
    NSMutableString *cookieValue = [NSMutableString string];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", cookie.name, cookie.value];
        [cookieValue appendString:appendString];
    }
    return cookieValue;
}

//设置cookie
+ (void)makeCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        if ([cookie.name isEqualToString:@"richcore_user"]) {
            return;
        }
    }
    
    NSString *value = [RCHHelper valueForKey:kCurrentCookie];
    if (!value) {
        return;
    }
    
    NSMutableDictionary *fromappDict = [NSMutableDictionary dictionary];
    [fromappDict setObject:@"richcore_user" forKey:NSHTTPCookieName];
    [fromappDict setObject:value forKey:NSHTTPCookieValue];
    [fromappDict setObject:@"www.richcore.com" forKey:NSHTTPCookieDomain];
    [fromappDict setObject:@"/" forKey:NSHTTPCookiePath];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:fromappDict];
    [cookieStorage setCookie:cookie];
}


//清除cookie
+ (void)deleteCookies
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieAry = [cookieJar cookies];
    for (cookie in cookieAry) {
        [cookieJar deleteCookie: cookie];
    }
    
}

+ (void)showRequestErrorCode:(NSInteger)statusCode url:(NSString *)url
{
    NSLog(@"key:%ld, url:%@", statusCode ,url);
    
    if (statusCode == -999) {
        return;
    }
    if (statusCode >= 500) {
        [MBProgressHUD showError:(NSString *)kConnectionError500 ToView:[[UIApplication sharedApplication] keyWindow]];
        return;
    }
    
    if (statusCode >= 400) {
        if (statusCode == 403) {
            if ([url containsString:kRichcoreAgenciesUrl]) {
                return;
            }
            if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutDidSuccessNotification object:nil];
                return;
            }
            
        } else if (statusCode == 401) {
            [MBProgressHUD showError:(NSString *)kConnectionError401 ToView:[[UIApplication sharedApplication] keyWindow]];
            return;
        } else if (statusCode == 404) {
            [MBProgressHUD showError:(NSString *)kConnectionError404 ToView:[[UIApplication sharedApplication] keyWindow]];
            return;
        }  else {
            
        }
    }
    [MBProgressHUD showError:(NSString *)kConnectionError ToView:[[UIApplication sharedApplication] keyWindow]];
}


@end
