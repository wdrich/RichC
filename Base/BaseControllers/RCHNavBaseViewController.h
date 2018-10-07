//
//  RCHNavBaseViewController.h
//  richcore
//
//  Created by Dong Wang on 2018/1/25.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "RCHNavigationBar.h"

@class RCHNavBaseViewController;
@protocol RCHNavBaseViewControllerDataSource <NSObject>

@optional
- (BOOL)navUIBaseViewControllerIsNeedNavBar:(RCHNavBaseViewController *)navUIBaseViewController;
@end

@interface RCHNavBaseViewController : UIViewController <RCHNavigationBarDelegate, RCHNavigationBarDataSource, RCHNavBaseViewControllerDataSource>
/*默认的导航栏字体*/
- (NSMutableAttributedString *)changeTitle:(NSString *)curTitle;
/**  */
@property (weak, nonatomic) RCHNavigationBar *k_navgationBar;

@end

