//
//  RCHMarket.h
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHCoin.h"
#import "RCHState.h"
#import "RCHMineral.h"

@interface RCHMarket : NSObject
{
    RCHState *_state;
}

@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) NSNumber *min_price;
@property (nonatomic, strong) NSNumber *max_price;
@property (nonatomic, strong) NSNumber *price_step;
@property (nonatomic, strong) NSNumber *min_amount;
@property (nonatomic, strong) NSNumber *max_amount;
@property (nonatomic, strong) NSNumber *amount_step;
@property (nonatomic, strong) NSNumber *min_total;
@property (nonatomic, strong) RCHCoin *coin;
@property (nonatomic, strong) RCHCoin *currency;
@property (nonatomic, strong) RCHState *state;
@property (nonatomic, strong) NSArray *minerals;
@property (nonatomic, assign) BOOL is_auction;
@property (nonatomic, assign) BOOL is_auctioning;
@property (nonatomic, assign) NSInteger auction_stage;

- (NSUInteger)priceScale;
- (NSUInteger)amountScale;
- (BOOL)isMining;
- (BOOL)isSecondary;
- (RCHCoin *)sector;

@end
