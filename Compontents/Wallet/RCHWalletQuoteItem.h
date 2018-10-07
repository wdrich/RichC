//
//  RCHWalletQuoteItem.h
//  richcore
//
//  Created by WangDong on 2018/6/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCHWalletQuoteItem : UIView

@property (nonatomic, strong) RCHMarket *market;
@property (nonatomic, strong) UIColor *coinLabelColor;
@property (nonatomic, strong) UIFont *coinLabelFont;
@property (nonatomic, strong) UIColor *cnyColor;
@property (nonatomic, strong) UIFont *cnyFont;
@property (nonatomic, strong) UIColor *priceColor;
@property (nonatomic, strong) UIFont *priceFont;
@property (nonatomic, strong) UIColor *changeayColor;
@property (nonatomic, strong) UIFont *changeayFont;
@property (nonatomic, assign) NSTextAlignment coinLabelAlignment;
@property (nonatomic, assign) NSTextAlignment cnyAlignment;
@property (nonatomic, assign) NSTextAlignment priceAlignment;
@property (nonatomic, assign) NSTextAlignment changeayAlignment;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) CGFloat originx;
@property (nonatomic, assign) CGFloat originy;
@property (nonatomic, assign) CGFloat spacex;
@property (nonatomic, assign) CGFloat spacey;

+ (id)itemViewWithFrame:(CGRect)frame market:(RCHMarket *)market;
- (id)initWithFrame:(CGRect)frame market:(RCHMarket *)market;

@end
