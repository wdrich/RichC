//
//  RCHMyViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMyViewController.h"
#import "RCHLoginViewController.h"
#import "RCHTabbarViewController.h"
#import "RCHSafeCenterViewController.h"
#import "RCHWalletsViewController.h"
#import "RCHSettingViewController.h"
#import "RCHInviteController.h"
#import "MJLOnePixLineView.h"
#import "RCHAlertView.h"

#define headViewHeight 85.0f

@interface RCHMyViewController ()<UIGestureRecognizerDelegate>

@end

@implementation RCHMyViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = [self createHeaderView:(CGRect){{0.0f, 0.0f}, {self.tableView.width, headViewHeight}}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.bottom += kTabBarHeight;
    self.tableView.contentInset = edgeInsets;
    
    RCHKeyValueArrowItem *item1 = [RCHKeyValueArrowItem itemWithTitle:NSLocalizedString(@"我的资产", nil) subTitle: @"" itemOperation:^(NSIndexPath *indexPath) {
        RCHWalletsViewController *viewcontroller = [[RCHWalletsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }];
    item1.defaultImage = RCHIMAGEWITHNAMED(@"ico_wallet");
    
    RCHKeyValueArrowItem *item2 = [RCHKeyValueArrowItem itemWithTitle:NSLocalizedString(@"奖励中心", nil) subTitle: @""];
    item2.defaultImage = RCHIMAGEWITHNAMED(@"ico_gfit");
    item2.destVc = [RCHInviteController class];
    
    RCHWeak(self);
    RCHKeyValueArrowItem *item3 = [RCHKeyValueArrowItem itemWithTitle:NSLocalizedString(@"身份认证", nil) subTitle: @"" itemOperation:^(NSIndexPath *indexPath) {
        [weakself showAlert];
    }];
    item3.defaultImage = RCHIMAGEWITHNAMED(@"ico_identify");
    
    RCHKeyValueArrowItem *item4 = [RCHKeyValueArrowItem itemWithTitle:NSLocalizedString(@"安全中心", nil) subTitle: @""];
    item4.defaultImage = RCHIMAGEWITHNAMED(@"ico_security");
    item4.destVc = [RCHSafeCenterViewController class];
    
    RCHKeyValueArrowItem *item5 = [RCHKeyValueArrowItem itemWithTitle:NSLocalizedString(@"设置", nil) subTitle: @""];
    item5.defaultImage = RCHIMAGEWITHNAMED(@"ico_set");
    item5.destVc = [RCHSettingViewController class];
    
#ifdef TEST_MODE_CORP
    NSString *value = [NSString stringWithFormat:@"v %@ (测试版)",SOFTWARE_BUILT_VERSION];
#else
    NSString *value = [NSString stringWithFormat:@"v %@",SOFTWARE_VERSION];
#endif
    if ([RCHHelper isNeedUpdate]) {
        value = NSLocalizedString(@"有新版请升级",nil);
    }
    RCHKeyValueArrowItem *item6 = [RCHKeyValueArrowItem itemWithTitle:NSLocalizedString(@"当前版本",nil) subTitle: value];
    item6.defaultImage = RCHIMAGEWITHNAMED(@"ico_version");
    item6.itemOperation = ^(NSIndexPath *indexPath) {
        
        if ([RCHHelper isNeedUpdate]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kManualUpdateNotification object:nil];
        } else {
            [MBProgressHUD showInfo:NSLocalizedString(@"已更新至最新版本", nil) ToView:weakself.view];
        }
        
    };
    
    RCHKeyValueArrowItem *item7 = [RCHKeyValueArrowItem itemWithTitle:NSLocalizedString(@"帮助中心", nil) subTitle: @"" itemOperation:^(NSIndexPath *indexPath) {
        RCHWebViewController *webviewController = [[RCHWebViewController alloc] init];
        webviewController.gotoURL = @"https://richc.zendesk.com/hc/zh-cn";
        webviewController.title = NSLocalizedString(@"帮助中心",nil);
        [self.navigationController pushViewController:webviewController animated:YES];
    }];
    item7.defaultImage = RCHIMAGEWITHNAMED(@"ico_help");
    
    RCHItemSection *section1 = [RCHItemSection sectionWithItems:@[item1] andHeaderTitle:@"" footerTitle:@""];
    
    RCHItemSection *section2 = [RCHItemSection sectionWithItems:@[item2, item3, item4, item5, item7] andHeaderTitle:@"" footerTitle:@""];
    
    RCHItemSection *section3 = [RCHItemSection sectionWithItems:@[item6] andHeaderTitle:@"" footerTitle:@""];
    
    
    [self.sections addObjectsFromArray:@[section1, section2, section3]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Implements UITableViewDelegate protocol


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.0f;
    }
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:section]];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForFooterInSection:section]];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


#pragma mark -
#pragma mark - CustomFunction

- (UIView *)createHeaderView:(CGRect)frame
{
    UIView *headView = [[UIView alloc] initWithFrame:frame];
    headView.backgroundColor = [UIColor clearColor];
    
    UIView *cell = [[UIView alloc] initWithFrame:(CGRect){{headView.left, 15.0f}, {headView.width, headView.height - 15.0f}}];
    cell.backgroundColor = [UIColor whiteColor];
    [headView addSubview:cell];
    
    float imageWith = 40.0f;
    float imageHeight = imageWith;
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, (cell.height - imageHeight)/2, imageWith, imageHeight)];
    headImageView.layer.cornerRadius = 8.0f;
    headImageView.layer.masksToBounds = YES;
    headImageView.userInteractionEnabled = YES;
    [headImageView sd_setImageWithURL:[NSURL URLWithString:[RCHHelper valueForKey:kCurrentHeadImageUrl]] placeholderImage:RCHIMAGEWITHNAMED(@"pic_me_headpic")];
    [cell addSubview:headImageView];
    
    NSString *showName;
    if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
        if (!RCHIsEmpty([RCHHelper valueForKey:kCurrentUserEmail])) {
            showName = [RCHHelper valueForKey:kCurrentUserEmail];
        } else {
            showName = NSLocalizedString(@"未知",nil);
        }
    } else {
        showName = NSLocalizedString(@"请登录",nil);
    }
    
    showName = [RCHHelper confusedSting:showName];
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:18.0f];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right + 15.0f, 20.0f, 200.0f, 20.0f)];
    nameLabel.font = font;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = kFontBlackColor;
    nameLabel.text = showName;
    [cell addSubview:nameLabel];
    [nameLabel sizeToFit];
    
    nameLabel.center = (CGPoint){nameLabel.center.x, headImageView.center.y};
    
    MJLOnePixLineView *toplineView = [[MJLOnePixLineView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {cell.width, [RCHHelper retinaFloat:1.0f]}}];
    [cell addSubview:toplineView];
    
    MJLOnePixLineView *bottomView = [[MJLOnePixLineView alloc] initWithFrame:(CGRect){{0.0f, cell.height - [RCHHelper retinaFloatOffset:1.0f]}, {cell.width, [RCHHelper retinaFloat:1.0f]}}];
    [cell addSubview:bottomView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.cancelsTouchesInView = YES;
    tapGesture.delegate = self;
    [cell addGestureRecognizer:tapGesture];
    
    return headView;
}

-(void) showAlert
{
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger index = 0; index < 3; index ++) {
        NSString *title;
        NSString *subTitle;
        NSString *value;
        BOOL showTopLine;
        BOOL showBottomLine;
        switch (index) {
            case 0:
                title = @"Lv.1";
                subTitle = @"";
                value = @"24h提现额度：0.1 BTC";
                showTopLine = NO;
                showBottomLine = YES;
                break;
            case 1:
                title = @"Lv.2";
                subTitle = @"(身份认证)";
                value = @"24h提现额度：100 BTC";
                showTopLine = YES;
                showBottomLine = YES;
                break;
            case 2:
                title = @"Lv.3";
                subTitle = @"(联系我们)";
                value = @"更高提现额度";
                showTopLine = YES;
                showBottomLine = NO;
                break;
                
            default:
                title = @"";
                subTitle = @"";
                value = @"";
                showTopLine = YES;
                showBottomLine = NO;
                break;
        }
        
        
        RCHAlert *alert = [[RCHAlert alloc] init];
        alert.title = title;
        alert.subTitle = subTitle;
        alert.value = value;
        alert.showTopLine = showTopLine;
        alert.showBottomLine = showBottomLine;
        NSInteger grade = [[RCHHelper valueForKey:kCurrentUserGrade] integerValue];
        if (index < grade) {
            alert.leveled = YES;
        } else {
            alert.leveled = NO;
        }
        [items addObject:alert];
    }
    
    NSString *title = @"完成身份认证相关操作";
    
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [titleParagraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, [title length])];
    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f] range:NSMakeRange(0, [title length])];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange(0, [title length])];
    
    NSString *tempString = @"请前往富矿官网";
    NSString *boldString = @" ( richcore.com ）";
    NSString *description = [NSString stringWithFormat:@"%@%@", tempString, boldString];
    NSMutableAttributedString *attributedStrin2 = [[NSMutableAttributedString alloc] initWithString:description];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedStrin2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [description length])];
    [attributedStrin2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f] range:NSMakeRange(0, [tempString length])];
    [attributedStrin2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f] range:NSMakeRange([tempString length], [boldString length])];
    [attributedStrin2 addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange(0, [description length])];
    
    
    [RCHAlertView showAlertWithTitle:attributedStrin2 description:attributedString1 items:items detailHeight:210.0f type:RCHAlertViewList];
}

#pragma mark -
#pragma mark - tapGestureClicked

- (void)tapGesture:(id)sender
{
    if([RCHHelper gotoLogin]) {
        return;
    }
    
    return;
}


@end
