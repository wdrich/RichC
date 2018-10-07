//
//  RCHWalletsViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWalletsViewController.h"
#import "RCHWalletViewController.h"
#import "RCHFlowsController.h"
#import "RCHWalletsRequest.h"
#import "RCHEmptyDataView.h"
#import "RCHWalletListCell.h"

#define defaultCellHeight 80.0f
#define footerHeight 100.0f

@interface RCHWalletsViewController ()
{
    NSInteger   _isReloadTable;
    NSDictionary *_parameter;
    RCHWalletsRequest *_walletsRequest;
}
@property (nonatomic, strong) RCHWalletsRequest *walletsRequest;
@property (nonatomic, strong) NSMutableArray *wallets;

@end

@implementation RCHWalletsViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"我的资产",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
//    self.tableView.tableHeaderView = [self createHeaderView:(CGRect){{0.0f, kAppOriginY}, {kMainScreenWidth, headerHeight}}];
    self.tableView.tableFooterView = [self createFooterView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, footerHeight}}];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.tableView.scrollsToTop = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Implements UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_wallets count] > indexPath.row) {
        RCHWallet *wallet = [_wallets objectAtIndex:indexPath.row];
        RCHWalletViewController *viewcontroller = [[RCHWalletViewController alloc] initWithWallet:wallet];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    } else {
        [MBProgressHUD showError:kRangeError ToView:self.view];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForFooterInSection:section]];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark -
#pragma mark Implements UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_wallets  && [_wallets count] > 0) {
        return [_wallets count];
    }
    else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  defaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCHWallet *wallet = nil;
    if (_wallets && [_wallets count] > indexPath.row) {
        wallet = [_wallets objectAtIndex:indexPath.row];
    }
    if (wallet) {
        static NSString *CellIdentifier = @"walletCellIdentifier";
        RCHWalletListCell *cell = (RCHWalletListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            cell = [[RCHWalletListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if (wallet) {
            [cell setWallet:wallet];
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"CellIdentifier";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor clearColor];
        }
        return cell;
    }
    
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)showButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
//    BOOL isSelected = button.selected;
    [button setSelected:!button.selected];
    [RCHHelper setValue:[NSNumber numberWithBool:button.selected] forKey:kShowBalance];
    self.tableView.tableHeaderView = [self createHeaderView:self.tableView.tableHeaderView.frame];
}

#pragma mark -
#pragma mark - Request

- (void)getWallets
{
    self.tableView.tableFooterView = [self createFooterView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, footerHeight}}];
    RCHWeak(self);
    if (weakself.walletsRequest.currentTask) {
        [weakself.walletsRequest.currentTask cancel];
    }
    
    //    [MBProgressHUD showLoadToView:self.view];
    [weakself.walletsRequest wallets:^(NSObject *response) {
        [weakself endHeaderFooterRefreshing];
        //        [MBProgressHUD hideHUDForView:self.view];
        if ([response isKindOfClass:[NSArray class]]) {
            weakself.wallets = [NSMutableArray arrayWithArray:[weakself sort:(NSArray *)response]];
            [weakself tableviewReload];
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    }];
}

#pragma mark -
#pragma mark - CustomFuction

- (UIView *)createHeaderView:(CGRect)rect
{
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    headView.backgroundColor = kNavigationColor_MB;
    
    UIView *balanceView = [self createBalanceView:(CGRect){{0.0f, 0.0f}, {rect.size.width, rect.size.height}}];
    [headView addSubview:balanceView];
    
    
    return headView;
}

- (UIView *)createFooterView:(CGRect)rect
{
    UIView *footView = [[UIView alloc] initWithFrame:rect];
    [footView setBackgroundColor:[UIColor clearColor]];
    return footView;
}


- (UIView *)createTopbarView:(CGRect)rect
{
    CGFloat height = 20.0f;
    CGFloat originX = 20.0f;
    CGFloat width = 56.0f;
    UIColor *color = kAppOrangeColor;
    UIView *topbar = [[UIView alloc] initWithFrame:rect];
    topbar.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, 19.0f}, {width, height}}];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"当前资产";
    titleLabel.textColor = color;
    [topbar addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){{titleLabel.left, rect.size.height - 3.0f}, {titleLabel.width, 3.0f}}];
    lineView.backgroundColor = color;
    lineView.layer.cornerRadius = lineView.height / 2.0f;
    lineView.layer.masksToBounds = YES;
    [topbar addSubview:lineView];
    
    return topbar;
}

- (UIView *)createBalanceView:(CGRect)rect
{
    CGFloat height = 20.0f;
    CGFloat originX = 20.0f;
    CGFloat width = 66.0f;
    UIColor *color = RGBA(255.0f, 255.0f, 255.0f, 0.85);
    UIView *balanceview = [[UIView alloc] initWithFrame:rect];
    balanceview.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, 30.0f}, {width, height}}];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"总估值";
    titleLabel.textColor = color;
    [balanceview addSubview:titleLabel];
    [titleLabel sizeToFit];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(balanceview);
        make.top.mas_equalTo(30.0f);
        make.width.mas_equalTo(titleLabel.mas_width);
        make.height.mas_equalTo(20.0f);
    }];
    
    UIImage *image = [UIImage imageNamed:@"btn_hide.png"];
    UIImage *selectImage = [UIImage imageNamed:@"btn_view.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = (CGRect){{titleLabel.right + 10.0f, 0.0f}, image.size};
//    [button setBackgroundColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(showButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [balanceview addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(0.0f);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.width.mas_equalTo(image.size.width + 10.0f);
        make.height.mas_equalTo(image.size.height);
    }];
    
    
    NSDictionary *balance = [self getTotleBalance:_wallets];
    
    BOOL isSHow =  [[RCHHelper valueForKey:kShowBalance] boolValue];
    [button setSelected:isSHow];
    NSString *btc = @"0";
    NSString *cny = @"0";
    if (isSHow) {
        cny = [NSString stringWithFormat:@"¥%0.2f", [[balance objectForKey:@"cny"] floatValue]];
    } else {
        cny = @"****";
    }
    
    
    UILabel *cnyLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {60.0f, 22.0f}}];
    cnyLabel.backgroundColor = [UIColor clearColor];
    cnyLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:32.0f];
    cnyLabel.textAlignment = NSTextAlignmentCenter;
    cnyLabel.text = cny;
    cnyLabel.textColor = [UIColor whiteColor];
    [balanceview addSubview:cnyLabel];
    
    [cnyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(balanceview);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10.0f);
        make.width.mas_equalTo(balanceview.mas_width);
        make.height.mas_equalTo(30.0f);
    }];
    
    
    return balanceview;
}

- (NSArray *)sort:(NSArray *)wallets
{
    NSSortDescriptor * descript = [NSSortDescriptor sortDescriptorWithKey:@"balance" ascending:NO];
    NSArray * descripts = @[descript];
    return [wallets sortedArrayUsingDescriptors:descripts];
}

- (NSDictionary *)getTotleBalance:(NSArray *)wallets
{
    NSMutableDictionary *balance = [NSMutableDictionary dictionary];
    NSDecimalNumber *btc = [NSDecimalNumber zero];
    NSDecimalNumber *cny = [NSDecimalNumber zero];
    for (RCHWallet *wallet in wallets) {
        btc = [btc decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[wallet.ebtc decimalValue]]];
        cny = [cny decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[wallet.ecny decimalValue]]];
    }
    [balance setObject:btc forKey:@"btc"];
    [balance setObject:cny forKey:@"cny"];
    return balance;
}

- (void)loadMore:(BOOL)isMore
{
    [self getWallets];
}

- (void)tableviewReload
{
    CGFloat headerHeight = 140.0f;
    self.tableView.tableHeaderView = [self createHeaderView:(CGRect){{0.0f, kAppOriginY}, {kMainScreenWidth, headerHeight}}];
    if ([_wallets count] == 0) {
        self.tableView.tableFooterView = [[RCHEmptyDataView alloc] initWithFrame:self.tableView.frame text:NSLocalizedString(@"没有资产信息",nil)];
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.tableFooterView = [self createFooterView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, footerHeight}}];
        self.tableView.scrollEnabled = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark -  NavigationDataSource

- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar
{
    [self customButtonInfo:rightButton title:NSLocalizedString(@"历史记录",nil)];
    return nil;
}

#pragma mark -
#pragma mark -  NavigationDelegate

-(void)rightButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar {
    NSLog(@"%s", __func__);
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RCHFlowsController *flowsViewController = [[RCHFlowsController alloc] init];
        [weakself.navigationController pushViewController:flowsViewController animated:YES];
    });
}


#pragma mark -
#pragma mark - getter

- (RCHWalletsRequest *)walletsRequest
{
    if(_walletsRequest == nil)
    {
        _walletsRequest = [[RCHWalletsRequest alloc] init];
    }
    return _walletsRequest;
}

@end
