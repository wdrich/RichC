//
//  RCHWalletQuotesView.h
//  richcore
//
//  Created by WangDong on 2018/6/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCHWalletQuotesView : UIView

@property (nonatomic, copy) void (^seleced)(RCHMarket *market);

@property (nonatomic, assign) CGFloat originx;
@property (nonatomic, assign) CGFloat originy;
@property (nonatomic, assign) CGFloat spacex;
@property (nonatomic, assign) CGFloat spacey;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) NSInteger numberOfRow;

@property (nonatomic, strong) NSArray *markets;

@end
