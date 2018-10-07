//
//  RCHWithdrawsController.m
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWithdrawsController.h"
#import "RCHEmptyDataView.h"
#import "RCHWithdrawListCell.h"
#import "RCHWithdrawRequest.h"
#import "RCHWithdraw.h"
#import "RCHTXDetailViewController.h"

#define defaultCellHeight 72.0f

@interface RCHWithdrawsController () <RCHWithdrawCellDelegate>

@property (nonatomic, assign) NSInteger  pageSize;
@property (nonatomic, assign) NSInteger  page;
@property (nonatomic, strong) RCHWithdrawRequest *withdrawRequest;
@property (nonatomic, strong) NSMutableArray *withdraws;

@end

@implementation RCHWithdrawsController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"提币记录",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    if (self.withdraws  && [self.withdraws count] > 0) {
        return [self.withdraws count];
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
    RCHWithdraw *withdraw = nil;
    if (_withdraws && [_withdraws count] > indexPath.row) {
        withdraw = [_withdraws objectAtIndex:indexPath.row];
    }
    if (withdraw) {
        static NSString *CellIdentifier = @"walletCellIdentifier";
        RCHWithdrawListCell *cell = (RCHWithdrawListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            cell = [[RCHWithdrawListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            cell.delegate = self;
        }
        
        if (withdraw) {
            [cell setWithdraw:withdraw];
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

#pragma mark - UITableVewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RCHTXDetailViewController *controller = [[RCHTXDetailViewController alloc] initWithWithdraw:[_withdraws objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark - Request
- (void)getwWithdraws
{
    self.tableView.tableFooterView = nil;
    RCHWeak(self);
    if (weakself.withdrawRequest.currentTask) {
        [weakself.withdrawRequest.currentTask cancel];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithInteger:self.page] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithInteger:self.pageSize] forKey:@"size"];
    
    [weakself.withdrawRequest withdraws:^(NSObject *response) {
        [weakself endHeaderFooterRefreshing];
        if ([response isKindOfClass:[RCHWithdrawList class]]) {
            RCHWithdrawList *withdrawList = (RCHWithdrawList *)response;
            if (weakself.page == 1) {
                [weakself.withdraws removeAllObjects];
            }
            weakself.page += 1;
            [weakself.withdraws addObjectsFromArray:withdrawList.records];
            if (withdrawList.page < withdrawList.total) {
                self.tableView.mj_footer.hidden = NO;
            } else {
                self.tableView.mj_footer.hidden = YES;
            }
            [weakself tableviewReload];
            
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    } parameters:parameters];

}


- (void)revokeRequest:(void(^)(NSError *error, WDBaseResponse *response))completion withdrawId:(NSInteger)withdrawId
{
    if (self.withdrawRequest.currentTask) {
        [self.withdrawRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [self.withdrawRequest revokeWithdraw:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        completion(error, response);
    } withdrawId:withdrawId];
}

#pragma mark -
#pragma mark - CustomFuction

- (void)init_info
{
    self.page = 1;
    self.pageSize = 20;
}

- (void)loadMore:(BOOL)isMore
{
    if (!isMore) {
        [self init_info];
    }
    [self getwWithdraws];
}

- (void)tableviewReload
{
    if ([self.withdraws count] == 0) {
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
#pragma mark RCHWithdrawCellDelegate delegate
- (void)RCHWithdrawListCell:(RCHWithdrawListCell *)cell withdraw:(RCHWithdraw *)withdraw;
{
    RCHWeak(self);
    [self revokeRequest:^(NSError *error, WDBaseResponse *response) {
        if (error) {
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            cell.withdraw.revoked_at = [RCHHelper transTimeString:[NSDate date]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell reload];
            });
        });
        [MBProgressHUD showInfo:NSLocalizedString(@"取消成功", nil) ToView:weakself.view];
    } withdrawId:withdraw.withdraw_id];
}

#pragma mark -
#pragma mark - getter

- (NSArray *)withdraws
{
    if(_withdraws == nil)
    {
        _withdraws = [NSMutableArray array];
    }
    return _withdraws;
}

- (RCHWithdrawRequest *)withdrawRequest
{
    if(_withdrawRequest == nil)
    {
        _withdrawRequest = [[RCHWithdrawRequest alloc] init];
    }
    return _withdrawRequest;
}

@end
