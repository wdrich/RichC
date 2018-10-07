//
//  RCHPayVerifyViewController.h
//  richcore
//
//  Created by Apple on 2018/6/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHPayInfo.h"

@interface RCHPayVerifyViewController : UIViewController

- (instancetype)initWithVerifyInfo:(RCHPayVerifyInfo *)verifyInfo
                          onSubmit:(void (^)(NSString *, void (^)(NSString *)))onSubmit
                           onClose:(void (^)(void))onClose;

@end
