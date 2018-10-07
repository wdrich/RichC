//
//  RCHKlineItem.h
//  richcore
//
//  Created by WangDong on 2018/7/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHKlineItem : NSObject

@property (nonatomic, copy) NSString *open;
@property (nonatomic, copy) NSString *high;
@property (nonatomic, copy) NSString *low;
@property (nonatomic, copy) NSString *close;
@property (nonatomic, copy) NSString *volume;

@property (nonatomic, assign) NSTimeInterval timestamp;

@end
