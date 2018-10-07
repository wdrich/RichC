//
//  MCGlobal.h
//  uber
//
//  Created by WangDong on 2018/1/21.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHMarket.h"

@interface RCHGlobal : NSObject

@property (nonatomic, strong) NSArray *marketsArray;
@property (nonatomic, strong) RCHMarket *currentMarket;
@property (nonatomic, strong) NSString *resolution; //k线图 websocket时间间隔
@property (nonatomic, assign) BOOL isPortrait;
@property (nonatomic, assign) RCHSortType marketSortType;
@property (nonatomic, assign) RCHSortTrendType marketTrendType;

+ (RCHGlobal *)sharedGlobal;

- (NSString *)defaultCurrencyCode;
- (RCHMarket *)findBySymbol:(NSString *)symbol;

@end
