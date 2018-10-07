//
//  RCHBaseViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHBaseViewController.h"

@interface RCHBaseViewController ()

@end

@implementation RCHBaseViewController

#pragma mark - 生命周期

- (id)init {
    if(self = [super init]) {
        _offsetY = 0.0f;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)){
            [[UIScrollView appearanceWhenContainedInInstancesOfClasses:@[[RCHBaseViewController class]]] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    });
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
    //只支持这一个方向(正常的方向)
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super init]) {
        self.title = title.copy;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[WDRequestManager sharedManager].operationQueue cancelAllOperations];
}


#pragma mark -
#pragma mark -  NavigationDelegate


-(void)leftButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar {
    NSLog(@"%s", __func__);
    
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark -
#pragma mark - NavigationDataSource

- (UIImage *)RCHNavigationBarLeftButtonImage:(UIButton *)leftButton navigationBar:(RCHNavigationBar *)navigationBar
{
    if (self.navigationController.viewControllers.count > 1) {
        leftButton.k_size = (CGSizeMake(34.0f, 44.0f));
        UIImage *image = RCHIMAGEWITHNAMED(@"btn_back");
        return image;
    } else {
        return nil;
    }
    
}


/** 背景色 */
- (UIColor *)RCHNavigationBackgroundColor:(RCHNavigationBar *)navigationBar
{
    return kNavigationColor_MB;
}

/** 是否显示底部黑线 */
- (BOOL)RCHNavigationIsHideBottomLine:(RCHNavigationBar *)navigationBar
{
    return YES;
}

/**头部标题*/
- (NSMutableAttributedString*)RCHNavigationBarTitle:(RCHNavigationBar *)navigationBar
{
    return [self changeTitle:self.title ?: self.navigationItem.title];
}

#pragma mark 自定义代码

-(NSMutableAttributedString *)changeTitle:(NSString *)curTitle
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:curTitle ?: @""];
    
    [title addAttribute:NSForegroundColorAttributeName value:kNavigationTextColor range:NSMakeRange(0, title.length)];
    
    [title addAttribute:NSFontAttributeName value:kNavigationTitleFont range:NSMakeRange(0, title.length)];
    
    return title;
}


- (void)customButtonInfo:(UIButton *)button title:(NSString *)title
{
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState: UIControlStateNormal];
    if ([title length] > 2) {
        [button.titleLabel setFont:kNavigationButtonFont];
    } else {
        [button.titleLabel setFont:kNavigationShortButtonFont];
    }
    
    [button sizeToFit];
    
    button.k_height = kNavigationBarHeight;
    button.k_width = button.k_width + 12.0f;
}


#pragma mark -
#pragma mark - UITapGestureRecognizer

-(void)viewTapped:(UITapGestureRecognizer*)tapGesture
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


@end
