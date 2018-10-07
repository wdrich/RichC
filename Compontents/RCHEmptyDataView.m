//
//  RCHEmptyDataView.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHEmptyDataView.h"

@implementation RCHEmptyDataView

- (id)initWithFrame:(CGRect)frame text:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = text;
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = kFontLightGrayColor;
        titleLabel.backgroundColor = [UIColor clearColor];
//        titleLabel.shadowColor = [UIColor whiteColor];
//        titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [self addSubview:titleLabel];
        [titleLabel sizeToFit];
        
        titleLabel.frame = (CGRect){{(frame.size.width - titleLabel.frame.size.width) / 2, (frame.size.height - titleLabel.frame.size.height) / 2}, titleLabel.frame.size};
        
    }
    return self;
}

@end
