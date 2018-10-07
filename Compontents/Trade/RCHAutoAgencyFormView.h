//
//  RCHAutoAgencyFormView.h
//  richcore
//
//  Created by WangDong on 2018/6/19.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHAutoAgency.h"

@interface RCHAutoAgencyFormView : UIView

@property (nonatomic, copy) void (^showNotice)(void);
@property (nonatomic, strong) UIButton *submitButton;

- (id)initWithFrame:(CGRect)frame onSubmit:(void (^)(RCHAutoAgency *, UIButton *))onSubmit;
- (void)reloadWithAgency:(RCHAutoAgency *)agency;
- (void)setWallets:(NSArray *)wallets;
- (void)setPrice:(NSDecimalNumber *)price;

@end
