//
//  RCHAutoAgency.h
//  richcore
//
//  Created by WangDong on 2018/6/19.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHAutoAgency: NSObject

@property (nonatomic, assign) RCHAgencyType type;
@property (nonatomic, strong) RCHMarket *market;
@property (nonatomic, assign) RCHAgencyAim aim;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic, strong) NSDecimalNumber *miniPrice;
@property (nonatomic, strong) NSDecimalNumber *maxPrice;
@property (nonatomic, strong) NSDecimalNumber *buyPrice;
@property (nonatomic, strong) NSDecimalNumber *sellPrice;
@property (nonatomic, strong) NSDecimalNumber *stepPrice;
@property (nonatomic, strong) NSDecimalNumber *amount;

- (id)initWithType:(RCHAgencyType)type market:(RCHMarket *)market aim:(RCHAgencyAim)aim stepPrice:(NSDecimalNumber *)stepPrice;
- (BOOL)valid;
- (void)resetPriceRange;
- (NSDecimalNumber *)total;
- (NSDecimalNumber *)priceCNY;
- (NSDecimalNumber *)price_CNY:(NSDecimalNumber *)price;
- (NSDecimalNumber *)price_mini;
- (NSDecimalNumber *)price_max;
- (NSString *)dtype;
- (NSDictionary *)dispose;

@end
