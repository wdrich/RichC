//
//  RCHWithdrawSuccessViewController.m
//  richcore
//
//  Created by Apple on 2018/6/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWithdrawSuccessViewController.h"
#import "RCHFlowsController.h"

@interface RCHWithdrawSuccessViewController ()

@end

@implementation RCHWithdrawSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"提示信息", nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
    rightView.frame = CGRectMake(0, 0, 50, 44);
    rightView.backgroundColor = [UIColor clearColor];
    rightView.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [rightView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightView setTitle:@"完成" forState:UIControlStateNormal];
    [self.k_navgationBar setRightView:rightView];
    
    [self loadContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)leftButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    [self back];
}

- (void)rightButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    [self back];
}

- (void)back {
    if ([[self.navigationController viewControllers] count] > 3) {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)loadContent
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kAppOriginY, self.view.frame.size.width, 335)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.frame.size.width - 74) / 2, 60, 74, 48)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.image = RCHIMAGEWITHNAMED(@"pic_email_verify");
    [view addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((view.frame.size.width - 314) / 2, 123, 314, 24)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = RGBA(51, 51, 51, 1);
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17.f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"邮箱验证";
    [view addSubview:titleLabel];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((view.frame.size.width - 314) / 2, 177, 314, 46)];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = RGBA(51, 51, 51, 1);
    textLabel.numberOfLines = 2;
    textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = @"已向您的注册邮箱发送一封验证邮件，\n请按照邮件中的提示，确认本次提币请求。";
    [view addSubview:textLabel];
    
    UIButton *flowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flowButton.frame = CGRectMake((view.frame.size.width - 120) / 2, 241, 120, 44);
    flowButton.layer.cornerRadius = 4.f;
    flowButton.layer.borderWidth = .5f;
    flowButton.layer.borderColor = kAppOrangeColor.CGColor;
    flowButton.layer.masksToBounds = YES;
    [flowButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    flowButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    [flowButton setTitleColor:kAppOrangeColor forState:UIControlStateNormal];
    [flowButton setTitle:@"历史记录" forState:UIControlStateNormal];
    [flowButton addTarget:self action:@selector(toFlow:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:flowButton];
    
    [self.view addSubview:view];
}

- (void)toFlow:(UIButton *)button
{
    RCHFlowsController *controller = [[RCHFlowsController alloc] initFromWithdraw];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
