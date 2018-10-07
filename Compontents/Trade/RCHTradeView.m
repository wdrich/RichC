//
//  RCHTradeView.m
//  richcore
//
//  Created by WangDong on 2018/7/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTradeView.h"
#import "RCHMarket.h"
#import "RCHMenuCell.h"
#import "RCHRealtimeAgencyView.h"
#import "YBPopupMenu.h"
#import "RCHOrderRequest.h"

@interface RCHTradeView () <UIGestureRecognizerDelegate, YBPopupMenuDelegate>
{
    UILabel *_agencyTypeLabel;
    RCHAgencyType _agencyType;
}

@property (nonatomic, assign) BOOL creatingOrder;
@property (nonatomic, assign) BOOL buySuccess;
@property (nonatomic, assign) BOOL sellSuccess;
@property (nonatomic, assign) RCHAgencyAim agencyAim;
@property (nonatomic, assign) RCHAgencyAim orderAgencyAim;
@property (nonatomic, strong) RCHRealtimeAgencyView *realtimeAgencyView;
@property (nonatomic, strong) UIView *formView;
@property (nonatomic, strong) RCHOrderRequest *buyRequest;
@property (nonatomic, strong) RCHOrderRequest *sellRequest;
@property (nonatomic, strong) RCHOrderRequest *orderRequest;
@property (nonatomic, strong) NSMutableArray *currentOrders;
@property (nonatomic, strong) NSArray *asks;
@property (nonatomic, strong) NSArray *bids;
@property (nonatomic, strong) NSArray *wallets;
@property (nonatomic, strong) NSDecimalNumber *buyPrice;
@property (nonatomic, strong) NSDecimalNumber *sellPrice;
@property (nonatomic, strong) NSDecimalNumber *maxPrice;
@property (nonatomic, strong) NSDecimalNumber *miniPrice;
@property (nonatomic, strong) NSDecimalNumber *amount;
@property (nonatomic, strong) NSDecimalNumber *stepPrice;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation RCHTradeView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = [UIColor whiteColor];
}

- (instancetype)initWithFrame:(CGRect)frame type:(RCHAgencyAim)aim
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.agencyAim = aim;
        [self createUI];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
 
    if (self.buyRequest.currentTask) {
        [self.buyRequest.currentTask cancel];
    }
    
    if (self.sellRequest.currentTask) {
        [self.sellRequest.currentTask cancel];
    }
    
    if (self.orderRequest.currentTask) {
        [self.orderRequest.currentTask cancel];
    }
}

#pragma mark -
#pragma mark - UITapGestureRecognizer

- (void)changeAgencyTypeClicked:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    [YBPopupMenu showRelyOnView:tap.view titles:@[@"限价单", @"市价单"] icons:nil menuWidth:tap.view.width + 15.0f otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.tag = 100;
        popupMenu.dismissOnSelected = YES;
        popupMenu.isShowShadow = YES;
        popupMenu.delegate = self;
        popupMenu.type = YBPopupMenuTypeDefault;
        popupMenu.cornerRadius = 4.0f;
        popupMenu.itemHeight = 30.0f;
        popupMenu.backColor = kNavigationColor_MB;
        popupMenu.isShowShadow = NO;
        popupMenu.offset = 2.0f;
    }];
}

#pragma mark -
#pragma mark - YBPopupMenuDelegate
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index
{
    if (ybPopupMenu.tag == 100) {
        _agencyType = index == 0 ? RCHAgencyTypeLimit : RCHAgencyTypeMarket;
        _agencyTypeLabel.text = _agencyType == RCHAgencyTypeLimit ? @"限价单" : @"市价单";
        [self reloadAgencyForm:NO];
    }
}

- (UITableViewCell *)ybPopupMenu:(YBPopupMenu *)ybPopupMenu cellForRowAtIndex:(NSInteger)index
{
    static NSString *MenuCellIdentifer = @"MenuCellIdentifer";
    RCHMenuCell * cell = [ybPopupMenu.tableView dequeueReusableCellWithIdentifier:MenuCellIdentifer];
    if (cell == nil) {
        cell = [[RCHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuCellIdentifer];
    }
    
    cell.contentView.backgroundColor = kNavigationColor_MB;
    if (ybPopupMenu.tag == 100) {
        cell.textLabel.text = @[@"限价单", @"市价单"][index];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = RGBA(0X19, 0X1E, 0X3D, 1.0f);
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)showNotice:(id)sender
{
    !self.showHelp ?: self.showHelp();
}

#pragma mark -
#pragma mark - CustomFuction

- (void)createUI {
    
    [self removeAllSubviews];
    
    [self createTypeSelector];
    [self addSubview:self.formView];
    
    [self addSubview:self.realtimeAgencyView];
    
    [self reloadAgencyForm:YES];
    [_realtimeAgencyView setMarket:[[RCHGlobal sharedGlobal] currentMarket]];
}

- (void)createTypeSelector {
    if (self.agencyAim == RCHAgencyAimAuto) {
        [self createAutoAgencyTypeSelector];
    } else {
        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        if (market.is_auction) {
            [self createAutoAgencyTypeSelector];
        } else {
            [self createAgencyTypeSelector];
        }
        
    }
}


- (void)createAgencyTypeSelector {
    UIView *selectorView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, self.frame.size.width / 2 - 20, 18)];
    selectorView.backgroundColor = [UIColor clearColor];
    
    _agencyTypeLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {280.0f, 18}}];
    _agencyTypeLabel.backgroundColor = [UIColor clearColor];
    _agencyTypeLabel.textAlignment = NSTextAlignmentLeft;
    _agencyTypeLabel.textColor = kNavigationColor_MB;
    _agencyTypeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    _agencyTypeLabel.text = _agencyType == RCHAgencyTypeLimit ? @"限价单" : @"市价单";
    [_agencyTypeLabel sizeToFit];
    [selectorView addSubview:_agencyTypeLabel];
    
    UIImage *image = RCHIMAGEWITHNAMED(@"ico_arrow_country");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, image.size}];
    imageView.image = image;
    [selectorView addSubview:imageView];
    
    _agencyTypeLabel.frame = (CGRect){{_agencyTypeLabel.left, 0}, _agencyTypeLabel.frame.size};
    imageView.frame =(CGRect){{_agencyTypeLabel.right + 5.0f, 0.0f}, image.size};
    imageView.center = CGPointMake(imageView.center.x, _agencyTypeLabel.center.y);
    selectorView.frame = (CGRect){selectorView.frame.origin, {imageView.right, selectorView.height}};
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAgencyTypeClicked:)];
    tapGesture.delegate = self;
    [selectorView addGestureRecognizer:tapGesture];
    [self addSubview:selectorView];
}

- (void)createAutoAgencyTypeSelector {
    
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    
    UIView *selectorView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, self.frame.size.width / 2 - 20, 18)];
    selectorView.backgroundColor = [UIColor clearColor];
    
    _agencyTypeLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {280.0f, 18}}];
    _agencyTypeLabel.backgroundColor = [UIColor clearColor];
    _agencyTypeLabel.textAlignment = NSTextAlignmentLeft;
    _agencyTypeLabel.textColor = kNavigationColor_MB;
    _agencyTypeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    if (market.is_auction) {
        _agencyTypeLabel.text = @"抽奖消费交易";
    } else {
        _agencyTypeLabel.text = @"自动交易";
    }
    
    [_agencyTypeLabel sizeToFit];
    [selectorView addSubview:_agencyTypeLabel];
    
    UIImage *image = RCHIMAGEWITHNAMED(@"ico_trade_help");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, image.size}];
    imageView.image = image;
    [selectorView addSubview:imageView];
    
    _agencyTypeLabel.frame = (CGRect){{_agencyTypeLabel.left, 0}, _agencyTypeLabel.frame.size};
    imageView.frame =(CGRect){{_agencyTypeLabel.right + 5.0f, 0.0f}, image.size};
    imageView.center = CGPointMake(imageView.center.x, _agencyTypeLabel.center.y);
    selectorView.frame = (CGRect){selectorView.frame.origin, {imageView.right, selectorView.height}};
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotice:)];
    tapGesture.delegate = self;
    [selectorView addGestureRecognizer:tapGesture];
    [self addSubview:selectorView];
}

- (void)reloadAgencyForm:(BOOL)force {
    
    if (self.agencyAim == RCHAgencyAimAuto) {
        [(RCHAutoAgencyFormView *)_formView reloadWithAgency:[[RCHAutoAgency alloc] initWithType:RCHAgencyTypeLimit
                                                                 market:[[RCHGlobal sharedGlobal] currentMarket]
                                                                    aim:_agencyAim
                                                              stepPrice:self.stepPrice]];
        
        if (force) {
            [(RCHAutoAgencyFormView *)_formView setWallets:nil];
        }
    } else {
        [(RCHAgencyFormView *)_formView reloadWithAgency:[[RCHAgency alloc] initWithType:_agencyType
                                                                                      market:[[RCHGlobal sharedGlobal] currentMarket]
                                                                                         aim:_agencyAim]];
        
        if (force) {
            [(RCHAgencyFormView *)_formView setWallets:nil];
        }
    }
    

    !self.reloadBlock ?: self.reloadBlock(force);
}

- (void)changeButtonState:(BOOL)state button:(UIButton *)button
{
    self.creatingOrder = state;
    [button setSelected:state];
    [UIApplication sharedApplication].idleTimerDisabled = state;
}

- (BOOL)isOverPriceRange:(RCHAutoAgency *)agency
{
    if ([agency.miniPrice compare:agency.buyPrice] == NSOrderedDescending) {
        [MBProgressHUD showError:[NSString stringWithFormat:NSLocalizedString(@"买入价格(%@)低于挂单最低价",nil), [self.numberFormatter stringFromNumber:agency.buyPrice]] ToView:self];
        return NO;
    }
    
    if ([agency.maxPrice compare:agency.buyPrice] == NSOrderedAscending) {
        [MBProgressHUD showError:[NSString stringWithFormat:NSLocalizedString(@"买入价格(%@)高于挂单最高价",nil), [self.numberFormatter stringFromNumber:agency.buyPrice]] ToView:self];
        return NO;
    }
    
    if ([agency.miniPrice compare:agency.sellPrice] == NSOrderedDescending) {
        [MBProgressHUD showError:[NSString stringWithFormat:NSLocalizedString(@"卖出价格(%@)低于挂单最低价",nil), [self.numberFormatter stringFromNumber:agency.sellPrice]] ToView:self];
        return NO;
    }
    
    if ([agency.maxPrice compare:agency.sellPrice] == NSOrderedAscending) {
        [MBProgressHUD showError:[NSString stringWithFormat:NSLocalizedString(@"卖出价格(%@)高于挂单最低高价",nil), [self.numberFormatter stringFromNumber:agency.sellPrice]] ToView:self];
        return NO;
    }
    
    return YES;
    
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
    
    [self addSubview:view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view removeFromSuperview];
    });
}

- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids
{
    self.asks = asks;
    self.bids = bids;
    [_realtimeAgencyView setAsks:self.asks bids:self.bids];
}

- (void)refreshPrice:(NSString *)symbol
{
    if ([[RCHGlobal sharedGlobal] currentMarket] && [symbol isEqualToString:[[[RCHGlobal sharedGlobal] currentMarket] symbol]]) {
        [_realtimeAgencyView refreshPrice];
    }
}

- (void)setCurrentWallets:(NSArray *)wallets
{
    self.wallets = wallets;
    if (self.agencyAim == RCHAgencyAimAuto) {
        [(RCHAutoAgencyFormView *)self.formView setWallets:wallets];
    } else {
        [(RCHAgencyFormView *)self.formView setWallets:wallets];
    }
}

- (void)changeCurrentOrders:(NSArray *)orders
{
    if (self.agencyAim != RCHAgencyAimAuto) {
        return;
    }
    
    if (!_creatingOrder && orders.count == 0) {
        [self.currentOrders removeAllObjects];
        [((RCHAutoAgencyFormView *)self.formView).submitButton setSelected:NO];
    } else {
        for (RCHOrder *order in self.currentOrders) {
            for (RCHOrder *o in orders) {
                if (o.order_id == order.order_id) {
                    return;
                }
            }
        }
        
        BOOL createOrder = YES;
        if (!self.buySuccess || !self.sellSuccess) {
            createOrder = NO;
        } else {
            createOrder = YES;
            self.buySuccess = NO;
            self.sellSuccess = NO;
        }
        
        if (createOrder) {
            [self.currentOrders removeAllObjects];
            RCHAutoAgency *agency = [[RCHAutoAgency alloc] initWithType:RCHAgencyTypeLimit
                                                                 market:[[RCHGlobal sharedGlobal] currentMarket]
                                                                    aim:RCHAgencyAimBuy
                                                              stepPrice:self.stepPrice];
            agency.amount = self.amount;
            agency.stepPrice = self.stepPrice;
            agency.maxPrice = self.maxPrice;
            agency.miniPrice = self.miniPrice;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self submitAgency:agency :nil];
            });
        }
    }
}

#pragma mark -
#pragma mark -  Reqeust

- (void)submitAgency:(RCHAgency *)agency
{
    if (self.orderRequest.currentTask) {
        [self.orderRequest.currentTask cancel];
    }
    
    RCHWeak(self);
    [MBProgressHUD showLoadToView:self];
    [self.orderRequest createOrder:^(NSObject *response) {
        [MBProgressHUD hideHUDForView:weakself];
        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        if ([response isKindOfClass:[RCHOrder class]]) {
            //            [MB；ProgressHUD showError:NSLocalizedString(@"委托下单成功", nil) ToView:self];
            [(RCHAgencyFormView *)weakself.formView setPrice:_agencyType == RCHAgencyTypeMarket || !market || !market.state ? nil : [NSDecimalNumber decimalNumberWithDecimal:[market.state.last_price decimalValue]]];
            [(RCHAgencyFormView *)weakself.formView setAmount:nil];
            
            [self showSuccess:YES];
        } else if ([response isKindOfClass:[WDBaseResponse class]]) {
            
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];

            
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", errorInfo);
            NSString *pre = self->_agencyAim == RCHAgencyAimBuy ? @"买入" : @"卖出";
            
            if ([errorInfo isEqualToString:@"MIN_PRICE"]) {
                errorInfo = [NSString stringWithFormat:@"%@价不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_price]];
            } else if ([errorInfo isEqualToString:@"MAX_PRICE"]) {
                errorInfo = [NSString stringWithFormat:@"%@价不能高于%@", pre, [self.numberFormatter stringFromNumber:market.max_price]];
            } else if ([errorInfo isEqualToString:@"PRICE_STEP"]) {
                errorInfo = [NSString stringWithFormat:@"%@价阶梯为%@", pre, [self.numberFormatter stringFromNumber:market.price_step]];
            } else if ([errorInfo isEqualToString:@"MIN_AMOUNT"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_amount]];
            } else if ([errorInfo isEqualToString:@"MAX_AMOUNT"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量不能高于%@", pre, [self.numberFormatter stringFromNumber:market.max_amount]];
            } else if ([errorInfo isEqualToString:@"AMOUNT_STEP"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量阶梯为%@", pre, [self.numberFormatter stringFromNumber:market.amount_step]];
            } else if ([errorInfo isEqualToString:@"MIN_TOTAL"]) {
                errorInfo = [NSString stringWithFormat:@"%@交易额不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_total]];
            } else if ([errorInfo isEqualToString:@"NO_ENOUGH_BALANCE"]) {
                errorInfo = [NSString stringWithFormat:@"可用余额不足"];
            } else if ([errorInfo isEqualToString:@"LIMIT_UP"]) {
                errorInfo = [NSString stringWithFormat:@"%@价高于涨停价", pre];
            } else if ([errorInfo isEqualToString:@"LIMIT_DOWN"]) {
                errorInfo = [NSString stringWithFormat:@"%@价低于跌停价", pre];
            } else {
                if (code == 403) {
                    [self showSuccess:NO];
                } else {
                    [RCHHelper showRequestErrorCode:code url:url];
                }
                return;
            }
            [MBProgressHUD showError:errorInfo ToView:self];
            
        } else {
            [MBProgressHUD showError:kDataError ToView:self];
        }
    } info:[agency dispose] type:agency.dtype];
}

- (void)submitAgency:(RCHAutoAgency *)agency :(UIButton *)button
{
    if (button) {
        if (!button.selected) {
            [self changeButtonState:YES button:button];
            
        } else {
            [self changeButtonState:NO button:button];
            [self.currentOrders removeAllObjects];
            return;
        }
    }
    
    if (!self.creatingOrder) {
        return;
    }
    
    RCHAutoAgencyFormView *formView = (RCHAutoAgencyFormView *)self.formView;
    
    if (RCHIsEmpty(agency) || RCHIsEmpty(agency.amount) || [agency.amount compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        [MBProgressHUD showError:NSLocalizedString(@"交易数量不能为空",nil) ToView:self];
        [self changeButtonState:NO button:formView.submitButton];
        return;
    }
    
    if (RCHIsEmpty(agency.miniPrice) || [agency.miniPrice compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        [MBProgressHUD showError:NSLocalizedString(@"挂单最低价不能为空",nil) ToView:self];
        [self changeButtonState:NO button:formView.submitButton];
        return;
    }
    
    if (RCHIsEmpty(agency.maxPrice) || [agency.maxPrice compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        [MBProgressHUD showError:NSLocalizedString(@"挂单最高价不能为空",nil) ToView:self];
        [self changeButtonState:NO button:formView.submitButton];
        return;
    }
    
    if (RCHIsEmpty(agency.stepPrice) || [agency.stepPrice compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
        [MBProgressHUD showError:NSLocalizedString(@"挂单间隔不能为空",nil) ToView:self];
        [self changeButtonState:NO button:((RCHAutoAgencyFormView *)self.formView).submitButton];
        return;
    }
    
    if ([agency.amount compare:agency.market.min_amount] == NSOrderedAscending) {
        [MBProgressHUD showError:[NSString stringWithFormat:NSLocalizedString(@"交易数量不能少于%@",nil), [self.numberFormatter stringFromNumber:agency.market.min_amount]] ToView:self];
        [self changeButtonState:NO button:formView.submitButton];
        return;
    }
    
    if (![self isOverPriceRange:agency]) {
        [self changeButtonState:NO button:formView.submitButton];
        return;
    }
    
    
    if (!agency.market || !agency.market.state) {
        [MBProgressHUD showError:kConnectionError ToView:self];
        return;
    } else {
        RCHAutoAgency *buy = [[RCHAutoAgency alloc] initWithType:RCHAgencyTypeLimit
                                                          market:agency.market
                                                             aim:RCHAgencyAimBuy
                                                       stepPrice:self.stepPrice];
        buy.price = agency.buyPrice;
        buy.amount = agency.amount;
        _orderAgencyAim = agency.aim;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendBuyRequest:buy];
        });
        
        RCHAutoAgency *sell = [[RCHAutoAgency alloc] initWithType:RCHAgencyTypeLimit
                                                           market:agency.market
                                                              aim:RCHAgencyAimSell
                                                        stepPrice:self.stepPrice];
        sell.price = agency.sellPrice;
        sell.amount = agency.amount;
        _orderAgencyAim = agency.aim;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendSellRequest:sell];
        });
        
    }
}


- (void)sendBuyRequest:(RCHAutoAgency *)agency
{
    if (self.buyRequest.currentTask) {
        [self.buyRequest.currentTask cancel];
    }
    RCHWeak(self);
    [self.buyRequest createOrder:^(NSObject *response) {
        if ([response isKindOfClass:[RCHOrder class]]) {
            weakself.buySuccess = YES;
            RCHOrder *order = (RCHOrder *)response;
            [weakself.currentOrders addObject:order];
            
        } else if ([response isKindOfClass:[WDBaseResponse class]]) {
            RCHAutoAgencyFormView *formView = (RCHAutoAgencyFormView *)weakself.formView;
            [weakself changeButtonState:NO button:formView.submitButton];
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            
            RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
            NSString *pre = weakself.orderAgencyAim == RCHAgencyAimBuy ? @"买入" : @"卖出";
            
            if ([errorInfo isEqualToString:@"MIN_PRICE"]) {
                errorInfo = [NSString stringWithFormat:@"%@价不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_price]];
            } else if ([errorInfo isEqualToString:@"MAX_PRICE"]) {
                errorInfo = [NSString stringWithFormat:@"%@价不能高于%@", pre, [self.numberFormatter stringFromNumber:market.max_price]];
            } else if ([errorInfo isEqualToString:@"PRICE_STEP"]) {
                errorInfo = [NSString stringWithFormat:@"%@价阶梯为%@", pre, [self.numberFormatter stringFromNumber:market.price_step]];
            } else if ([errorInfo isEqualToString:@"MIN_AMOUNT"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_amount]];
            } else if ([errorInfo isEqualToString:@"MAX_AMOUNT"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量不能高于%@", pre, [self.numberFormatter stringFromNumber:market.max_amount]];
            } else if ([errorInfo isEqualToString:@"AMOUNT_STEP"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量阶梯为%@", pre, [self.numberFormatter stringFromNumber:market.amount_step]];
            } else if ([errorInfo isEqualToString:@"MIN_TOTAL"]) {
                errorInfo = [NSString stringWithFormat:@"%@交易额不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_total]];
            } else if ([errorInfo isEqualToString:@"NO_ENOUGH_BALANCE"]) {
                errorInfo = [NSString stringWithFormat:@"可用余额不足"];
            } else if ([errorInfo isEqualToString:@"LIMIT_UP"]) {
                errorInfo = [NSString stringWithFormat:@"%@价高于涨停价", pre];
            } else if ([errorInfo isEqualToString:@"LIMIT_DOWN"]) {
                errorInfo = [NSString stringWithFormat:@"%@价低于跌停价", pre];
            } else {
                [RCHHelper showRequestErrorCode:code url:url];
                return;
            }
            [MBProgressHUD showError:errorInfo ToView:self];
            
        } else {
            [MBProgressHUD showError:kDataError ToView:self];
        }
    } info:[agency dispose] type:agency.dtype];
}

- (void)sendSellRequest:(RCHAutoAgency *)agency
{
    if (self.sellRequest.currentTask) {
        [self.sellRequest.currentTask cancel];
    }
    RCHWeak(self);
    [self.sellRequest createOrder:^(NSObject *response) {
        if ([response isKindOfClass:[RCHOrder class]]) {
            weakself.sellSuccess = YES;
            RCHOrder *order = (RCHOrder *)response;
            [weakself.currentOrders addObject:order];
        } else if ([response isKindOfClass:[WDBaseResponse class]]) {
            RCHAutoAgencyFormView *formView = (RCHAutoAgencyFormView *)weakself.formView;
            [weakself changeButtonState:NO button:formView.submitButton];
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            
            RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
            NSString *pre = weakself.orderAgencyAim == RCHAgencyAimBuy ? @"买入" : @"卖出";
            
            if ([errorInfo isEqualToString:@"MIN_PRICE"]) {
                errorInfo = [NSString stringWithFormat:@"%@价不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_price]];
            } else if ([errorInfo isEqualToString:@"MAX_PRICE"]) {
                errorInfo = [NSString stringWithFormat:@"%@价不能高于%@", pre, [self.numberFormatter stringFromNumber:market.max_price]];
            } else if ([errorInfo isEqualToString:@"PRICE_STEP"]) {
                errorInfo = [NSString stringWithFormat:@"%@价阶梯为%@", pre, [self.numberFormatter stringFromNumber:market.price_step]];
            } else if ([errorInfo isEqualToString:@"MIN_AMOUNT"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_amount]];
            } else if ([errorInfo isEqualToString:@"MAX_AMOUNT"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量不能高于%@", pre, [self.numberFormatter stringFromNumber:market.max_amount]];
            } else if ([errorInfo isEqualToString:@"AMOUNT_STEP"]) {
                errorInfo = [NSString stringWithFormat:@"%@数量阶梯为%@", pre, [self.numberFormatter stringFromNumber:market.amount_step]];
            } else if ([errorInfo isEqualToString:@"MIN_TOTAL"]) {
                errorInfo = [NSString stringWithFormat:@"%@交易额不能低于%@", pre, [self.numberFormatter stringFromNumber:market.min_total]];
            } else if ([errorInfo isEqualToString:@"NO_ENOUGH_BALANCE"]) {
                errorInfo = [NSString stringWithFormat:@"可用余额不足"];
            } else if ([errorInfo isEqualToString:@"LIMIT_UP"]) {
                errorInfo = [NSString stringWithFormat:@"%@价高于涨停价", pre];
            } else if ([errorInfo isEqualToString:@"LIMIT_DOWN"]) {
                errorInfo = [NSString stringWithFormat:@"%@价低于跌停价", pre];
            } else {
                [RCHHelper showRequestErrorCode:code url:url];
                return;
            }
            [MBProgressHUD showError:errorInfo ToView:self];
            
        } else {
            [MBProgressHUD showError:kDataError ToView:self];
        }
    } info:[agency dispose] type:agency.dtype];
}

#pragma mark -
#pragma mark - getter

- (RCHOrderRequest *)buyRequest
{
    if(_buyRequest == nil)
    {
        _buyRequest = [[RCHOrderRequest alloc] init];
    }
    return _buyRequest;
}

- (RCHOrderRequest *)sellRequest
{
    if(_sellRequest == nil)
    {
        _sellRequest = [[RCHOrderRequest alloc] init];
    }
    return _sellRequest;
}

- (RCHOrderRequest *)orderRequest
{
    if(_orderRequest == nil)
    {
        _orderRequest = [[RCHOrderRequest alloc] init];
    }
    return _orderRequest;
}

- (NSMutableArray *)currentOrders
{
    if(_currentOrders == nil)
    {
        _currentOrders = [NSMutableArray array];
    }
    return _currentOrders;
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

-(UIView *)formView
{
    if(_formView == nil)
    {
        RCHWeak(self);
        if (self.agencyAim == RCHAgencyAimAuto) {
            _formView = [[RCHAutoAgencyFormView alloc] initWithFrame:CGRectMake(0, 43, self.width / 2, self.height - 43)
                                                            onSubmit:^(RCHAutoAgency *agency, UIButton *button) {
                                                                weakself.amount = agency.amount;
                                                                weakself.stepPrice = agency.stepPrice;
                                                                weakself.maxPrice = agency.maxPrice;
                                                                weakself.miniPrice = agency.miniPrice;
                                                                
                                                                RCHAutoAgency *current_agency = [[RCHAutoAgency alloc] initWithType:RCHAgencyTypeLimit
                                                                                                                             market:[[RCHGlobal sharedGlobal] currentMarket]
                                                                                                                                aim:RCHAgencyAimBuy
                                                                                                                          stepPrice:agency.stepPrice];
                                                                current_agency.amount = agency.amount;
                                                                current_agency.maxPrice = agency.maxPrice;
                                                                current_agency.miniPrice = agency.miniPrice;
                                                                
                                                                [weakself submitAgency:current_agency :button];
                                                            }];
            
        } else {
            _formView = [[RCHAgencyFormView alloc] initWithFrame:CGRectMake(0, 43, self.width / 2, self.height - 43)
                                                        onSubmit:^(RCHAgency *agency) {
                                                            [weakself submitAgency:agency];
                                                        }];
        }
    }
    return _formView;
}


-(UIView *)realtimeAgencyView
{
    if(_realtimeAgencyView == nil)
    {
        RCHWeak(self);
        _realtimeAgencyView = [[RCHRealtimeAgencyView alloc] initWithFrame:CGRectMake(self.width / 2, 0, self.width / 2, self.height)
                                                                onSelected:^(NSString *price, DepthSide side) {
                                                                    if (weakself.agencyAim != RCHAgencyAimAuto) {
                                                                        if (!price) return;
                                                                        NSDecimalNumber *p = [NSDecimalNumber decimalNumberWithString:price];
                                                                        if ([p compare:[NSDecimalNumber notANumber]] == NSOrderedSame) return;
                                                                        [(RCHAgencyFormView *)weakself.formView setPrice:p];
                                                                    }
                                                                }];
    }
    return _realtimeAgencyView;
}

-(NSNumberFormatter *)numberFormatter
{
    if(_numberFormatter == nil)
    {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_numberFormatter setPositiveFormat:@"####.##"];
        [_numberFormatter setMaximumFractionDigits:8];
        [_numberFormatter setRoundingMode:NSNumberFormatterRoundFloor];
    }
    return _numberFormatter;
}

@end
