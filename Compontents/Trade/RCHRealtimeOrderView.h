//
//  TradeDetailAskView.h
//  richcore
//
//  Created by WangDong on 2018/7/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DetailDepthSide) {
    DetailDepthSideAsk,
    DetailDepthSideBid
};

@interface RCHRealtimeOrderView : UIView

@property (nonatomic, strong) RCHMarket *market;

- (id)initWithFrame:(CGRect)frame side:(DetailDepthSide)side;
- (void)setItemDatas:(NSArray *)datas;
- (void)setDisplayPrecision:(NSUInteger)precision;

@end


@interface DetailDepthItem : UIView <UIGestureRecognizerDelegate>
{
    DetailDepthSide _side;
    void (^_onSelected)(NSString *, DetailDepthSide);
    NSString *_price;
    NSString *_amount;
    CGFloat _depth;
}

- (id)initWithFrame:(CGRect)frame side:(DetailDepthSide)side onSelected:(void (^)(NSString *, DetailDepthSide))onSelected;
- (void)setPrice:(NSString *)price amount:(NSString *)amount depth:(CGFloat)depth;

@end
