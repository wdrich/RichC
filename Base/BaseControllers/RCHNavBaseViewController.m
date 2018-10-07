//
//  RCHNavBaseViewController.m
//  richcore
//
//  Created by Dong Wang on 2018/1/25.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "RCHNavBaseViewController.h"
#import "RCHNavigationBar.h"

@implementation RCHNavBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RCHWeak(self);
    [self.navigationItem addObserverBlockForKeyPath:RCHKeyPath(self.navigationItem, title) block:^(id  _Nonnull obj, id  _Nonnull oldVal, NSString  *_Nonnull newVal) {
        if (newVal.length > 0 && ![newVal isEqualToString:oldVal]) {
            weakself.title = newVal;
        }
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
    //只支持这一个方向(正常的方向)
}

#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.k_navgationBar.width = self.view.width;
    [self.view bringSubviewToFront:self.k_navgationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [self.navigationItem removeObserverBlocksForKeyPath:RCHKeyPath(self.navigationItem, title)];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark -
#pragma mark - DataSource
- (BOOL)navUIBaseViewControllerIsNeedNavBar:(RCHNavBaseViewController *)navUIBaseViewController {
    return YES;
}

/**头部标题*/
- (NSMutableAttributedString*)RCHNavigationBarTitle:(RCHNavigationBar *)navigationBar
{
    
    return [self changeTitle:self.title ?: self.navigationItem.title];
}

/** 背景图片 */
//- (UIImage *)RCHNavigationBarBackgroundImage:(RCHNavigationBar *)navigationBar
//{
//
//}


/** 背景色 */
- (UIColor *)RCHNavigationBackgroundColor:(RCHNavigationBar *)navigationBar
{
    return [UIColor whiteColor];
}

/** 是否显示底部黑线 */
- (BOOL)RCHNavigationIsHideBottomLine:(RCHNavigationBar *)navigationBar
{
    return NO;
}

/** 导航条的高度 */
- (CGFloat)RCHNavigationHeight:(RCHNavigationBar *)navigationBar {
    return [UIApplication sharedApplication].statusBarFrame.size.height + 44.0;
}


/** 导航条的左边的 view */
//- (UIView *)RCHNavigationBarLeftView:(RCHNavigationBar *)navigationBar
//{
//
//}
/** 导航条右边的 view */
//- (UIView *)RCHNavigationBarRightView:(RCHNavigationBar *)navigationBar
//{
//
//}
/** 导航条中间的 View */
//- (UIView *)RCHNavigationBarTitleView:(RCHNavigationBar *)navigationBar
//{
//
//}
/** 导航条左边的按钮 */
//- (UIImage *)RCHNavigationBarLeftButtonImage:(UIButton *)leftButton navigationBar:(RCHNavigationBar *)navigationBar
//{
//
//}
/** 导航条右边的按钮 */
//- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar
//{
//
//}



#pragma mark - Delegate
/** 左边的按钮的点击 */
-(void)leftButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar {
    NSLog(@"%s", __func__);
}
/** 右边的按钮的点击 */
-(void)rightButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar {
    NSLog(@"%s", __func__);
}
/** 中间如果是 label 就会有点击 */
-(void)titleClickEvent:(UILabel *)sender navigationBar:(RCHNavigationBar *)navigationBar {
    NSLog(@"%s", __func__);
}


#pragma mark 自定义代码

-(NSMutableAttributedString *)changeTitle:(NSString *)curTitle
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:curTitle ?: @""];
    
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, title.length)];
    
    [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:18.0f] range:NSMakeRange(0, title.length)];
    
    return title;
}



- (RCHNavigationBar *)k_navgationBar {
    // 父类控制器必须是导航控制器
    if(!_k_navgationBar && [self.parentViewController isKindOfClass:[UINavigationController class]])
    {
        RCHNavigationBar *navigationBar = [[RCHNavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        [self.view addSubview:navigationBar];
        _k_navgationBar = navigationBar;
        
        navigationBar.dataSource = self;
        navigationBar.rchDelegate = self;
        navigationBar.hidden = ![self navUIBaseViewControllerIsNeedNavBar:self];
    }
    return _k_navgationBar;
}




- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.k_navgationBar.title = [self changeTitle:title];
}

@end
