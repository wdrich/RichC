//
//  RCHGoogleAuthController.h
//  MeiBe
//
//  Created by WangDong on 2018/3/7.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTextViewController.h"

typedef NS_ENUM(NSInteger, RCHGoogleAuth) {
    RCHGoogleAuthTypeDefault                = 0, //默认样式
    RCHGoogleAuthTypeBackup                 = 1, //备份密钥页面
    RCHGoogleAuthTypeGuidelines             = 2, //引导页面页面
    RCHGoogleAuthTypeInput                  = 3,  //输入密钥页面
    RCHGoogleAuthTypeSubmit                 = 4,  //提交密钥页面
    RCHGoogleAuthTypeDownload               = 5  //下载谷歌验证页面
};

@interface RCHGoogleAuthController : RCHTextViewController

@property (nonatomic, strong) NSString *backupKey;

- (id)initWithGoogleAuthType:(RCHGoogleAuth)type;

@end
