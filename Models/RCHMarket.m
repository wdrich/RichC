//
//  RCHMarket.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMarket.h"

@implementation RCHMarket

@synthesize state = _state;

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.symbol = nil;
    self.min_price = nil;
    self.max_price = nil;
    self.price_step = nil;
    self.min_amount = nil;
    self.max_amount = nil;
    self.amount_step = nil;
    self.min_total = nil;
    self.coin = nil;
    self.minerals = nil;
    self.currency = nil;
    
    self.is_auction = NO;
    self.is_auctioning = NO;
    self.auction_stage = 0;
    
    _state = nil;
    
    
    return self;
}

- (void)dealloc {
    
    self.min_price = nil;
    self.max_price = nil;
    self.price_step = nil;
    self.min_amount = nil;
    self.max_amount = nil;
    self.amount_step = nil;
    self.min_total = nil;
    self.coin = nil;
    self.minerals = nil;
    self.currency = nil;
    _state = nil;
    
}

- (void)setState:(RCHState *)state {
    _state = state;
    [self saveState];
    
    if (_state) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTickerUpdatedNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:self.symbol
                                                                                               forKey:@"symbol"]];
    }
}

- (void)saveState {
    if (!_state || ![self _filePath]) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *json_data = [NSJSONSerialization dataWithJSONObject:[self->_state mj_keyValues]
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
        [json_data writeToFile:[self _filePath] atomically:YES];
    });
}

- (RCHState *)state {
    if (!_state && [self _filePath] && [[NSFileManager defaultManager] fileExistsAtPath:[self _filePath]]) {
        _state = [RCHState mj_objectWithKeyValues:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self _filePath]]
                                                                                  options:NSJSONReadingAllowFragments
                                                                                    error:nil]];
    }
    return _state;
}

- (NSString *)_filePath {
    return self.symbol ? [NSString stringWithFormat:@"%@/%@", kMarketsFileDir, self.symbol] : nil;
}

- (BOOL)isMining {
    return self.minerals && [self.minerals count] > 0;
}

- (BOOL)isSecondary {
    if (self.isMining) {
        for(RCHMineral *mineral in self.minerals) {
            if (![mineral.coin.code isEqualToString:self.coin.code] && mineral.coin.isSecondary) return YES;
        }
    }
    return NO;
}

- (RCHCoin *)sector {
    if (self.isSecondary) {
        for(RCHMineral *mineral in self.minerals) {
            if (mineral.coin.isSecondary) return mineral.coin;
        }
    }
    return self.currency;
}

- (NSUInteger)priceScale {
    if (!self.price_step) { return 8; }
    NSArray *ss = [[[RCHHelper getNumberFormatterFractionDigits:8] stringFromNumber:self.price_step] componentsSeparatedByString:@"."];
    if ([ss count] == 2) { return [[ss objectAtIndex:1] length]; }
    return 0;
}

- (NSUInteger)amountScale {
    if (!self.amount_step) { return 8; }
    NSArray *ss = [[[RCHHelper getNumberFormatterFractionDigits:8] stringFromNumber:self.amount_step] componentsSeparatedByString:@"."];
    if ([ss count] == 2) { return [[ss objectAtIndex:1] length]; }
    return 0;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"minerals":[RCHMineral class]
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{};
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[];
}


@end
