//
//  RCHAlert.h
//  MeiBe
//
//  Created by WangDong on 2018/3/30.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHAlert : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, assign) BOOL leveled;
@property (nonatomic, assign) BOOL showTopLine;
@property (nonatomic, assign) BOOL showBottomLine;

@end
