//
//  RCHSafeCenterViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/19.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHSafeCenterViewController.h"
#import "RCHGoogleAuthController.h"
#import "RCHRevokeGoogleAuthController.h"
#import "RCHModifyPasswordController.h"
#import "RCHBindMobileViewController.h"
#import "RCHRemoveBindController.h"
#import "RCHAlertView.h"

@interface RCHSafeCenterViewController ()

@end

@implementation RCHSafeCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    RCHKeyValueArrowItem *item1 = [RCHKeyValueArrowItem itemWithTitle:@"修改密码" subTitle: @""];
    item1.destVc = [RCHModifyPasswordController class];
    
    NSString *mobile = @"未开启";
    NSString *google = @"未开启";
    NSString *info = @"完成";
    

    BOOL isNeedMobileAuth = ![RCHHelper valueForKey:kCurrentUserMobile];
    if (isNeedMobileAuth) {
        mobile = @"未开启";
    } else {
        mobile = @"已开启";
        info = @"关闭";
    }
    
    
    BOOL isNeedGoogleAuth = ![[RCHHelper valueForKey:kCurrentUserGoogleAuth] boolValue];
    if (isNeedGoogleAuth) {
        google = @"未开启";
    } else {
        google = @"已开启";
    }
    
    RCHWeak(self);
    RCHKeyValueArrowItem *item2 = [RCHKeyValueArrowItem itemWithTitle:@"手机验证" subTitle: mobile itemOperation:^(NSIndexPath *indexPath) {
        [weakself showMobileAuthAlert:info];
    }];
    
    RCHKeyValueArrowItem *item3 = [RCHKeyValueArrowItem itemWithTitle:@"谷歌验证" subTitle: google itemOperation:^(NSIndexPath *indexPath) {
        [weakself showGoogleAuthAlert:isNeedGoogleAuth];
    }];
    
    
    RCHItemSection *section1 = [RCHItemSection sectionWithItems:@[item1] andHeaderTitle:@"" footerTitle:@""];
    
    RCHItemSection *section2 = [RCHItemSection sectionWithItems:@[item2, item3] andHeaderTitle:@"" footerTitle:@""];

    [self.sections addObjectsFromArray:@[section1, section2]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - CustomFunction

-(void) showMobileAuthAlert:(NSString *)info
{
    BOOL isNeedMobileAuth = ![RCHHelper valueForKey:kCurrentUserMobile];
    
    if (isNeedMobileAuth) {
        RCHBindMobileViewController *viewcontroller = [[RCHBindMobileViewController alloc] init];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    } else {
        RCHRemoveBindController *viewcontroller = [[RCHRemoveBindController alloc] init];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }
}

-(void) showGoogleAuthAlert:(BOOL)isNeddAuth
{
    if (isNeddAuth) {
        RCHGoogleAuthController *viewcontroller = [[RCHGoogleAuthController alloc] initWithGoogleAuthType:RCHGoogleAuthTypeDownload];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    } else {
        
        RCHRevokeGoogleAuthController *viewcontroller = [[RCHRevokeGoogleAuthController alloc] init];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }
}

@end
