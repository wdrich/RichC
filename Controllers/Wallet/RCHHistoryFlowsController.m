//
//  RCHHistoryFlowsController.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHHistoryFlowsController.h"
#import "RCHEmptyDataView.h"
#import "RCHFlowListCell.h"
#import "RCHFlowRequest.h"
#import "RCHWalletsRequest.h"
#import "RCHTXDetailViewController.h"

#define defaultCellHeight 72.0f

@interface RCHHistoryFlowsController ()
{
    RCHFlowsType _flowsType;
    RCHWalletsRequest *_walletsRequest;
    NSArray *_wallets;
    RCHPaging *_paging;
}

@property (nonatomic, strong) RCHFlowRequest *flowsRequest;
@property (nonatomic, strong) NSArray *flows;

@end

@implementation RCHHistoryFlowsController

- (id)initWithFlowsType:(RCHFlowsType)type
{
    if(self = [super init]) {
        _flowsType = type;
        _wallets = @[];
        _paging = [[RCHPaging alloc] init];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"充币记录",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    [self.tableView.mj_header beginRefreshing];
    [self getWallets];
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
#pragma mark Implements UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _paging ? [_paging.records count] : 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  defaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCHFlow *flow = nil;
    if (_paging) {
        flow = [_paging.records objectAtIndex:indexPath.row];
    }
    if (flow) {
        static NSString *CellIdentifier = @"walletCellIdentifier";
        RCHFlowListCell *cell = (RCHFlowListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            cell = [[RCHFlowListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if (flow) {
            [cell setFlow:flow];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_flowsType == RCHFlowsTypeShareUnlock) return;
    
    RCHFlow *flow = [_paging.records objectAtIndex:indexPath.row];
    RCHWallet *theWallet = nil;
    for (RCHWallet *wallet in _wallets) {
        if ([wallet.coin.code isEqualToString:flow.coin.code]) {
            theWallet = wallet;
            break;
        }
    }
    if (!theWallet) return;
    
    RCHTXDetailViewController *controller = [[RCHTXDetailViewController alloc] initWithRecharge:[RCHRecharge rechargeWithFlow:[_paging.records objectAtIndex:indexPath.row] wallet:theWallet]];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark -
#pragma mark - CustomFuction

- (void)fetchFlowsRequest:(BOOL)refresh
{
    self.tableView.tableFooterView = nil;
    RCHWeak(self);
    if (weakself.flowsRequest.currentTask) {
        [weakself.flowsRequest.currentTask cancel];
    }
    
    NSString *range = @"";
    switch (_flowsType) {
        case RCHFlowsTypeRecharge:
            range = @"recharge";
            break;
        case RCHFlowsTypeShareUnlock:
            range = @"share_unlock";
            break;
        default:
            range = @"all";
            break;
    }
    
    [weakself.flowsRequest flows:^(NSObject *response) {
        [weakself endHeaderFooterRefreshing];
        if ([response isKindOfClass:[RCHPaging class]]) {
            [weakself tableviewReload:(RCHPaging *)response refresh:refresh];
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    } range:range page:(refresh ? 1 : _paging.page + 1) size:20];
}

- (void)loadMore:(BOOL)isMore
{
    if (isMore && _paging.page >= _paging.total) return;
    [self fetchFlowsRequest:!isMore];
}

- (void)tableviewReload:(RCHPaging *)paging refresh:(BOOL)refresh
{
    _paging = refresh ? paging : [_paging merge:paging];
    self.tableView.mj_footer.hidden = _paging.page >= _paging.total;
    if ([_paging.records count] == 0) {
        self.tableView.tableFooterView = [[RCHEmptyDataView alloc] initWithFrame:self.tableView.frame text:NSLocalizedString(@"还没有记录",nil)];
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.tableFooterView = nil;
        self.tableView.scrollEnabled = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - getter

- (RCHFlowRequest *)flowsRequest
{
    if(_flowsRequest == nil)
    {
        _flowsRequest = [[RCHFlowRequest alloc] init];
    }
    return _flowsRequest;
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

- (void)getWallets
{
    if ([self walletsRequest].currentTask) {
        [[self walletsRequest].currentTask cancel];
    }
    
    [[self walletsRequest] wallets:^(NSObject *response) {
        if ([response isKindOfClass:[NSArray class]]) {
            self->_wallets = (NSArray *)response;
        }
    }];
}

@end
