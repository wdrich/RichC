//
//  RCHOrderCurrentCell.h
//  MeiBe
//
//  Created by WangDong on 2018/3/25.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHOrder.h"

@protocol RCHOrderCurrentCellDelegate;

@interface RCHOrderCurrentCell : UITableViewCell

@property (nonatomic, strong) RCHOrder *order;
@property(nonatomic, assign) NSObject<RCHOrderCurrentCellDelegate> *delegate;

- (void)reload;

@end


@protocol RCHOrderCurrentCellDelegate <NSObject>
@optional

- (void)RCHOrderCurrentCell:(RCHOrderCurrentCell *)cell order:(RCHOrder *)order;

@end
