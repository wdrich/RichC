//
//  RCHHistoryOrdersController.m
//  richcore
//
//  Created by WangDong on 2018/5/24.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHHistoryOrdersController.h"
#import "MJLPickerActionSheet.h"
#import "RCHEmptyDataView.h"
#import "RCHOrderFilterView.h"
#import "RCHOrderHistoryCell.h"
#import "RCHOrderRequest.h"
#import "SLSlideMenu.h"
#import "RCHOrderDetailViewController.h"

#define defaultCellHeight 72.0f
#define titleHeight 40.0f

@interface RCHHistoryOrdersController () <SLSlideMenuProtocol, MJLPickerActionSheetDelegate>

@property (nonatomic, assign) NSInteger  pageSize;
@property (nonatomic, assign) NSInteger  page;
@property (nonatomic, assign) BOOL  canShowFilter;
@property (nonatomic, strong) NSMutableArray *orders;
@property (nonatomic, strong) NSMutableArray *coins;
@property (nonatomic, strong) RCHOrderRequest *orderRequest;
@property (nonatomic, strong) RCHOrderFilterView *filterView;
@property (nonatomic, copy) NSString *filterCoin;
@property (nonatomic, copy) NSString *filterCurrency;
@property (nonatomic, copy) NSString *filterStatus;

@end

@implementation RCHHistoryOrdersController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"历史委托",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    self.canShowFilter = true;
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.top = 0.0f;
    self.tableView.contentInset = edgeInsets;
    
    self.tableView.frame = (CGRect){{0.0f, kAppOriginY + titleHeight}, {kMainScreenWidth, kMainScreenHeight - titleHeight - kAppOriginY}};
    
    UIView *headView = [self createTItleView];
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kAppOriginY);
        make.left.right.mas_equalTo(0.0f);
        make.height.mas_equalTo(titleHeight);
    }];
    
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss:) name:@"dismissSLSLideMenu" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SLSlideMenu dismiss];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (self.orderRequest.currentTask) {
        [self.orderRequest.currentTask cancel];
    }
}

#pragma mark -
#pragma mark - CustomFuction

- (void)init_info
{
    self.page = 1;
    self.pageSize = 20;
}

- (NSDictionary *)getFliter
{
    NSMutableDictionary *filter = [NSMutableDictionary dictionary];
    if (!RCHIsEmpty(self.filterCoin)) {
        [filter  setObject:self.filterCoin forKey:@"coin"];
    }
    
    if (!RCHIsEmpty(self.filterCurrency)) {
        [filter  setObject:self.filterCurrency forKey:@"currency"];
    }
    
    if (!RCHIsEmpty(self.filterStatus)) {
        [filter  setObject:self.filterStatus forKey:@"status"];
    }
    
    return filter;
}

- (void)loadMore:(BOOL)isMore
{
    if (!isMore) {
        [self init_info];
    }
    [self getOrders];
}

- (UIView *)createTItleView
{
    CGFloat originX = 15.0f;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kLightGreenColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"市场";
    titleLabel.textColor = kTextUnselectColor;
    [view addSubview:titleLabel];
    [titleLabel sizeToFit];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(originX);
        make.centerY.mas_equalTo(view.mas_centerY);
        make.size.mas_equalTo(titleLabel.size);
    }];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:(CGRect){{170.0f, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.userInteractionEnabled = YES;
    priceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.text = @"成交均价/价格";
    priceLabel.textColor = kTextUnselectColor;
    [view addSubview:priceLabel];
    [priceLabel sizeToFit];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(view);
        make.size.mas_equalTo(priceLabel.size);
    }];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.userInteractionEnabled = YES;
    countLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.text = @"成交量/委托量";
    countLabel.textColor = kTextUnselectColor;
    [view addSubview:countLabel];
    [countLabel sizeToFit];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-originX);
        make.centerY.mas_equalTo(view.mas_centerY);
        make.size.mas_equalTo(countLabel.size);
    }];
    
    return view;
}

- (void)tableviewReload
{
    RCHWeak(self);
    [self.tableView configBlankPage:RCHBlankPageViewTypeNoDataOnlyMessage hasData:[_orders count] emptyMessage:@"暂无委托记录" reloadButtonBlock:^(UIButton *sender) {
        [weakself.tableView.mj_header beginRefreshing];
        weakself.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [weakself.tableView reloadData];
    }];
    weakself.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine  ;
    [weakself.tableView reloadData];
}

#pragma mark -
#pragma mark - Notification

- (void)dismiss:(NSNotification *)notification
{
    self.canShowFilter = true;
}

#pragma mark -
#pragma mark - Request

- (void)getOrders
{
    self.tableView.tableFooterView = nil;
    RCHWeak(self);
    if (self.orderRequest.currentTask) {
        [self.orderRequest.currentTask cancel];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@"history" forKey:@"range"];
    [dictionary setObject:[NSNumber numberWithInteger:1] forKey:@"is_page"];
    [dictionary setObject:[NSNumber numberWithInteger:self.pageSize] forKey:@"size"];
    [dictionary setObject:[NSNumber numberWithInteger:self.page] forKey:@"page"];
    if (!RCHIsEmpty(self.filterCoin)) {
        [dictionary setObject:[self.filterCoin uppercaseString] forKey:@"coin"];
    }
    
    if (!RCHIsEmpty(self.filterCurrency)) {
        [dictionary setObject:[self.filterCurrency uppercaseString] forKey:@"currency"];
    }
    
    if (!RCHIsEmpty(self.filterStatus)) {
        [dictionary setObject:self.filterStatus forKey:@"status"];
    }
    
    [self.orderRequest orders:^(NSObject *response) {
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
            if (code == 404) {
                if (weakself.page == 1) {
                    [weakself.orders removeAllObjects];
                }
                self.tableView.mj_footer.hidden = YES;
                [weakself tableviewReload];
                 [MBProgressHUD showError:NSLocalizedString(@"无效的交易对",nil) ToView:self.view];
            } else {
                [RCHHelper showRequestErrorCode:code url:url];
            }
            
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    } info:dictionary];

}

#pragma mark -
#pragma mark -  buttonClicked
- (void)changeBaseCoin
{
    NSString *title = NSLocalizedString(@"",nil);
    MJLPickerActionSheetType type = MJLPickerActionSheetTypeCoin;
    NSObject *object = @[self.coins];
    MJLPickerActionSheet *pickerView = [[MJLPickerActionSheet alloc] initWithTitle:title object:object key:@"coin" type:type];
    [pickerView show];
    pickerView.delegate = self;
    [[[UIApplication sharedApplication] keyWindow] addSubview:pickerView];
}

#pragma mark -
#pragma mark - MJLPickerActionSheetDelegate

- (void)pickerActionSheet:(MJLPickerActionSheet *)sheet didPickerStrings:(NSArray *)pickedStrings key:(NSString *)key
{
    if ([pickedStrings count] > 0) {
        NSDictionary *dic = [pickedStrings objectAtIndex:0];
        [_filterView setCurrency:[dic objectForKey:@"text"]];
    }
}


#pragma mark -
#pragma mark -  NavigationDataSource

- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar
{
    rightButton.imageView.contentMode = UIViewContentModeBottom;
    rightButton.k_size = (CGSizeMake(34.0f, 44.0f));
    UIImage *image = RCHIMAGEWITHNAMED(@"btn_filter");
    return image;
}

#pragma mark -
#pragma mark -  NavigationDelegate

-(void)rightButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([RCHHelper gotoLogin]) {
            return;
        }
        if (self.canShowFilter) {
            self.canShowFilter = false;
            [SLSlideMenu slideMenuWithFrame:CGRectMake(0, kAppOriginY, kMainScreenWidth, kMainScreenHeight) delegate:self direction:SLSlideMenuDirectionTop slideOffset:284.0f allowSwipeCloseMenu:YES aboveNav:NO identifier:@"filter" object:nil];
        } else {
            [SLSlideMenu dismiss];
        }
    });
}

#pragma mark -
#pragma mark -  SLSlideMenuProtocol
- (void)slideMenu:(SLSlideMenu *)slideMenu prepareSubviewsForMenuView:(UIView *)menuView
{
    RCHWeak(self);
    _filterView = [[RCHOrderFilterView alloc] init];
    _filterView.filter = ^(NSDictionary *filter) {
        weakself.filterCoin =  [filter objectForKey:@"coin"] ?: nil;
        weakself.filterCurrency =  [filter objectForKey:@"currency"] ?: nil;
        weakself.filterStatus =  [filter objectForKey:@"status"] ?: nil;
        [SLSlideMenu dismiss];
        
        [weakself.tableView.mj_header beginRefreshing];
    };
    _filterView.changeCoin = ^(void) {
        [weakself changeBaseCoin];
    };
    [_filterView setDefaultFilter:[self getFliter]];
    [menuView addSubview:_filterView];
    
    [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
    [_filterView setBackgroundColor:[UIColor whiteColor]];
    menuView.backgroundColor = [UIColor clearColor];
    [menuView layoutIfNeeded];
}

#pragma mark -
#pragma mark Implements UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [_orders count]) {
        RCHOrder *order = [_orders objectAtIndex:indexPath.row];
        if (order.transactions && order.transactions.count > 0) {
            RCHOrderDetailViewController *controller = [[RCHOrderDetailViewController alloc] initWithOrder:order];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else {
        [MBProgressHUD showError:kRangeError ToView:self.view];
    }
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
        RCHOrderHistoryCell *cell = (RCHOrderHistoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            cell = [[RCHOrderHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
#pragma mark - getter

- (NSArray *)orders
{
    if(_orders == nil)
    {
        _orders = [NSMutableArray array];
    }
    return _orders;
}

- (NSArray *)coins
{
    if(_coins == nil)
    {
        NSMutableArray *groups = [NSMutableArray array];
        for (RCHMarket *market in [[RCHGlobal sharedGlobal] marketsArray]) {
            NSDictionary *theGroup = nil;
            for (NSDictionary *group in groups) {
                if ([[group objectForKey:@"code"] isEqualToString:market.sector.code]) {
                    theGroup = group;
                    break;
                }
            }
            
            if (theGroup == nil) {
                [groups addObject:[NSDictionary dictionaryWithObjectsAndKeys:market.sector.code, @"code", @[market], @"markets", nil]];
            } else {
                [groups replaceObjectAtIndex:[groups indexOfObject:theGroup]
                                  withObject:[NSDictionary dictionaryWithObjectsAndKeys:market.sector.code, @"code", [[theGroup objectForKey:@"markets"] arrayByAddingObject:market], @"markets", nil]];;
            }
        }
        
        _coins = groups;
    }
    return _coins;
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
