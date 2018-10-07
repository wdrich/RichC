//
//  RCHTradeItem.h
//  MJLMerchantsChatServerPush
//
//  Created by WangDong on 2018/5/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCHTradeItem : UIView

@property (nonatomic, strong) NSAttributedString *price;
@property (nonatomic, strong) NSAttributedString *amount;
@property (nonatomic, strong) void (^didSelected)(NSString *price);

- (id)initWithFrame:(CGRect)frame title:(NSMutableAttributedString *)title value:(NSMutableAttributedString *)value;

@end
