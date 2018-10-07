//
//  RCHPayNavigationBar.m
//  richcore
//
//  Created by Apple on 2018/6/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHPayNavigationBar.h"

@implementation RCHPayNavigationBar

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title leftView:(UIView *)leftView rightView:(UIView *)rightView {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat padding = 0;
        if (leftView) {
            padding = MAX(padding, leftView.frame.size.width);
        }
        if (rightView) {
            padding = MAX(padding, rightView.frame.size.width);
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding,
                                                                        0,
                                                                        frame.size.width - padding * 2,
                                                                        frame.size.height)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 1;
        titleLabel.clipsToBounds = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = RGBA(51, 51, 51, 1);
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17.f];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        if (leftView) {
            leftView.frame = CGRectMake(0, 0, leftView.frame.size.width, leftView.frame.size.height);
            leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            [self addSubview:leftView];
        }
        
        if (rightView) {
            rightView.frame = CGRectMake(frame.size.width - rightView.frame.size.width, 0, rightView.frame.size.width, rightView.frame.size.height);
            rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self addSubview:rightView];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetLineWidth(context, .5f);
    [RGBA(225.f, 225.f, 225.f, 1.f) setStroke];
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
