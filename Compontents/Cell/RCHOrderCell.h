//
//  RCHOrderCell.h
//  richcore
//
//  Created by WangDong on 2018/7/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHOrder.h"

@protocol RCHOrderCellDelegate;

@interface RCHOrderCell : UITableViewCell
@property (nonatomic, strong) RCHOrder *order;
@property (nonatomic, assign) BOOL showCoin;
@property (nonatomic, assign) CGFloat originX;
@property (nonatomic, assign) CGFloat separatorX;
@property(nonatomic, assign) NSObject<RCHOrderCellDelegate> *delegate;

- (void)reload;

@end


@protocol RCHOrderCellDelegate <NSObject>
@optional

- (void)RCHOrderCell:(RCHOrderCell *)cell order:(RCHOrder *)order;

@end

