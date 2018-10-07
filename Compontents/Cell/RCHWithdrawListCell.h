//
//  RCHWithdrawListCell.h
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHWithdraw.h"

@protocol RCHWithdrawCellDelegate;

@interface RCHWithdrawListCell : UITableViewCell

@property (nonatomic, strong) RCHWithdraw *withdraw;
@property(nonatomic, assign) NSObject<RCHWithdrawCellDelegate> *delegate;

- (void)reload;

@end


@protocol RCHWithdrawCellDelegate <NSObject>
@optional

- (void)RCHWithdrawListCell:(RCHWithdrawListCell *)cell withdraw:(RCHWithdraw *)withdraw;

@end

