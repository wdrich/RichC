//
//  RCHRealtimeAgencyView.h
//  richcore
//
//  Created by Apple on 2018/6/2.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DepthSide) {
    DepthSideAsk,
    DepthSideBid
};

@interface RCHRealtimeAgencyView : UIView

@property (nonatomic, strong) RCHMarket *market;

- (id)initWithFrame:(CGRect)frame onSelected:(void (^)(NSString *, DepthSide))onSelected;
- (void)refreshPrice;
- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids;


@end

@interface DepthItem : UIView <UIGestureRecognizerDelegate>
{
    DepthSide _side;
    void (^_onSelected)(NSString *, DepthSide);
    NSString *_price;
    NSString *_amount;
    CGFloat _depth;
}

- (id)initWithFrame:(CGRect)frame side:(DepthSide)side onSelected:(void (^)(NSString *, DepthSide))onSelected;
- (void)setPrice:(NSString *)price amount:(NSString *)amount depth:(CGFloat)depth;

@end
