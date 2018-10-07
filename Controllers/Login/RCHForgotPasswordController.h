//
//  RCHForgotPasswordController.h
//  richcore
//
//  Created by WangDong on 2018/6/14.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTextViewController.h"
#import "RCHMember.h"

@interface RCHForgotPasswordController : RCHTextViewController

@property (nonatomic, strong) RCHMember *member;
@property (nonatomic, strong) void (^finished)(void);

@end
