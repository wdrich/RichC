//
//  RCHTradeController.m
//  richcore
//
//  Created by WangDong on 2018/7/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTradeController.h"
#import "RCHCurrentOrdersController.h"
#import "RCHOrderCell.h"
#import "RCHOrderRequest.h"
#import "RCHTradeView.h"
#import "RCHAuctionView.h"
#import "RCHEmptyDataView.h"
#import "RCHAlertView.h"

#define defaultCellHeight 100.0f

@interface RCHTradeController () <RCHOrderCellDelegate>
{
    RCHAgencyType _agencyType;
    RCHAgencyAim _agencyAim;
    RCHTradeView *_tradeView;
    RCHAuctionView *_auctionView;
}

@property (nonatomic, strong) RCHOrder *currentOrder;
@property (nonatomic, assign) NSInteger  pageSize;
@property (nonatomic, assign) NSInteger  page;
//@property (nonatomic, assign) BOOL cellUpdating;
@property (nonatomic, strong) NSMutableArray *orders;
@property (nonatomic, strong) NSArray *asks;
@property (nonatomic, strong) NSArray *bids;
@property (nonatomic, strong) NSArray *wallets;
@property (nonatomic, strong) NSArray *currentChangeOrders;
@property (nonatomic, strong) RCHAuction *auction;
@property (nonatomic, strong) RCHAuctionTx *auctionTx;

@property (nonatomic, strong) RCHOrderRequest *orderRequest;

@end

@implementation RCHTradeController

- (id)initWithType:(RCHAgencyAim)aim {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _agencyType = RCHAgencyTypeLimit;
        _agencyAim = aim;
        [[NSNotificationCenter defaultCenter] postNotificationName:kReconnectWebsocketeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(currentMarketChanged:)
                                                     name:kCurrentMarketChangedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tickerUpdated:)
                                                     name:kTickerUpdatedNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMessage:)
                                                     name:kReceiveMessageNotification
                                                   object:nil];
        

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"交易",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    [self initKeyboard];
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.bottom += kMainStatusBarHeight;
    self.tableView.contentInset = edgeInsets;
//    [self.tableView.mj_header beginRefreshing];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = [self createHeaderView];
    self.tableView.tableFooterView = [[RCHEmptyDataView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, 40.0f}} text:NSLocalizedString(@"",nil)];

    [self updateCells:self.currentChangeOrders];
    
    //开启orders数组的监听 KVO
//    [self addObserver:self forKeyPath:@"orders" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.tableView.mj_footer.hidden = YES;
    self.tableView.mj_header.hidden = NO;
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

- (void)dealloc
{
    
}


#pragma mark -
#pragma mark - CustomFuction

- (void)initKeyboard {
    // 键盘
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = NO;
    manager.enableAutoToolbar = YES;
    manager.toolbarTintColor = kFontLightGrayColor;
    manager.shouldPlayInputClicks = NO;
    manager.toolbarDoneBarButtonItemText = NSLocalizedString(@"完成",nil);
    manager.shouldShowToolbarPlaceholder = YES;
    manager.previousNextDisplayMode = IQPreviousNextDisplayModeAlwaysHide;
}

- (void)loadMore:(BOOL)isMore
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReconnectWebsocketeNotification object:nil];
    [self endHeaderFooterRefreshing];
}

- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids
{
    self.asks = asks;
    self.bids = bids;    
    [_tradeView setAsks:_asks bids:_bids];
}

- (NSArray *)getDiffer:(NSArray *)olds :(NSArray *)news
{
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    //找到news中有,olds中没有的数据
    [news enumerateObjectsUsingBlock:^(RCHOrder *order1, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL isHave = NO;
        [olds enumerateObjectsUsingBlock:^(RCHOrder *order2, NSUInteger idx, BOOL * _Nonnull stop) {
            if ((order1.order_id == order2.order_id) && [order1.filledAmount compare:order2.filledAmount] == NSOrderedSame) {
                isHave = YES;
                *stop = YES;
            }
        }];
        if (!isHave) {
            [array addObject:order1];
        }
    }];
    
    //找到olds中有,news中没有的数据
    [olds enumerateObjectsUsingBlock:^(RCHOrder *order1, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL isHave = NO;
        [news enumerateObjectsUsingBlock:^(RCHOrder *order2, NSUInteger idx, BOOL * _Nonnull stop) {
            if (order1.order_id == order2.order_id) {
                isHave = YES;
                *stop = YES;
            }
        }];
        if (!isHave) {
            [array addObject:order1];
        }
    }];
    return array;
}

- (void)updateCells:(NSArray *)currentOrders
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.orders];
    NSArray *diffs =  [self getDiffer:array :currentOrders];
    diffs = [diffs valueForKeyPath:@"@distinctUnionOfObjects.self"]; //数组去重

    [diffs enumerateObjectsUsingBlock:^(RCHOrder *order, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([array containsObject:order]) {
            __block BOOL isAmountEqual = NO;
            [array enumerateObjectsUsingBlock:^(RCHOrder *o, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([o.filledAmount compare:order.filledAmount] == NSOrderedSame) {
                    isAmountEqual = YES;
                    *stop = YES;
                }
            }];
            if (isAmountEqual) { //订单存在 且成交数量完全相同
                [self removeCell:order];
            } else {
                [self reloadCell:order];
            }
        } else {
            [self insterCell:order];
        }
    }];
}

- (void)insterCell:(RCHOrder *)order
{
    NSLog(@"=======begin insert=========");
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.orders insertObject:order atIndex:0];
    [self.tableView beginUpdates];
    if (self.orders.count == 1 && [self.tableView numberOfRowsInSection:0] > 0) {
        [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView insertRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    [self.tableView endUpdates];
}
 

- (void)removeCell:(RCHOrder *)order
{
    NSInteger row = [self.orders indexOfObject:order];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        
        [self.orders removeObject:order];
        [self.tableView beginUpdates];
        if (self.orders.count == 0){
            [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationLeft];
        }

        [self.tableView endUpdates];
    }
}

- (void)reloadCell:(RCHOrder *)order
{
    NSLog(@"=======begin reload=========");
    NSInteger row = [self.orders indexOfObject:order];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.orders replaceObjectAtIndex:indexPath.row withObject:order];
    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

- (void)tableviewReload
{
    RCHDispatch_main_sync_safe(^{
        if ([self.orders count]) {
            self.tableView.scrollEnabled = YES;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        } else {
            self.tableView.scrollEnabled = YES;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [self.tableView reloadData];
    });
}

- (UIView *)createHeaderView
{
    CGFloat tradeviewHeight = 478.0f;
    CGFloat top = 0;
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
    top = ((currentMarket.is_auction && _agencyAim != RCHAgencyAimAuto) ? 165.0f : 0.0f);
    UIView *headView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, tradeviewHeight + top + 10.0f}}];
    headView.backgroundColor = [UIColor whiteColor];
    
    if (currentMarket.is_auction && _agencyAim != RCHAgencyAimAuto) {
        _auctionView = [[RCHAuctionView alloc] init];
        [_auctionView setAuctionInfo:_auction];
        [_auctionView setAuctionTxInfo:_auctionTx];
        [headView addSubview:_auctionView];
        [_auctionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15.0f);
            make.left.mas_equalTo(10.0f);
            make.right.mas_equalTo(-10.0f);
            make.height.mas_equalTo(150.0f);
        }];
        
    }

    RCHWeak(self);
    _tradeView = [[RCHTradeView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, tradeviewHeight}} type:_agencyAim];
    [_tradeView setAsks:self.asks bids:self.bids];
    [_tradeView setCurrentWallets:self.wallets];
    _tradeView.showHelp = ^{
        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        if (market.is_auction) {
            RCHWebViewController *webviewController = [[RCHWebViewController alloc] init];
            webviewController.gotoURL = @"https://support.richcore.com/hc/zh-cn/articles/360008290832";
            [weakself.navigationController pushViewController:webviewController animated:YES];
        } else {
            [weakself showNotice];
        }
        
    };
    NSLog(@"%@", NSStringFromCGRect(self.tableView.tableHeaderView.frame));
    [headView addSubview:_tradeView];
    
    [_tradeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(top);
        make.left.right.mas_equalTo(0.0f);
        make.height.mas_equalTo(tradeviewHeight);
    }];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kTabbleViewBackgroudColor;
    [headView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(headView.mas_bottom);
        make.left.right.mas_equalTo(0.0f);
        make.height.mas_equalTo(10.0f);
    }];
    
    
    
    
    return headView;
}

- (void)showSuccess:(BOOL)flag
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake((kMainScreenWidth - 134) / 2, (kMainScreenHeight - kAppOriginY - pageMenuHeight - kTabBarHeight - 46) / 2, 134, 46)];
    view.backgroundColor = kTextUnselectColor;
    view.layer.cornerRadius = 2;
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(20, (view.height - 24) / 2, 24, 24)];
    icon.backgroundColor = [UIColor clearColor];
    [view addSubview:icon];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(54, (view.height - 16) / 2, view.width - 74, 16)];
    text.backgroundColor = [UIColor clearColor];
    text.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.f];
    text.textColor = [UIColor whiteColor];
    [view addSubview:text];
    
    if (flag) {
        text.text = @"委托成功";
        [icon setImage:RCHIMAGEWITHNAMED(@"agency_success")];
    } else {
        text.text = @"委托失败";
        [icon setImage:RCHIMAGEWITHNAMED(@"ico_notice_fail")];
    }
    
    [self.view addSubview:view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view removeFromSuperview];
    });
}

- (void)showNotice
{
    NSString *title = @"使用自动交易";
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *attributedTitleStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedTitleStyle setAlignment:NSTextAlignmentCenter];
    [attributedTitle addAttribute:NSParagraphStyleAttributeName value:attributedTitleStyle range:NSMakeRange(0, [title length])];
    [attributedTitle addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:15.0f] range:NSMakeRange(0, [title length])];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange(0, [title length])];
    
    
    title = NSLocalizedString(@"自动交易订单：按照市场最新价 ± 挂单间隔，自动挂出买卖单，每组买卖单成交后自动挂下一组；达到挂单最低或最高价格后，停止自动挂单。\n\n注：离开当前自动交易页面、或锁屏网络断开等，会停止自动挂单，请注意保持当前页面的网络连接。",nil);
    NSArray *array = [title componentsSeparatedByString:@"\n\n"];
    CGFloat secondLength =  [array count] > 1 ? [[array objectAtIndex:1] length] : 0;
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [titleParagraphStyle setAlignment:NSTextAlignmentLeft];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, [title length])];
    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:13.0f] range:NSMakeRange(0, [title length])];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:kFontGrayColor range:NSMakeRange(0, [title length] - secondLength)];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:kYellowColor range:NSMakeRange([title length] - secondLength, secondLength)];
    
    [RCHAlertView showAlertWithTitle:attributedTitle description:attributedString1 imageName:nil buttonTitle:NSLocalizedString(@"我知道了",nil) type:RCHAlertViewNotice];
}


#pragma mark - kvo的回调方法(系统提供的回调方法)

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"orders"]) {
//        [self tableviewReload];
//    }
//}

#pragma mark -
#pragma mark - Notification

- (void)currentMarketChanged:(NSNotification *)notification
{
    [self.orders removeAllObjects];
    [self.tableView reloadData];
}

- (void)tickerUpdated:(NSNotification *)notification
{
    NSString *symbol = [notification.userInfo objectForKey:@"symbol"];
    [_tradeView refreshPrice:symbol];
}


- (void)receiveMessage:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"event"] isEqualToString:@"DEPTH"]) {
        self.asks = [[[notification userInfo] objectForKey:@"data"] objectForKey:@"asks"];
        self.bids = [[[notification userInfo] objectForKey:@"data"] objectForKey:@"bids"];
        [_tradeView setAsks:self.asks bids:self.bids];
    } else if ([[[notification userInfo] objectForKey:@"event"] isEqualToString:@"WALLET"]) {
        self.wallets = [[notification userInfo] objectForKey:@"data"];
        [_tradeView setCurrentWallets:self.wallets];
    } else if ([[[notification userInfo] objectForKey:@"event"] isEqualToString:@"CURRENT_AGENCY"]) {
        
        NSArray *orders = (NSArray *)[[notification userInfo] objectForKey:@"data"];
        self.currentChangeOrders = orders;
        [_tradeView changeCurrentOrders:orders];
        if ([self isViewLoaded]) {
            [self updateCells:orders];
        }
    } else if ([[[notification userInfo] objectForKey:@"event"] isEqualToString:@"AUCTION_SUMMARY"]) {
        _auction = [[notification userInfo] objectForKey:@"data"];
        [_auctionView setAuctionInfo:_auction];
    } else if ([[[notification userInfo] objectForKey:@"event"] isEqualToString:@"AUCTION_TXS"]) {
        _auctionTx = [[notification userInfo] objectForKey:@"data"];
        [_auctionView setAuctionTxInfo:_auctionTx];
    }
}

#pragma mark -
#pragma mark - Request

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
#pragma mark Implements UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat originX = 15.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:section]];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17.0f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"当前委托";
    titleLabel.textColor = kNavigationColor_MB;
    [view addSubview:titleLabel];
    [titleLabel sizeToFit];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.0f);
        make.centerY.mas_equalTo(view.mas_centerY);
    }];
    
    UIImage *allImage = RCHIMAGEWITHNAMED(@"ico_trade_order_all");
    CGFloat allWidth = 47.0f;
    UIButton *all = [UIButton buttonWithType:UIButtonTypeCustom];
    [all setTitle:NSLocalizedString(@"全部",nil) forState:UIControlStateNormal];
    [all setImage:allImage forState:UIControlStateNormal];
    [all setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    all.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    all.titleLabel.textAlignment = NSTextAlignmentRight;
    [all setTitleColor:kTradeBorderColor forState:UIControlStateNormal];
    [all addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:all];
    
    all.adjustsImageWhenDisabled = NO;
    all.adjustsImageWhenHighlighted = NO;
    
    
    // button标题的偏移量
    all.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f);
    // button图片的偏移量
    all.imageEdgeInsets = UIEdgeInsetsMake(0.0f, -3.0f, 0.0f, 0.0f);
    
    [all mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(view.mas_centerY);
        make.right.mas_equalTo(-15.0f);
        make.width.mas_equalTo(allWidth);
        make.height.mas_equalTo(18.0f);
    }];

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
    if (self.orders  && [self.orders count] > 0) {
        return [self.orders count];
    }
    else {
        return 1;
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
            cell.separatorX = 15.0f;
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        [cell.contentView removeAllSubviews];
        [cell.contentView addSubview:[[RCHEmptyDataView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, defaultCellHeight}} text:NSLocalizedString(@"暂无委托记录",nil)]];
        
        return cell;
    }
    
}

#pragma mark -
#pragma mark RCHOrderCellDelegate delegate

- (void)RCHOrderCell:(RCHOrderCell *)cell order:(RCHOrder *)order
{
    RCHWeak(self);
    [self revokeRequest:^(NSError *error, WDBaseResponse *response) {
//        weakself.canKVO = NO;
        if (error) {
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
            if (code == 403) {
                [MBProgressHUD showInfo:NSLocalizedString(@"撤单失败", nil) ToView:weakself.view];
            }
            return;
        }
        [MBProgressHUD showInfo:NSLocalizedString(@"撤单成功", nil) ToView:weakself.view];
    } orderId:order.order_id];
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)allButtonClicked:(id)sender
{
    RCHWeak(self);
    RCHDispatch_main_async_safe(^{
        if([RCHHelper gotoLogin]) {
            return;
        }
        RCHCurrentOrdersController *viewcontroller = [[RCHCurrentOrdersController alloc] initWithStyle:UITableViewStyleGrouped];
        [weakself.navigationController pushViewController:viewcontroller animated:YES];
    });
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

- (NSArray *)asks
{
    if(_asks == nil)
    {
        _asks = [NSArray array];
    }
    return _asks;
}

- (NSArray *)bids
{
    if(_bids == nil)
    {
        _bids = [NSArray array];
    }
    return _bids;
}

- (NSArray *)wallets
{
    if(_wallets == nil)
    {
        _wallets = [NSArray array];
    }
    return _wallets;
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
