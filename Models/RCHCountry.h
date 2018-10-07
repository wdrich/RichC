//
//  RCHCountry.h
//  MeiBe
//
//  Created by WangDong on 2018/3/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHCountry : NSObject

@property (nonatomic, assign) NSInteger countryId;//国家ID
@property (nonatomic, copy) NSString *code;//国家代码
@property (nonatomic, copy) NSString *name_cn;//国家名字
@property (nonatomic, copy) NSString *name_en;//国家名字英文


@end
