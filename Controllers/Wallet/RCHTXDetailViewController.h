//
//  RCHTXDetailViewController.h
//  richcore
//
//  Created by Apple on 2018/6/8.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHBaseViewController.h"
#import "RCHFlow.h"
#import "RCHWallet.h"
#import "RCHWithdraw.h"

@interface RCHRecharge: NSObject

@property (nonatomic, strong) RCHFlow *flow;
@property (nonatomic, strong) RCHWallet *wallet;

+ (RCHRecharge *)rechargeWithFlow:(RCHFlow *)flow wallet:(RCHWallet *)wallet;

@end

@interface RCHTXDetailViewController : RCHBaseViewController

- (id)initWithRecharge:(RCHRecharge *)recharge;
- (id)initWithWithdraw:(RCHWithdraw *)withdraw;

@end
