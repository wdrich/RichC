//
//  UIView+WDFrame.m
//  PLMMPRJK
//
//  Created by HuXuPeng on 2017/4/29.
//  Copyright © 2017年 GoMePrjk. All rights reserved.
//

#import "UIView+WDFrame.h"

@implementation UIView (WDFrame)

- (CGFloat)k_x {
    return self.frame.origin.x;
}

- (void)setK_x:(CGFloat)k_x {
    CGRect frame = self.frame;
    frame.origin.x = k_x;
    self.frame = frame;
}

- (CGFloat)k_y {
    return self.frame.origin.y;
}

- (void)setK_y:(CGFloat)k_y {
    CGRect frame = self.frame;
    frame.origin.y = k_y;
    self.frame = frame;
}

- (CGFloat)k_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setK_right:(CGFloat)k_right {
    CGRect frame = self.frame;
    frame.origin.x = k_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)k_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setK_bottom:(CGFloat)k_bottom {
    
    CGRect frame = self.frame;
    
    frame.origin.y = k_bottom - frame.size.height;
    
    self.frame = frame;
}

- (CGFloat)k_width {
    return self.frame.size.width;
}

- (void)setK_width:(CGFloat)k_width {
    CGRect frame = self.frame;
    frame.size.width = k_width;
    self.frame = frame;
}

- (CGFloat)k_height {
    return self.frame.size.height;
}

- (void)setK_height:(CGFloat)k_height {
    CGRect frame = self.frame;
    frame.size.height = k_height;
    self.frame = frame;
}

- (CGFloat)k_centerX {
    return self.center.x;
}

- (void)setK_centerX:(CGFloat)k_centerX {
    self.center = CGPointMake(k_centerX, self.center.y);
}

- (CGFloat)k_centerY {
    return self.center.y;
}

- (void)setK_centerY:(CGFloat)k_centerY {
    self.center = CGPointMake(self.center.x, k_centerY);
}

- (CGPoint)k_origin {
    return self.frame.origin;
}

- (void)setK_origin:(CGPoint)k_origin {
    CGRect frame = self.frame;
    frame.origin = k_origin;
    self.frame = frame;
}

- (CGSize)k_size {
    return self.frame.size;
}

- (void)setK_size:(CGSize)k_size {
    CGRect frame = self.frame;
    frame.size = k_size;
    self.frame = frame;
}

@end
