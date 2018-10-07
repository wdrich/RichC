//
//  MJLOnePixLineView.h
//  MJLMerchantsChatServerPush
//
//  Created by WangDong on 14-8-20.
//  Copyright (c) 2014年 WangDong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MJLOnePixLineViewImage     = 1, //图片
    MJLOnePixLineViewdraw      = 2  //划线
} MJLOnePixLineViewType;

@interface MJLOnePixLineView : UIView

@property (nonatomic, assign) MJLOnePixLineViewType lineType;
@property (nonatomic, strong) NSString *lineImageName;

@end
