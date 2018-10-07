//
//  RCHTradesViewController.m
//  richcore
//
//  Created by WangDong on 2018/6/26.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTradesViewController.h"
#import "RCHHistoryOrdersController.h"
#import "RCHCurrentOrdersController.h"
#import "RCHMarketsController.h"
#import "RCHTradeController.h"
#import "SPPageMenu.h"
#import "RCHAlertView.h"
#import "RCHTradeController.h"
#import "RCHTradeDetailController.h"

@interface RCHTradesViewController () <SPPageMenuDelegate, UIScrollViewDelegate>
{
    BOOL _ready;

    NSMutableArray *_categorys;
}

@property (nonatomic, weak) SPPageMenu *pageMenu;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *myChildViewControllers;
@property (nonatomic, strong) NSArray *asks;
@property (nonatomic, strong) NSArray *bids;
@property (nonatomic, assign) RCHAgencyAim agencyAim;
@property (nonatomic, assign) CGFloat menuHeight;

@end

@implementation RCHTradesViewController

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentMarketChanged:) name:kCurrentMarketChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tickerUpdated:) name:kTickerUpdatedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessfull:) name:kLoginDidSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccessfull:) name:kLogoutDidSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agencyAim:) name:kAgencyAimNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:kReceiveMessageNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    
    self.menuHeight = 36.0f;
    [self setNavigationTitle];
    
    self.agencyAim = [[RCHHelper valueForKey:kCurrentTradeType] integerValue];
    if ([[RCHHelper valueForKey:kCanShowCreateOrderNotice] boolValue]) {
        [RCHHelper setValue:[NSNumber numberWithBool:NO] forKey:kCanShowCreateOrderNotice];
        [self showAttention];
    }
    

    
    [self createBaseUI];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - getter

- (NSMutableArray *)myChildViewControllers {
    
    if (!_myChildViewControllers) {
        _myChildViewControllers = [NSMutableArray array];
        
    }
    return _myChildViewControllers;
}

#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 这一步是实现跟踪器时刻跟随scrollView滑动的效果,如果对self.pageMenu.scrollView赋了值，这一步可省
    // [self.pageMenu moveTrackerFollowScrollView:scrollView];
}



#pragma mark -
#pragma mark - CustomFuction

- (void)createBaseUI
{
    [self removeAllItems];
    [self.pageMenu removeFromSuperview];
    
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    _categorys = [self getCategorys];
    if (market.is_auction) {
        if (market.auction_stage == 3) {
            self.menuHeight = 36.0f;
        } else {
            self.menuHeight = 0.0f;
        }
    } else {
        self.menuHeight = 36.0f;
    }
    
    [self createControllers:_categorys];
    
    CGFloat scrollHeight = (kMainScreenHeight - kTabBarHeight - kNavigationBarHeight - self.menuHeight);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kAppOriginY + self.menuHeight, kMainScreenWidth, scrollHeight)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
    [self createPageMenu:_categorys];
    
    // 这一行赋值，可实现pageMenu的跟踪器时刻跟随scrollView滑动的效果
    self.pageMenu.bridgeScrollView = self.scrollView;
    
    // pageMenu.selectedItemIndex就是选中的item下标
    if (self.pageMenu.selectedItemIndex < self.myChildViewControllers.count) {
        UIViewController *baseController = self.myChildViewControllers[self.pageMenu.selectedItemIndex];
        [scrollView addSubview:baseController.view];
        baseController.view.frame = CGRectMake(kMainScreenWidth*self.pageMenu.selectedItemIndex, 0, kMainScreenWidth, scrollHeight);
        scrollView.contentOffset = CGPointMake(kMainScreenWidth*self.pageMenu.selectedItemIndex, 0);
        scrollView.contentSize = CGSizeMake(_categorys.count*kMainScreenWidth, 0);
    }
}

- (void)showAttention
{
    NSString *s1 = @"“交易即挖矿” 模式已上线，\n";
    NSString *s2 = @"支持交易挖矿的交易对";
    NSString *s3 = @"及挖矿最新\n动态，请注意查看公告。";
    NSString *title = [NSString stringWithFormat:@"%@%@%@",s1,s2,s3];
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [titleParagraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, [title length])];
    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f] range:NSMakeRange(0, [title length])];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange(0, [s1 length])];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:kYellowColor range:NSMakeRange([s1 length], [s2 length])];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange([s2 length] + [s1 length], [s3 length])];
    
    [RCHAlertView showAlertWithTitle:nil description:attributedString1 imageName:@"pic_bell" buttonTitle:@"我知道了" type:RCHAlertViewInfo];
}

- (NSMutableArray *)getCategorys {
    NSMutableArray *categorys = [NSMutableArray array];
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];

#ifdef TEST_MODE_CORP
    if ([currentMarket.coin.code isEqualToString:@"RCTKK"]) {
        currentMarket.auction_stage = 2;
    }
#endif
    
    if (currentMarket.is_auction && currentMarket.auction_stage != 3) {
        //标题栏为空
        [categorys addObject:NSLocalizedString(@"买入", nil)];
    } else {
        [categorys addObject:NSLocalizedString(@"买入", nil)];
        [categorys addObject:NSLocalizedString(@"卖出", nil)];
        
#ifdef TEST_MODE_CORP
        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        if ([market.coin.code isEqualToString:@"RCTRR"]) {
            [categorys addObject:NSLocalizedString(@"自动", nil)];
        } else {
            if (currentMarket.isMining) {
                [categorys addObject:NSLocalizedString(@"自动", nil)];
            }
        }
#else
        if (currentMarket.isMining) {
            [categorys addObject:NSLocalizedString(@"自动", nil)];
        }
#endif
        

    }
//    if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
//        [categorys addObject:NSLocalizedString(@"当前委托", nil)];
//    }

    return categorys;
}

- (void)createPageMenu:(NSArray *)categorys {
    
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, kAppOriginY, kMainScreenWidth, self.menuHeight) trackerStyle:SPPageMenuTrackerStyleLine];
    [pageMenu setItems:categorys selectedItemIndex:0];
    [pageMenu setSelectedItemTitleColor:kAppOrangeColor];
    [pageMenu setUnSelectedItemTitleColor:kligthWiteColor];
    if (categorys.count == 1) {
        pageMenu.tracker.backgroundColor = [UIColor clearColor];
    } else {
        pageMenu.tracker.backgroundColor = kAppOrangeColor;
    }
    pageMenu.tracker.backgroundColor = kAppOrangeColor;
    pageMenu.dividingLine.backgroundColor = [UIColor clearColor];
    pageMenu.itemTitleFont = [UIFont systemFontOfSize:15.0f];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    pageMenu.contentInset = UIEdgeInsetsMake(2.0f, 4.0f, 0.0f, 4.0f);
    pageMenu.dividingLineHeight = 0.0f;
    [pageMenu setBackgroundColor:kNavigationColor_MB];
    if (categorys.count > self.agencyAim) {
        [pageMenu setSelectedItemIndex:self.agencyAim];
    }
    pageMenu.delegate = self;
    [self.view addSubview:pageMenu];
    _pageMenu = pageMenu;
}

- (void)createControllers:(NSArray *)categorys {
    
    RCHBaseViewController *viewcontroller;
    for (NSString *category in categorys) {
        if ([category isEqualToString:NSLocalizedString(@"买入", nil)]) {
            viewcontroller = [[RCHTradeController alloc] initWithType:RCHAgencyAimBuy];
        } else if ([category isEqualToString:NSLocalizedString(@"卖出", nil)]) {
            viewcontroller = [[RCHTradeController alloc] initWithType:RCHAgencyAimSell];
        } else if ([category isEqualToString:NSLocalizedString(@"自动", nil)]) {
//            viewcontroller = [[RCHAutoTradeController alloc] init];
            viewcontroller = [[RCHTradeController alloc] initWithType:RCHAgencyAimAuto];
        } else if ([category isEqualToString:NSLocalizedString(@"当前委托", nil)]) {
            viewcontroller = [[RCHCurrentOrdersController alloc] initWithStyle:UITableViewStyleGrouped];
        } else {
            viewcontroller = [[RCHBaseViewController alloc] init];
        }
        
        viewcontroller.offsetY = self.menuHeight;
        if ([viewcontroller isKindOfClass:[RCHTradeController class]]) {
            [(RCHTradeController *)viewcontroller setAsks:@[] bids:@[]];
        }
        [self addChildViewController:viewcontroller];
        [self.myChildViewControllers addObject:viewcontroller];
    }
}

- (UIView *)getTitleView
{
    CGFloat height = kNavigationBarHeight;
    CGFloat width = 160.0f;
    UIView *titleView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 0.0f},{width, height}}];
    titleView.backgroundColor = [UIColor clearColor];
    
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleView.bounds];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17.0f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = _ready && currentMarket ? [NSString stringWithFormat:@"%@/%@", currentMarket.coin.code, currentMarket.currency.code] : @"Loading...";
    [titleView addSubview:titleLabel];
    [titleLabel sizeToFit];
    titleLabel.k_height = height;
    titleLabel.center = titleView.center;
    
    UIImage *image = RCHIMAGEWITHNAMED(@"ico_arrow_trade");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{titleLabel.right + 5.0f , (titleView.height - image.size.height) / 2.0f}, image.size}];
    imageView.image = image;
    imageView.hidden = !_ready || currentMarket == nil;
    [titleView addSubview:imageView];
    
    return titleView;
}

- (void)setNavigationTitle
{
    self.k_navgationBar.titleView = [self getTitleView];
}

#pragma mark -
#pragma mark -  NavigationDataSource

- (UIView *)RCHNavigationBarTitleView:(RCHNavigationBar *)navigationBar
{
    return [self getTitleView];
}

- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar
{
    rightButton.imageView.contentMode = UIViewContentModeBottom;
    rightButton.k_size = (CGSizeMake(34.0f, 44.0f));
    UIImage *image = RCHIMAGEWITHNAMED(@"btn_trade_order");
    return image;
}

- (UIImage *)RCHNavigationBarLeftButtonImage:(UIButton *)leftButton navigationBar:(RCHNavigationBar *)navigationBar
{
    leftButton.imageView.contentMode = UIViewContentModeBottom;
    leftButton.k_size = (CGSizeMake(34.0f, 44.0f));
    UIImage *image = RCHIMAGEWITHNAMED(@"btn_quotes_detail");
    return image;
}

#pragma mark -
#pragma mark -  NavigationDelegate

-(void)leftButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RCHTradeDetailController *viewcontroller = [[RCHTradeDetailController alloc] init];
        viewcontroller.canChangeMarket = NO;
        if (!RCHIsEmpty(weakself.asks) && !RCHIsEmpty(weakself.bids)) {
            [viewcontroller setAsks:weakself.asks bids:weakself.bids];
        }
        [self.navigationController pushViewController:viewcontroller animated:YES];
    });
}


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

-(void)titleClickEvent:(UILabel *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    if (!_ready) {
        return;
    }
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself titleButtonClickd:nil];
    });
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)titleButtonClickd:(id)sender
{
    if (![[RCHGlobal sharedGlobal] currentMarket]) return;
    
    RCHMarketsController *controller = [[RCHMarketsController alloc] init];
    RCHNavigationController *navigationController = [[RCHNavigationController alloc] initWithRootViewController:controller];
    [navigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    PresentModalViewControllerAnimated(self, navigationController,YES);
    
}


#pragma mark -
#pragma mark - Notification

- (void)currentMarketChanged:(NSNotification *)notification
{
    [self setNavigationTitle];
    [self createBaseUI];
}


- (void)tickerUpdated:(NSNotification *)notification
{
    if ([[RCHGlobal sharedGlobal] currentMarket] && [[notification.userInfo objectForKey:@"symbol"] isEqualToString:[[[RCHGlobal sharedGlobal] currentMarket] symbol]]) {
        if (!_ready) {
            if ([[[RCHGlobal sharedGlobal] currentMarket] state]) {
                _ready = YES;
            } else {
                _ready = NO;
            }
            [self setNavigationTitle];
        }

    }
}

- (void)receiveMessage:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"event"] isEqualToString:@"DEPTH"]) {
        self.asks = [[[notification userInfo] objectForKey:@"data"] objectForKey:@"asks"];
        self.bids = [[[notification userInfo] objectForKey:@"data"] objectForKey:@"bids"];
    }
}


- (void)logoutSuccessfull:(NSNotification *)notification
{
    for (NSInteger index = 0; index < self.myChildViewControllers.count; index ++) {
        NSString *title = [self.pageMenu titleForItemAtIndex:index];
        if ([title isEqualToString:NSLocalizedString(@"买入", nil)] || [title isEqualToString:NSLocalizedString(@"卖出", nil)]  || [title isEqualToString:NSLocalizedString(@"自动", nil)]) {
            continue;
        }
        [self removeItemAtIndex:index];
    }
    
}

- (void)loginSuccessfull:(NSNotification *)notification
{
    if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
        RCHCurrentOrdersController *viewcontroller = [[RCHCurrentOrdersController alloc] initWithStyle:UITableViewStyleGrouped];
        [self insertItemWithTitle:NSLocalizedString(@"当前委托", nil) controller:viewcontroller toIndex:self.myChildViewControllers.count];
    }
}

- (void)agencyAim:(NSNotification *)notification
{
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
    
    if (!currentMarket.is_auction) {
        self.agencyAim = [[[notification userInfo] objectForKey:@"aim"] integerValue];
        [self.pageMenu setSelectedItemIndex:self.agencyAim];
        
        self.asks = [[notification userInfo] objectForKey:@"asks"];
        self.bids = [[notification userInfo] objectForKey:@"bids"];
    }
}


#pragma mark - SPPageMenu的代理方法

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    NSLog(@"%zd------->%zd",fromIndex,toIndex);
    // 如果fromIndex与toIndex之差大于等于2,说明跨界面移动了,此时不动画.

    if (labs(toIndex - fromIndex) >= 2) {
        [self.scrollView setContentOffset:CGPointMake(kMainScreenWidth * toIndex, 0) animated:NO];
    } else {
        [self.scrollView setContentOffset:CGPointMake(kMainScreenWidth * toIndex, 0) animated:YES];
    }
    if (self.myChildViewControllers.count <= toIndex) {return;}
    
    UIViewController *targetViewController = self.myChildViewControllers[toIndex];
    // 如果已经加载过，就不再加载
    
    if ([targetViewController isViewLoaded]) {
        if ([targetViewController isKindOfClass:[RCHCurrentOrdersController class]]) {
            [(RCHCurrentOrdersController *)targetViewController refresh];
        }
        return;
    }
    
    CGFloat scrollHeight = (kMainScreenHeight - kTabBarHeight - kNavigationBarHeight - self.menuHeight);
    targetViewController.view.frame = CGRectMake(kMainScreenWidth * toIndex, 0, kMainScreenWidth, scrollHeight);
    [_scrollView addSubview:targetViewController.view];
    
}


- (void)insertItemWithTitle:(id)object controller:(RCHBaseViewController *)controller toIndex:(NSInteger)insertNumber {
    // 插入之前，先将新控制器之后的控制器view往后偏移
    CGFloat scrollHeight = (kMainScreenHeight - kTabBarHeight - kNavigationBarHeight - self.menuHeight);
    for (int i = 0; i < self.myChildViewControllers.count; i++) {
        if (i >= insertNumber) {
            UIViewController *childController = self.myChildViewControllers[i];
            childController.view.frame = CGRectMake(kMainScreenWidth * (i+1), 0, kMainScreenWidth, scrollHeight);
            [self.scrollView addSubview:childController.view];
        }
    }
    if (insertNumber <= self.pageMenu.selectedItemIndex && self.myChildViewControllers.count) { // 如果新插入的item在当前选中的item之前
        // scrollView往后偏移
        self.scrollView.contentOffset = CGPointMake(kMainScreenWidth*(self.pageMenu.selectedItemIndex+1), 0);
    } else {
        self.scrollView.contentOffset = CGPointMake(0, 0);
    }
    
    [self addChildViewController:controller];
    [self.myChildViewControllers insertObject:controller atIndex:insertNumber];
    
    // 要先添加控制器，再添加item，如果先添加item，会立即调代理方法，此时myChildViewControllers的个数还是0，在代理方法中retun了
    if ([object isKindOfClass:[NSString class]]) {
        [self.pageMenu insertItemWithTitle:object atIndex:insertNumber animated:YES];
    } else {
        [self.pageMenu insertItemWithImage:object atIndex:insertNumber animated:YES];
    }
    
    // 重新设置scrollView容量
    self.scrollView.contentSize = CGSizeMake(kMainScreenWidth*self.myChildViewControllers.count, 0);
}

- (void)removeItemAtIndex:(NSInteger)index {
    
    //判断删除是否越界
    if (index >= self.myChildViewControllers.count) {
        return;
    }
    
    [self.pageMenu removeItemAtIndex:index animated:YES];
    
    // 删除之前，先将新控制器之后的控制器view往前偏移
    CGFloat scrollHeight = (kMainScreenHeight - kTabBarHeight - kNavigationBarHeight - self.menuHeight);
    for (int i = 0; i < self.myChildViewControllers.count; i++) {
        if (i >= index) {
            UIViewController *childController = self.myChildViewControllers[i];
            childController.view.frame = CGRectMake(kMainScreenWidth * (i>0?(i-1):i), 0, kMainScreenWidth, scrollHeight);
            [self.scrollView addSubview:childController.view];
        }
    }
    if (index <= self.pageMenu.selectedItemIndex) { // 移除的item在当前选中的item之前
        // scrollView往前偏移
        NSInteger offsetIndex = self.pageMenu.selectedItemIndex-1;
        if (offsetIndex < 0) {
            offsetIndex = 0;
        }
        self.scrollView.contentOffset = CGPointMake(kMainScreenWidth*offsetIndex, 0);
    }
    
    UIViewController *vc = [self.myChildViewControllers objectAtIndex:index];
    [self.myChildViewControllers removeObjectAtIndex:index];
    [vc removeFromParentViewController];
    [vc.view removeFromSuperview];
    
    // 重新设置scrollView容量
    self.scrollView.contentSize = CGSizeMake(kMainScreenWidth*self.myChildViewControllers.count, 0);
}

- (void)removeAllItems {
    [self.pageMenu removeAllItems];
    for (UIViewController *vc in self.myChildViewControllers) {
        [vc removeFromParentViewController];
        [vc.view removeFromSuperview];
    }
    [self.myChildViewControllers removeAllObjects];
}

@end
