//
//  MJLFaceItemCell.h
//  MJLMerchantsChat
//
//  Created by WangDong on 13-4-30.
//  Copyright (c) 2013年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJLFaceItemCell : UITableViewCell

@property (nonatomic, assign) CGSize headImageSize;
@property (nonatomic, assign) CGFloat originX;
@property (nonatomic, assign) CGFloat spaceX;
@property (nonatomic, assign) CGFloat lineOriginX;
@property (nonatomic, assign) BOOL isHideLine;
@property (nonatomic, strong) NSString *accessoryCount;
@property (nonatomic, strong) UIColor *accessoryColor;
@property (nonatomic, strong) UIColor *titleColor;

- (void)setTitle:(NSString *)title andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl  andAccessoryView:(UIView *)accessoryView;
- (void)setTitle:(NSString *)title andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage andAccessoryView:(UIView *)accessoryView;
- (void)setTitle:(NSString *)title subTitle:(NSString *)subtitle andValue:(NSString *)value andHeadimageUtl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage andAccessoryView:(UIView *)accessoryView;

@end
