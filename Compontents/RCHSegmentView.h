//
//  RCHSegmentView.h
//  MeiBe
//
//  Created by WangDong on 2018/3/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCHSegmentView;
@protocol RCHSegmentViewDelegate <NSObject>

-(void)lxSegmentView:(RCHSegmentView *)segmentView
         selectIndex:(NSInteger)selectIndex;

@end


typedef void(^RCHSegmentViewSelectIndexBlock)(NSInteger index);


@interface RCHSegmentView : UIView

@property (nonatomic , strong) NSArray *btnTitleArray;

@property (nonatomic , strong) UIColor *btnTitleNormalColor;

@property (nonatomic , strong) UIColor *btnTitleSelectColor;

@property (nonatomic , strong) UIColor *btnBackgroundNormalColor;

@property (nonatomic , strong) UIColor *btnBackgroundSelectColor;

@property (nonatomic , strong) UIFont *titleFont;

#pragma mark --block,delegate--
@property (nonatomic , copy) RCHSegmentViewSelectIndexBlock rchSegmentBtnSelectIndexBlock;

@property (nonatomic , weak) id<RCHSegmentViewDelegate> delegate;

@end
