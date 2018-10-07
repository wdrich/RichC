//
//  RCHTradeDetailController.m
//  richcore
//
//  Created by WangDong on 2018/6/1.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTradeDetailController.h"
#import "RCHTradeController.h"
#import "RCHKlineController.h"
#import "RCHMarketsController.h"
#import "RCHKlineView.h"
#import "RCHTradePriceView.h"
#import "RCHTradeDetailOrderView.h"
#import "ZXAssemblyView.h"

#import "RCHTradingviewRequest.h"

#define kBottomBarHeight 74.0f + TabbarMiniSafeBottomMargin

@interface RCHTradeDetailController () <UIScrollViewDelegate>
{
    BOOL _ready;
}

@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSArray *asks;
@property (nonatomic, strong) NSArray *bids;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) RCHKlineView *kLineview;
@property (nonatomic, weak) RCHTradeDetailOrderView *orderView;
@property (nonatomic, weak) RCHTradePriceView *priceView;
@property (nonatomic, strong) RCHTradingviewRequest *tradingviewRequest;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, copy) NSString *socketResolution;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, copy) NSString *gotoURL;
@property (nonatomic, assign) NSTimeInterval from;

@end

@implementation RCHTradeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kTradeBackLightColor;
    [RCHGlobal sharedGlobal].isPortrait = YES;
    
    [self setNavigationTitle];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kReconnectWebsocketeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentMarketChanged:) name:kCurrentMarketChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tickerUpdated:) name:kTickerUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:kReceiveMessageNotification object:nil];
    
    [self fetchKlineItemsRequest];
    
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(0.0f);
        make.left.mas_equalTo(0.0f);
        make.right.mas_equalTo(self.view).offset(0.0f);
        make.height.mas_equalTo(107.0f);
    }];

    [self.kLineview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceView.mas_bottom).offset(0.0f);
        make.left.mas_equalTo(0.0f);
        make.right.mas_equalTo(self.view).offset(0.0f);
        make.height.mas_equalTo(380.0f);
    }];

    [self.orderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.kLineview.mas_bottom).offset(0.0f);
        make.left.mas_equalTo(0.0f);
        make.right.mas_equalTo(self.view).offset(0.0f);
        make.height.mas_equalTo(20 * 15.0f + 45.0f + 40.0f + 20.0f);
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(kAppOriginY, 0.0f, 0.0f, 0.0f));
        make.bottom.mas_equalTo(self.orderView.mas_bottom).offset(kBottomBarHeight + 20.0f);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.right.left.mas_equalTo(0.0f);
        make.height.mas_equalTo(kBottomBarHeight);
    }];
    
    [self.kLineview bringSubviewToFront:_scrollView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStopKlineWebsocketeNotification object:nil];
    if (self.tradingviewRequest.currentTask) {
        [self.tradingviewRequest.currentTask cancel];
    }
}

#pragma mark -
#pragma mark - CustomFuction

- (void)gotoTrade:(RCHAgencyAim)type
{
    [RCHHelper setValue:[NSNumber numberWithInt:type] forKey:kCurrentTradeType];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:[NSNumber numberWithInteger:type] forKey:@"aim"];
    if (self.bids) {
        [info setObject:self.bids forKey:@"bids"];
    }
    if (self.asks) {
        [info setObject:self.asks forKey:@"asks"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAgencyAimNotification object:nil userInfo:info];
    
    if (self.canChangeMarket) {
        UITabBarController *tabbarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [tabbarController setSelectedIndex:2];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    
    
}

- (UIView *)getTitleView
{
    CGFloat height = kNavigationBarHeight;
    CGFloat width = 220.0f;
    UIView *titleView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 0.0f},{width, height}}];
    
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleView.bounds];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17.0f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titleLabel];

    if (self.canChangeMarket) {
        titleLabel.text = _ready && currentMarket ? [NSString stringWithFormat:@"%@/%@", currentMarket.coin.code, currentMarket.currency.code] : @"Loading...";
    } else {
        titleLabel.text = [NSString stringWithFormat:@"%@/%@", currentMarket.coin.code, currentMarket.currency.code];
    }
    
    [titleLabel sizeToFit];
    titleLabel.k_height = height;
    titleLabel.center = titleView.center;
    
    UIImage *image = RCHIMAGEWITHNAMED(@"ico_arrow_trade");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{titleLabel.right + 5.0f , (titleView.height - image.size.height) / 2.0f}, image.size}];
    imageView.image = image;
    imageView.hidden = !_ready || currentMarket == nil || !self.canChangeMarket;
    [titleView addSubview:imageView];
    
    return titleView;
}


- (void)setNavigationTitle
{
    self.k_navgationBar.titleView = [self getTitleView];
}

- (NSString *)getSocketResolution:(NSInteger)resolution
{
    NSString *result;
    if (resolution < 60) {
        result = [NSString stringWithFormat:@"%ldm", (long)resolution];
    } else if (resolution >= 60 && resolution < 60 * 24) {
        result = [NSString stringWithFormat:@"%ldh", (long)resolution / 60];
    } else {
        result = @"15m";
    }
    return result;
}

- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids {
    self.asks = asks;
    self.bids = bids;
}

#pragma mark -
#pragma mark -  NavigationDataSource

- (UIView *)RCHNavigationBarTitleView:(RCHNavigationBar *)navigationBar
{
    return [self getTitleView];
}

- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar
{
    [self customButtonInfo:rightButton title:NSLocalizedString(@"介绍",nil)];
    return nil;
}

#pragma mark -
#pragma mark -  NavigationDelegate

-(void)rightButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        RCHWebViewController *webviewController = [[RCHWebViewController alloc] init];
        webviewController.gotoURL = market.coin.intro_link;
        webviewController.title = NSLocalizedString(@"介绍",nil);
        [self.navigationController pushViewController:webviewController animated:YES];
    });
}

-(void)titleClickEvent:(UILabel *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    if (!self.canChangeMarket) {
        return;
    }
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

- (void)buy:(id)sender
{
    [self gotoTrade:RCHAgencyAimBuy];
}

- (void)sell:(id)sender
{
    [self gotoTrade:RCHAgencyAimSell];
}

- (void)titleButtonClickd:(id)sender
{
    if (![[RCHGlobal sharedGlobal] currentMarket]) return;
    
    RCHMarketsController *controller = [[RCHMarketsController alloc] init];
    RCHNavigationController *navigationController = [[RCHNavigationController alloc] initWithRootViewController:controller];
    [navigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    PresentModalViewControllerAnimated(self, navigationController,YES);
    
}

#pragma mark -
#pragma mark - Request

- (void)fetchKlineItemsRequest
{
    RCHWeak(self);
    if (weakself.tradingviewRequest.currentTask) {
        [weakself.tradingviewRequest.currentTask cancel];
    }
    
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
    NSString *symbol = [NSString stringWithFormat:@"%@_%@",  currentMarket.coin.code, currentMarket.currency.code];
    
    NSTimeInterval to = [[[NSDate alloc] init] timeIntervalSince1970];
//    NSTimeInterval from = to - (60 * 60 * 24 * 15);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:symbol forKey:@"symbol"];
    [dictionary setObject:[NSNumber numberWithInteger:1] forKey:@"stream"];
//    [dictionary setObject:[NSNumber numberWithDouble:1530281540] forKey:@"from"];
//    [dictionary setObject:[NSNumber numberWithDouble:1531281540] forKey:@"to"];
    [dictionary setObject:[NSString stringWithFormat:@"%0.0f", weakself.from] forKey:@"from"];
    [dictionary setObject:[NSString stringWithFormat:@"%0.0f", to] forKey:@"to"];
    [dictionary setObject:self.resolution ?: @"15" forKey:@"resolution"];
    
    [MBProgressHUD showLoadToView:self.kLineview];
    [weakself.tradingviewRequest history:^(NSObject *response) {
        [MBProgressHUD hideHUDForView:weakself.kLineview];
        if ([response isKindOfClass:[NSMutableArray class]]) {
            [self.datas removeAllObjects];
            NSMutableArray *datas = [NSMutableArray array];
            [(NSMutableArray *)response enumerateObjectsUsingBlock:^(RCHKlineItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
                if (RCHIsEmpty(item) || RCHIsEmpty(item.open) || RCHIsEmpty(item.high) || RCHIsEmpty(item.low) || RCHIsEmpty(item.close) || RCHIsEmpty(item.volume)) {
                    //数据不符合要求
                } else {
                    [datas addObject:item];
                }
            }];
            [weakself.kLineview setDatas:datas];
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    } info:dictionary];
}

#pragma mark -
#pragma mark - Notification

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        
    }else if (self.orientation==UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
//        RCHKlineController *controller = [[RCHKlineController alloc]init];
//        controller.datas = self.datas;
//        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        PresentModalViewControllerAnimated(self, controller, YES);
    }
}

- (void)currentMarketChanged:(NSNotification *)notification
{
    [self.orderView setMarket:[[RCHGlobal sharedGlobal] currentMarket]];
    [self.priceView refreshPrice];
    [self fetchKlineItemsRequest];
    [self setNavigationTitle];
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
        [self.priceView refreshPrice];
    }
}

- (void)receiveMessage:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"event"] isEqualToString:@"DEPTH"]) {
        [self.orderView setAsks:[[[notification userInfo] objectForKey:@"data"] objectForKey:@"asks"]
                                bids:[[[notification userInfo] objectForKey:@"data"] objectForKey:@"bids"]];
    }
}

#pragma mark -
#pragma mark - getter

- (UIView *)orderView
{
    RCHWeak(self);
    if(!_orderView)
    {
        RCHTradeDetailOrderView *orderView = [[RCHTradeDetailOrderView alloc] initWithFrame:CGRectZero];
        [self.scrollView addSubview:orderView];
//        orderView.precisionChanged = ^(NSString *text) {
//            [MBProgressHUD showInfo:text ToView:orderView];
//        };
        [orderView setMarket:[[RCHGlobal sharedGlobal] currentMarket]];
        _orderView = orderView;
        [_orderView setAsks:weakself.asks bids:weakself.bids];
    }
    return _orderView;
}


- (UIScrollView *)scrollView
{
    if(!_scrollView)
    {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){{}, {}}];
        scrollView.backgroundColor = kTradeBackColor;
        scrollView.delegate = self;
        scrollView.pagingEnabled = NO;//进行分页
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = YES;
        scrollView.tag = 0;
        scrollView.scrollEnabled = YES;
        [self.view addSubview:scrollView];
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (RCHKlineView *)kLineview
{
    if(!_kLineview)
    {
        RCHWeak(self);
        RCHKlineView *kLineview = [[RCHKlineView alloc] initWithFrame:CGRectZero];
        kLineview.fullScreen = ^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                RCHKlineController *controller = [[RCHKlineController alloc]init];
//                controller.datas = weakself.datas;
//                controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//                PresentModalViewControllerAnimated(weakself, controller, YES);
//            });
        };
        kLineview.reloadBlock = ^(NSInteger resolution) {
            NSTimeInterval to = [[[NSDate alloc] init] timeIntervalSince1970];
            NSTimeInterval oneMinute = 60 * 60 * 8;
            if (resolution == KlineModelTypeWeek) {
                weakself.resolution = @"1W";
                weakself.from = to - (oneMinute * 60 * 24 * 7);
                [[RCHGlobal sharedGlobal] setResolution:weakself.resolution.lowercaseString];
            } else if (resolution == KlineModelTypeDay) {
                weakself.resolution = @"1D";
                weakself.from = to - (oneMinute * 60 * 24);
                [[RCHGlobal sharedGlobal] setResolution:weakself.resolution.lowercaseString];
            } else {
                weakself.resolution = [NSString stringWithFormat:@"%ld", (long)resolution];
                weakself.from = to - (oneMinute * resolution);
                [[RCHGlobal sharedGlobal] setResolution:[weakself getSocketResolution:resolution]];
            }
            
            [weakself fetchKlineItemsRequest];            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeResolutionChangedNotification object:nil];
        };
        [self.scrollView addSubview:kLineview];
        _kLineview = kLineview;
    }
    return _kLineview;
}

- (RCHTradePriceView *)priceView
{
    if(!_priceView)
    {
        RCHTradePriceView *priceView = [[RCHTradePriceView alloc] initWithFrame:CGRectZero];
        [self.scrollView addSubview:priceView];
        _priceView = priceView;
        
    }
    return _priceView;
}

- (UIView *)bottomView
{
    if(!_bottomView)
    {
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        [bottomView setBackgroundColor:kTradeBackLightColor];
        [self.view addSubview:bottomView];
        
        UIButton *buy = [UIButton buttonWithType:UIButtonTypeCustom];
        //    buy.frame = (CGRect){{originX, originY}, {butttonWidth, butttonHeight}};
        buy.layer.cornerRadius = 2.0f;
        buy.layer.masksToBounds = YES;
        buy.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
        [buy setTitle:NSLocalizedString(@"买入", nil) forState:UIControlStateNormal];
        [buy setBackgroundColor:kTradePositiveColor forState:UIControlStateNormal];
        [buy setBackgroundColor:kFontLightGrayColor forState:UIControlStateHighlighted];
        [buy addTarget:self action:@selector(buy:) forControlEvents:UIControlEventTouchUpInside];
        [buy setAdjustsImageWhenHighlighted:NO];
        [bottomView addSubview:buy];
        
        [buy mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15.0f);
            make.left.mas_equalTo(15.0f);
            make.right.mas_equalTo(bottomView.mas_centerX).offset(-5.0f);
            make.height.mas_equalTo(44.0f);
            
        }];
        
        UIButton *sell = [UIButton buttonWithType:UIButtonTypeCustom];
        sell.layer.cornerRadius = 2.0f;
        sell.layer.masksToBounds = YES;
        sell.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
        [sell setTitle:NSLocalizedString(@"卖出", nil) forState:UIControlStateNormal];
        [sell setBackgroundColor:kTradeNegativeColor forState:UIControlStateNormal];
        [sell setBackgroundColor:kFontLightGrayColor forState:UIControlStateHighlighted];
        [sell addTarget:self action:@selector(sell:) forControlEvents:UIControlEventTouchUpInside];
        [sell setAdjustsImageWhenHighlighted:NO];
        [bottomView addSubview:sell];
        
        [sell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15.0f);
            make.left.mas_equalTo(bottomView.mas_centerX).offset(5.0f);
            make.right.mas_equalTo(-15.0f);
            make.height.mas_equalTo(44.0f);
            
        }];
        
        RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
        if (currentMarket.is_auction) {
            sell.hidden = YES;
            [buy mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(15.0f);
                make.left.mas_equalTo(15.0f);
                make.right.mas_equalTo(-15.0);
                make.height.mas_equalTo(44.0f);
            }];
        }
        
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIInterfaceOrientation)orientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (NSString *)gotoURL
{
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
    return [NSString stringWithFormat:@"https://www.richcore.com/m/trend/%@_%@/1",  currentMarket.coin.code, currentMarket.currency.code];
}

- (RCHTradingviewRequest *)tradingviewRequest
{
    if(_tradingviewRequest == nil)
    {
        _tradingviewRequest = [[RCHTradingviewRequest alloc] init];
    }
    return _tradingviewRequest;
}

- (NSMutableArray *)datas
{
    if(_datas == nil)
    {
        _datas = [[NSMutableArray alloc] init];
    }
    return _datas;
}



@end
