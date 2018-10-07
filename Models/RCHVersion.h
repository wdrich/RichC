//
//  RCHVersion.h
//  richcore
//
//  Created by WangDong on 2018/5/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHVersion : NSObject

@property (nonatomic, copy) NSString *version;  //服务器当前版本号
@property (nonatomic, copy) NSString *downloadUrl; //新版本更新地址
@property (nonatomic, copy) NSString *updateInfo; //新版本更新详情
@property (nonatomic, copy) NSString *upgradeVersion; //强制升级的最低版本
@property (nonatomic, assign) BOOL isMustUpdate; //强制升级的最低版本

@end
