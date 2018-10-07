//
//  MCGlobal.m
//  uber
//
//  Created by WangDong on 2018/1/21.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "RCHGlobal.h"
#import "RCHState.h"

@implementation RCHGlobal

static RCHGlobal *_instance = nil;

#pragma mark singleton

+ (RCHGlobal *)sharedGlobal
{
    if(_instance == nil) {
        _instance = [[RCHGlobal alloc] init];
        _instance.resolution = @"15m";
        
        _instance.marketSortType = RCHSortTypeDefault;
        _instance.marketTrendType = RCHSortTrendTypeDecrease;
        
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:kMarketsFileDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:kMarketsFileDir
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
        }
    }
    return _instance;
}

- (id)init {
    if(self = [super init]) {
    }
    
    return self;
}

- (void)dealloc {
    self.marketsArray = nil;
}

- (void)setMarketsArray:(NSArray *)marketsArray {
    _marketsArray = marketsArray;
    
    RCHMarket *theMarket = nil;
    if (_currentMarket) {
        for (RCHMarket *market in _marketsArray) {
            if ([market.symbol isEqualToString:_currentMarket.symbol]) {
                theMarket = market;
                break;
            }
        }
    }
    self.currentMarket = theMarket ?: [self findDefaultMarket];
}

- (void)setCurrentMarket:(RCHMarket *)currentMarket {
    RCHMarket *lastMarket = _currentMarket;
    _currentMarket = currentMarket;
    if (lastMarket != _currentMarket) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentMarketChangedNotification object:nil];
        [RCHHelper setValue:_currentMarket.symbol forKey:kCurrentMarket];
    }
}

- (NSString *)defaultCurrencyCode {
    return @"USDT";
}

- (RCHMarket *)findBySymbol:(NSString *)symbol {
    if (_marketsArray == nil) return nil;
    for (RCHMarket *market in _marketsArray) {
        if ([symbol isEqualToString:market.symbol]) return market;
    }
    return nil;
}

- (RCHMarket *)findDefaultMarket
{
    if (!_marketsArray || [_marketsArray count] == 0) return nil;
    
    NSString *symbol = [RCHHelper valueForKey:kCurrentMarket];
    if (symbol) {
        for (RCHMarket *market in _marketsArray) {
            if ([market.symbol isEqualToString:symbol]) {
                return market;
            }
        }
    }
//    for (RCHMarket *market in _marketsArray) {
//        if ([market.currency.code isEqualToString:[self defaultCurrencyCode]]) {
//            return market;
//        }
//    }
    return [_marketsArray objectAtIndex:0];
}

@end
