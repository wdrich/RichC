//
//  RCHRate.m
//  richcore
//
//  Created by WangDong on 2018/7/16.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRate.h"

@implementation RCHRate

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.src = nil;
    self.dis = nil;
    self.rate = nil;
    
    return self;
}

- (void)dealloc {
    
    self.src = nil;
    self.dis = nil;
    self.rate = nil;
}


@end
