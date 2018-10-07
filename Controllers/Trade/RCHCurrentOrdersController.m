//
//  RCHCurrentOrdersController.m
//  richcore
//
//  Created by WangDong on 2018/5/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHCurrentOrdersController.h"
#import "RCHHistoryOrdersController.h"
#import "RCHOrderCell.h"
#import "RCHOrderRequest.h"

#define defaultCellHeight 100.0f

@interface RCHCurrentOrdersController () <RCHOrderCellDelegate>

@property (nonatomic, strong) RCHOrder *currentOrder;
@property (nonatomic, assign) NSInteger  pageSize;
@property (nonatomic, assign) NSInteger  page;
@property (nonatomic, strong) NSMutableArray *orders;
@property (nonatomic, strong) RCHOrderRequest *orderRequest;

@end

@implementation RCHCurrentOrdersController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"当前委托",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;

//    UIEdgeInsets edgeInsets = self.tableView.contentInset;
//    edgeInsets.bottom += kMainStatusBarHeight;
//    self.tableView.contentInset = edgeInsets;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self getOrders];
}

- (void)tableviewReload
{
    RCHWeak(self);
    [self.tableView configBlankPage:RCHBlankPageViewTypeNoDataOnlyMessage hasData:[_orders count] emptyMessage:@"暂无委托记录" reloadButtonBlock:^(UIButton *sender) {
        [weakself.tableView.mj_header beginRefreshing];
        weakself.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [weakself.tableView reloadData];
    }];
    [weakself.tableView reloadData];
}

- (void)refresh
{
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark -
#pragma mark - Request

- (void)getOrders
{
    self.tableView.tableFooterView = nil;
    RCHWeak(self);
    if (weakself.orderRequest.currentTask) {
        [weakself.orderRequest.currentTask cancel];
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@"current" forKey:@"range"];
    [dictionary setObject:[NSNumber numberWithInteger:1] forKey:@"is_page"];
    [dictionary setObject:[NSNumber numberWithInteger:self.pageSize] forKey:@"size"];
    [dictionary setObject:[NSNumber numberWithInteger:self.page] forKey:@"page"];
    
    [weakself.orderRequest orders:^(NSObject *response) {
        [weakself endHeaderFooterRefreshing];
        if ([response isKindOfClass:[RCHOrderList class]]) {
            RCHOrderList *orderList = (RCHOrderList *)response;
            if (weakself.page == 1) {
                [weakself.orders removeAllObjects];
            }
            weakself.page += 1;
            [weakself.orders addObjectsFromArray:orderList.data];
            if (orderList.page < orderList.total) {
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
    } info:dictionary];
}

- (void)revokeRequest:(void(^)(NSError *error, WDBaseResponse *response))completion orderId:(NSInteger)orderId
{
    if (self.orderRequest.currentTask) {
        [self.orderRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [self.orderRequest revokeOrder:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        completion(error, response);
    } orderId:orderId];
}

#pragma mark -
#pragma mark -  NavigationDataSource

- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar
{
    rightButton.imageView.contentMode = UIViewContentModeBottom;
    rightButton.k_size = (CGSizeMake(34.0f, 44.0f));
    UIImage *image = RCHIMAGEWITHNAMED(@"btn_trade_order");
    return image;
}

#pragma mark -
#pragma mark -  NavigationDelegate

-(void)rightButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([RCHHelper gotoLogin]) {
            return;
        }
        RCHHistoryOrdersController *viewcontroller = [[RCHHistoryOrdersController alloc] initWithStyle:UITableViewStylePlain];
        [weakself.navigationController pushViewController:viewcontroller animated:YES];
    });
}

#pragma mark -
#pragma mark Implements UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    if (self.orders  && [self.orders count] > 0) {
        return [self.orders count];
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
    RCHOrder *order = nil;
    
    if ([_orders count] > indexPath.row) {
        order = [_orders objectAtIndex:indexPath.row];
    }
    
    if (order) {
        static NSString *CellIdentifier = @"marketCellIdentifier";
        RCHOrderCell *cell = (RCHOrderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            cell = [[RCHOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            cell.showCoin = YES;
        }
        
        if (order) {
            [cell setOrder:order];
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"CellIdentifier";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor blueColor];
        }
        return cell;
    }
    
}

#pragma mark -
#pragma mark RCHOrderCellDelegate delegate

- (void)RCHOrderCell:(RCHOrderCell *)cell order:(RCHOrder *)order
{
    RCHWeak(self);
    [self revokeRequest:^(NSError *error, WDBaseResponse *response) {
        if (error) {
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
            if (code == 403) {
                [MBProgressHUD showInfo:NSLocalizedString(@"撤单失败", nil) ToView:weakself.view];
            }
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakself.orders removeObject:order];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself tableviewReload];
            });
        });
        
        [MBProgressHUD showInfo:NSLocalizedString(@"撤单成功", nil) ToView:weakself.view];
    } orderId:order.order_id];
}

#pragma mark -
#pragma mark - getter

- (NSMutableArray *)orders
{
    if(_orders == nil)
    {
        _orders = [NSMutableArray array];
    }
    return _orders;
}

- (RCHOrder *)currentOrder
{
    if(_currentOrder == nil)
    {
        _currentOrder = [[RCHOrder alloc] init];
    }
    return _currentOrder;
}

- (RCHOrderRequest *)orderRequest
{
    if(_orderRequest == nil)
    {
        _orderRequest = [[RCHOrderRequest alloc] init];
    }
    return _orderRequest;
}


@end
