//
//  RCHEnum.h
//  richcore
//
//  Created by WangDong on 2018/7/3.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#ifndef RCHEnum_h
#define RCHEnum_h

typedef NS_ENUM(NSUInteger, RCHAgencyAim) {
    RCHAgencyAimBuy,
    RCHAgencyAimSell,
    RCHAgencyAimAuto
};

typedef NS_ENUM(NSUInteger, RCHAgencyType) {
    RCHAgencyTypeLimit,
    RCHAgencyTypeMarket
};

typedef NS_ENUM(NSUInteger, RCHSortType) {
    RCHSortTypeDefault,
    RCHSortTypeName,
    RCHSortTypeVolume,
    RCHSortTypePrice,
    RCHSortTypeChange
};

typedef NS_ENUM(NSUInteger, RCHSortTrendType) {
    RCHSortTrendTypeIncrease,
    RCHSortTrendTypeDecrease
};

#endif /* RCHEnum_h */
