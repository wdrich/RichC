//
//  RCHSecondAuthController.h
//  MeiBe
//
//  Created by WangDong on 2018/3/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTextViewController.h"

typedef NS_ENUM(NSInteger, RCHSecondAuth) {
    RCHSecondAuthTypeGoogle                = 0, //
    RCHSecondAuthTypeMobie                 = 1, //备份密钥页面
};

@interface RCHSecondAuthController : RCHTextViewController

- (id)initWithSecondAuthType:(RCHSecondAuth)type;
- (id)initWithSecondAuthType:(RCHSecondAuth)type completion:( void (^ _Nonnull )(RCHSecondAuth, NSString *))completion;

@end
