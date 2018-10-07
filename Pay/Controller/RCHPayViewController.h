//
//  RCHPayViewController.h
//  richcore
//
//  Created by Apple on 2018/5/15.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHPayReq.h"
#import "RCHPayInfo.h"

@interface RCHPayViewController : UIViewController

- (instancetype)initWithReq:(RCHPayReq *)req
                    payInfo:(RCHPayInfo *)payInfo
                   onSubmit:(void (^)(NSString *, void (^)(NSString *)))onSubmit
                    onClose:(void (^)(void))onClose;

@end
