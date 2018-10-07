//
//  RCHWalletQuotesView.m
//  richcore
//
//  Created by WangDong on 2018/6/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWalletQuotesView.h"
#import "RCHWalletQuoteItem.h"

@interface RCHWalletQuotesView ()
{
}
@end

@implementation RCHWalletQuotesView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initQuoteViewItem];
        [self reloadView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void) dealloc {

}

#pragma mark -
#pragma mark - CustomFuction

- (void)initQuoteViewItem
{
    _originx = 0.0f;
    _originy = 0.0f;
    _numberOfRow = 2;
    _spacex = 10.0f;
    _spacey = 10.0f;
    
    _itemWidth = (self.width - _spacex) / _numberOfRow;
    _itemHeight = 0.0f;
}

#pragma mark -
#pragma mark - UIGestureRecognizer
- (void)selecedMarket:(UITapGestureRecognizer*)tapGesture
{
    NSInteger tag = tapGesture.view.tag;
    if (self.markets.count > tag) {
        RCHMarket *market = self.markets[tag];
        !self.seleced ?: self.seleced(market);
    }
}

#pragma mark -
#pragma mark - setter

- (void)setOriginx:(CGFloat)originx
{
    _originx = originx;
    [self layoutSubviews];
}

- (void)setOriginy:(CGFloat)originy
{
    _originy = originy;
    [self layoutSubviews];
}


- (void)setSpacex:(CGFloat)spacex
{
    _spacex = spacex;
    [self layoutSubviews];
}

- (void)setSpacey:(CGFloat)spacey
{
    _spacey = spacey;
    [self layoutSubviews];
}

- (void)setItemWidth:(CGFloat)itemWidth
{
    _itemWidth = itemWidth;
    [self layoutSubviews];
}

- (void)setItemHeight:(CGFloat)itemHeight
{
    _itemHeight = itemHeight;
    [self layoutSubviews];
}

- (void)setMarkets:(NSArray *)markets
{
    _markets = markets;
    [self reloadView];
}

- (void)setNumberOfRow:(NSInteger)numberOfRow
{
    _numberOfRow = numberOfRow;
    
    [self layoutSubviews];
}

#pragma mark -
#pragma mark - CustomFuction

- (void)reloadView
{
    if (self.markets.count == 0) {
        return;
    }
    if ([[NSDecimalNumber numberWithFloat:_itemHeight] compare:[NSDecimalNumber zero]] == NSOrderedSame) {
        NSInteger rows = (self.markets.count - 1) / _numberOfRow + 1;
        _itemHeight = (self.height - _spacey * (rows - 1) - _originy * 2) / rows;
    }
    
    NSInteger index = 0;
    for (RCHMarket *market in self.markets) {
        NSInteger col = index % _numberOfRow;
        NSInteger row = index / _numberOfRow;
        RCHWalletQuoteItem *item = [RCHWalletQuoteItem itemViewWithFrame:(CGRect){{col * (_itemWidth + _spacex) + _originx, row * (_itemHeight + _spacey) + _originy}, {_itemWidth, _itemHeight}}
                                                                  market:market];
        item.backgroundColor = kLightGreenColor;
        item.tag = index;
        [self addSubview:item];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selecedMarket:)];
        tapGesture.cancelsTouchesInView = NO;
        [item addGestureRecognizer:tapGesture];
        
        index += 1;
    }

    [self layoutSubviews];
    
}


@end
