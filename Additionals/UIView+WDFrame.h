//
//  UIView+WDFrame.h
//  PLMMPRJK
//
//  Created by HuXuPeng on 2017/4/29.
//  Copyright © 2017年 GoMePrjk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WDFrame)

@property (nonatomic) CGFloat k_x;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat k_y;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat k_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat k_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat k_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat k_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat k_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat k_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint k_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  k_size;        ///< Shortcut for frame.size.

@end
