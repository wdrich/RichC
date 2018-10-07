//
//  RCHSettingViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/19.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHSettingViewController.h"

@interface RCHSettingViewController ()

@end

@implementation RCHSettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    self.tableView.backgroundColor = [UIColor clearColor];

    RCHWeak(self);
    RCHKeyValueArrowItem *item1 = [RCHKeyValueArrowItem itemWithTitle:@"退出登录" subTitle:@"" itemOperation:^(NSIndexPath *indexPath) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutDidSuccessNotification object:nil];
        });        
    }];
    
    
    RCHItemSection *section1 = [RCHItemSection sectionWithItems:@[item1] andHeaderTitle:@"" footerTitle:@""];
    
    [self.sections addObjectsFromArray:@[section1]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
