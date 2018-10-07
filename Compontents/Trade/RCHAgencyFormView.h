//
//  RCHAgencyFormView.h
//  richcore
//
//  Created by Apple on 2018/6/2.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHWallet.h"

@interface RCHAgency: NSObject

@property (nonatomic, assign) RCHAgencyType type;
@property (nonatomic, strong) RCHMarket *market;
@property (nonatomic, assign) RCHAgencyAim aim;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic, strong) NSDecimalNumber *amount;

- (id)initWithType:(RCHAgencyType)type market:(RCHMarket *)market aim:(RCHAgencyAim)aim;
- (BOOL)valid;
- (NSDecimalNumber *)total;
- (NSDecimalNumber *)priceCNY;
- (NSString *)dtype;
- (NSDictionary *)dispose;

@end

@interface RCHAgencyFormView : UIView

- (id)initWithFrame:(CGRect)frame onSubmit:(void (^)(RCHAgency *))onSubmit;
- (void)reloadWithAgency:(RCHAgency *)agency;
- (void)setWallets:(NSArray *)wallets;
- (void)setPrice:(NSDecimalNumber *)price;
- (void)setAmount:(NSDecimalNumber *)amount;
@end
