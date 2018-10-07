//
//  RCHKeyValueCell.h
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCHKeyValueItem;

@interface RCHKeyValueCell : UITableViewCell

@property (nonatomic, assign) CGSize headImageSize;
@property (nonatomic, assign) CGFloat originX;
@property (nonatomic, assign) CGFloat spaceX;
@property (nonatomic, assign) CGFloat lineOriginX;
@property (nonatomic, strong) NSString *accessoryCount;
@property (nonatomic, strong) UIColor *accessoryColor;
@property (nonatomic, strong) UIColor *titleColor;

+ (instancetype)cellWithTableView:(UITableView *)tableView andCellStyle:(UITableViewCellStyle)style;

- (void)setTitle:(NSString *)title andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl  andAccessoryView:(UIView *)accessoryView;
- (void)setTitle:(NSString *)title andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage andAccessoryView:(UIView *)accessoryView;
- (void)setTitle:(NSString *)title subTitle:(NSString *)subtitle andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage andAccessoryView:(UIView *)accessoryView;

@end
