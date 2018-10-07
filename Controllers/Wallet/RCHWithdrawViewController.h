//
//  RCHWithdrawViewController.h
//  richcore
//
//  Created by Apple on 2018/6/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTextViewController.h"

typedef NS_ENUM(NSUInteger, RCHWithdrawPreLoadError) {
    RCHWithdrawPreLoadErrorNone,
    RCHWithdrawPreLoadErrorVerify,
    RCHWithdrawPreLoadErrorOther
};

@interface RCHWithdrawViewController : RCHTextViewController

+ (void)preLoadWithCoinCode:(NSString *)coinCode
                 onFinished:(void(^)(RCHWithdrawPreLoadError error, RCHWithdrawViewController *controller))onFinished;

@end

@interface RCHWithdrawDenyAlert : UIView

+ (void)showInView:(UIView *)view content:(NSString *)content;

@end
