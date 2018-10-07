//
//  RCHShare.h
//  richcore
//
//  Created by Apple on 2018/7/4.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHShare : NSObject

@property (nonatomic, strong) RCHCoin *coin;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSNumber *unlocked;

- (NSDecimalNumber *)remain;

@end
