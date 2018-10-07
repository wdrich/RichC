//
//  RCHAuthContrroller.h
//  MeiBe
//
//  Created by WangDong on 2018/3/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHBaseViewController.h"
#import "RCHSecondAuthController.h"

@interface RCHAuthContrroller : RCHBaseViewController

- (instancetype)initWithCompletion:( void (^ _Nonnull )(RCHSecondAuth, NSString *))completion;

@end
