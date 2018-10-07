//
//  RCHWalletViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWalletViewController.h"
#import "MJLOnePixLineView.h"
#import "RCHWalletQuotesView.h"
#import "RCHRechargeController.h"
#import "MJLOnePixLineView.h"
#import "RCHAlertView.h"
#import "RCHWithdrawViewController.h"
#import "RCHShareRequest.h"
#import "RCHFlowsController.h"

@interface RCHWalletViewController () <UIGestureRecognizerDelegate>
{
    UIView *_bottomView;
    UILabel *_submitLabel;
    UILabel *_withdrawLabel;
    
    NSMutableDictionary *_items;
    NSArray *_cells;
    
    RCHWallet *_wallet;
    RCHShareRequest *_sharesRequest;
}
@end

@implementation RCHWalletViewController


- (id)initWithWallet:(RCHWallet *)wallet
{
    if(self = [super init]) {
        _wallet = wallet;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"资产",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    if (!_cells) {
        _cells = [NSArray arrayWithObjects:@"总额",@"可用余额",@"冻结",@"估值(￥)", nil];
    }
    
    if (!_items) {
        _items = [NSMutableDictionary dictionary];
        NSString *value;
        NSString *defaultString = @"0";
        for (NSString *cell in _cells) {
            if ([cell isEqualToString:@"总额"]) {
                value  = [RCHHelper getNSDecimalString:_wallet.balance defaultString:defaultString precision:_wallet.coin.scale];
            } else if ([cell isEqualToString:@"可用余额"]) {
                NSNumber *canUse = [RCHHelper sub:_wallet.balance and:_wallet.freeze];
                value  = [RCHHelper getNSDecimalString:canUse defaultString:defaultString precision:_wallet.coin.scale];
            } else if ([cell isEqualToString:@"冻结"]) {
                value  = [RCHHelper getNSDecimalString:_wallet.freeze defaultString:defaultString precision:_wallet.coin.scale];
            } else if ([cell isEqualToString:@"估值(BTC)"]) {
                value  = [RCHHelper getNSDecimalString:_wallet.ebtc defaultString:defaultString precision:defaultPrecision];
            } else if ([cell isEqualToString:@"估值(￥)"]) {
                value  = [RCHHelper getNSDecimalString:_wallet.ecny defaultString:defaultString precision:2];
            } else {
                value = @"0";
            }
            
            [_items setObject:value forKey:cell];
        }
    }
    
    [self initCustomView];
    
    [self loadShare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - CustomFunction

- (void)initCustomView
{
    CGFloat headerHeight = 279.0f;
    CGFloat submitButtonHeight = 44.0f;
    CGFloat bottomHeight = submitButtonHeight + 30.0f;
    
    CGFloat bottomOriginY = self.view.height - bottomHeight - TabbarMiniSafeBottomMargin;
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.bottom += bottomHeight;
    self.tableView.contentInset = edgeInsets;
    
    self.tableView.tableHeaderView = [self createHeaderView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, headerHeight}}];
    NSArray *markets = [self getQuotes:[[RCHGlobal sharedGlobal] marketsArray]];
    if ([markets count] > 0) {
        NSInteger rows = ceil(markets.count / 2.0);
        self.tableView.tableFooterView = [self createFooterView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, rows * 58.0f + 10 * (rows - 1) + 46.0f + 30.0f}} markets:markets];
    } else {
        self.tableView.tableFooterView = nil;
    }

    [_bottomView removeFromSuperview];
    _bottomView = [self createBottomView:(CGRect){{0.0f, bottomOriginY}, {kMainScreenWidth, bottomHeight}}];
    [self.view addSubview:_bottomView];
}

- (UIView *)createHeaderView:(CGRect)rect
{
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    headView.backgroundColor = RGBA(255.0, 255.0f, 255.0f, 1.0f);
    
    UIView *titleView = [self createTitleView:(CGRect){} wallet:_wallet];
    titleView.backgroundColor = [UIColor clearColor];
    [headView addSubview:titleView];
    
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(headView.mas_centerX).offset(-10.0f);
        make.top.mas_equalTo(30.0f);
        make.size.mas_equalTo(titleView.size);
    }];
    [headView layoutIfNeeded];
    
    
    CGFloat bottom = 94.0f;
    CGFloat spaceY = 10.0f;
    CGSize size = CGSizeMake(kMainScreenWidth, 21.0f);
    NSInteger index = 0;
    for (NSString *key in _cells) {
        NSString *value = [_items objectForKey:key];
        UIView *itemView = [self createItemView:(CGRect){{0.0f, bottom}, size} title:key value:value];
        [headView addSubview:itemView];
        if (index == 2) {            
            CGFloat originX = 15.0f;
            bottom = bottom + size.height + 20.0f;
            MJLOnePixLineView *spacelineView = [[MJLOnePixLineView alloc] initWithFrame:(CGRect){{originX, bottom - [RCHHelper retinaFloatOffset:1.0f]}, {headView.width - originX * 2, [RCHHelper retinaFloat:1.0f]}}];
            [headView addSubview:spacelineView];
            
            bottom = bottom + 20.0f;
        } else {
            bottom = bottom + size.height + spaceY;
        }
        
        index += 1;
    }
    
    bottom = bottom - spaceY + 30.0f;
    headView.frame = (CGRect){headView.frame.origin, {headView.width, bottom}};
    
    UIView *topView = [[UIView alloc] initWithFrame:headView.frame];
    topView.backgroundColor = [UIColor clearColor];
    [topView addSubview:headView];
    
    return topView;
}

- (UIView *)createFooterView:(CGRect)rect markets:(NSArray *)markets
{
    CGFloat origibackViewY = 10.0f;
    CGFloat originX = 15.0f;
    CGFloat originY = 15.0f;
    CGFloat spaceY = 15.0f;
    CGFloat bottom = 30.0f;
    UIView *footerView = [[UIView alloc] initWithFrame:rect];
    footerView.backgroundColor = [UIColor clearColor];
    
    UIView *backView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, origibackViewY}, {rect.size.width, rect.size.height - origibackViewY}}];
    backView.backgroundColor = RGBA(255.0, 255.0f, 255.0f, 1.0f);
    [footerView addSubview:backView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, originY}, {45.0f, 16.0f}}];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"去交易";
    titleLabel.textColor = kFontBlackColor;
    [backView addSubview:titleLabel];
    [titleLabel sizeToFit];    
    titleLabel.height = 16.0f;
    
    RCHWeak(self);
    RCHWalletQuotesView *quotesView = [[RCHWalletQuotesView alloc] initWithFrame:(CGRect){{titleLabel.left, titleLabel.bottom + spaceY}, {rect.size.width - originX * 2, rect.size.height - (titleLabel.bottom + spaceY) - bottom}}];
    quotesView.markets = markets;
    quotesView.seleced = ^(RCHMarket *market) {
        if (market) {
            [[RCHGlobal sharedGlobal] setCurrentMarket:market];
            [RCHHelper setValue:[NSNumber numberWithInt:RCHAgencyAimBuy] forKey:kCurrentTradeType];
            UITabBarController *tabbarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [tabbarController setSelectedIndex:2];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.navigationController popToRootViewControllerAnimated:YES];
            });
        } else {
            [MBProgressHUD showError:kRangeError ToView:self.view];
        }
        
    };
    quotesView.backgroundColor = [UIColor clearColor];
    [backView addSubview:quotesView];
    
    return footerView;
}

- (UIView *)createBottomView:(CGRect)rect
{
    CGFloat height = 44.0f;
    CGFloat lineWidth = 1.0f;
    CGFloat originX = 15.0f;
    CGFloat originY = (rect.size.height - height) / 2.0f;
    CGFloat width = (rect.size.width - originX * 2 - 10.0f) / 2.0f;
    UIColor *color = kAppOrangeColor;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:rect];
    bottomView.backgroundColor = [UIColor clearColor];
    
    UIButton *withdraw = [UIButton buttonWithType:UIButtonTypeCustom];
    withdraw.frame = (CGRect){{originX, originY}, {width, height}};
    [withdraw setTitle:NSLocalizedString(@"提币", nil) forState:UIControlStateNormal];
    [withdraw setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [withdraw.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]];
    [withdraw setTitleColor:color forState:UIControlStateNormal];
    withdraw.titleLabel.textAlignment = NSTextAlignmentCenter;
    withdraw.layer.cornerRadius = 4.0f;
    withdraw.layer.masksToBounds = YES;
    withdraw.layer.borderWidth = lineWidth;
    withdraw.layer.borderColor = [color CGColor];
    [withdraw addTarget:self action:@selector(withdrawClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:withdraw];
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.frame = (CGRect){{withdraw.right + 10.0f, withdraw.top}, {width, height}};
    [submit setTitle:NSLocalizedString(@"充币", nil) forState:UIControlStateNormal];
    [submit setBackgroundColor:color forState:UIControlStateNormal];
    [submit.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]];
    [submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submit.titleLabel.textAlignment = NSTextAlignmentCenter;
    submit.layer.cornerRadius = 4.0f;
    submit.layer.masksToBounds = YES;
    [submit addTarget:self action:@selector(submitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:submit];
    
    return bottomView;
}

- (UIView *)createTitleView:(CGRect)rect wallet:(RCHWallet *)wallet
{
    NSString *defaultString;
    NSMutableAttributedString *attributedString;
    UIView *titleView = [[UIView alloc] initWithFrame:rect];
    titleView.backgroundColor = [UIColor clearColor];
    
    CGSize size = (CGSize){32.0f, 32.0f};
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [iconImageView sd_setImageWithURL:[NSURL URLWithString:wallet.icon] placeholderImage:nil];
//    iconImageView.frame = (CGRect){{0.0f, 0.0f}, size};
    [titleView addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0.0f);
        make.size.mas_equalTo(size);
    }];
    
    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    codeLabel.backgroundColor = [UIColor clearColor];
    codeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17.0f];
    codeLabel.textAlignment = NSTextAlignmentLeft;
    codeLabel.textColor = kFontBlackColor;
    if (wallet.coin.code) {
        attributedString = [RCHHelper getMutableAttributedStringe:wallet.coin.code Font:codeLabel.font color:codeLabel.textColor alignment:codeLabel.textAlignment];
    } else {
        attributedString = [RCHHelper getMutableAttributedStringe:defaultString Font:codeLabel.font color:codeLabel.textColor alignment:codeLabel.textAlignment];
    }
    codeLabel.attributedText = attributedString;
    [codeLabel sizeToFit];
    [titleView addSubview:codeLabel];
    [codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iconImageView.mas_top).offset(0.0f);
        make.left.mas_equalTo(iconImageView.mas_right).offset(10.0f);
        make.height.mas_equalTo(18.0f);
    }];
    
    UILabel *enLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    enLabel.backgroundColor = [UIColor clearColor];
    enLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    enLabel.textAlignment = NSTextAlignmentRight;
    enLabel.textColor = kFontLightGrayColor;
    if (wallet.coin.name_en) {
        attributedString = [RCHHelper getMutableAttributedStringe:wallet.coin.name_en Font:enLabel.font color:enLabel.textColor alignment:enLabel.textAlignment];
    } else {
        attributedString = [RCHHelper getMutableAttributedStringe:defaultString Font:enLabel.font color:enLabel.textColor alignment:enLabel.textAlignment];
    }
    enLabel.attributedText = attributedString;
    [enLabel sizeToFit];
    [titleView addSubview:enLabel];
    [enLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(codeLabel.mas_bottom).offset(0.0f);
        make.left.mas_equalTo(codeLabel.mas_left).offset(0.0f);
        make.height.mas_equalTo(14.0f);
    }];
    
    [titleView layoutIfNeeded];
    
    titleView.size = CGSizeMake(MAX(enLabel.right,codeLabel.right), iconImageView.bottom);
    return titleView;
}

- (UIView *)createItemView:(CGRect)rect title:(NSString *)title value:(NSString *)value
{
    CGFloat originX = 15.0f;
    
    UIView *itemView = [[UIView alloc] initWithFrame:rect];
    itemView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.frame = (CGRect){{originX, 0.0f}, {280.0f, rect.size.height}};
    if (title) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [title length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f] range:NSMakeRange(0, [title length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange(0, [title length])];
        titleLabel.attributedText = attributedString;
    } else {
        titleLabel.attributedText = nil;
    }
    
    [titleLabel sizeToFit];
    [itemView addSubview:titleLabel];
    
    CGFloat width = 280.0f;
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabel.frame = (CGRect){{rect.size.width - originX - width, titleLabel.top}, {width, titleLabel.height}};
    valueLabel.backgroundColor = [UIColor clearColor];
    if (value) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:value];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentRight];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [value length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:17.0f] range:NSMakeRange(0, [value length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kAPPBlueColor range:NSMakeRange(0, [value length])];
        valueLabel.attributedText = attributedString;
    } else {
        valueLabel.attributedText = nil;
    }
    
    [itemView addSubview:valueLabel];
    
    return itemView;
}

- (NSArray *)getQuotes:(NSArray *)array
{
    NSMutableArray *markets = [NSMutableArray array];
    for (RCHMarket *market in array) {
        if ([_wallet.coin.code isEqualToString:market.coin.code]) {
            [markets addObject:market];
        }
    }
    return markets;
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)submitClicked:(id)sender
{
    RCHRechargeController *viewcontroller = [[RCHRechargeController alloc] initWithWallet:_wallet];
    [self.navigationController pushViewController:viewcontroller animated:YES];
}

- (void)withdrawClicked:(id)sender
{
//    if (_wallet.coin.canWithdraw) {
//        [MBProgressHUD showLoadToView:self.view];
//        [RCHWithdrawViewController preLoadWithCoinCode:_wallet.coin.code
//                                            onFinished:^(RCHWithdrawPreLoadError error, RCHWithdrawViewController *controller){
//                                                [MBProgressHUD hideHUDForView:self.view animated:NO];
//                                                if (error == RCHWithdrawPreLoadErrorNone) {
//                                                    [self.navigationController pushViewController:controller animated:YES];
//                                                } else if (error == RCHWithdrawPreLoadErrorVerify) {
//                                                    [RCHWithdrawDenyAlert showInView:self.navigationController.view
//                                                                             content:@"为了您的资产安全，\n提币需要开启二次验证，请前往\n【安全中心】完成验证。"];
//                                                } else {
//                                                    [MBProgressHUD showError:kDataError ToView:self.view];
//                                                }
//                                            }];
//    } else {
//        [RCHWithdrawDenyAlert showInView:self.navigationController.view
//                                 content:[NSString stringWithFormat:@"%@提币暂停，\n恢复时间请注意查看公告。", _wallet.coin.code]];
//    }
//    return;
    
    NSString *title = @"完成提币的相关操作";
    
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
    
    [RCHAlertView showAlertWithTitle:attributedStrin2 description:attributedString1 imageName:@"icon_popup_pc"];
}


- (void)loadShare {
    if (!_sharesRequest) {
        _sharesRequest = [[RCHShareRequest alloc] init];
    }
    
    if (_sharesRequest.currentTask) {
        [_sharesRequest.currentTask cancel];
    }
    
    RCHWeak(self);
    [_sharesRequest shareWithCoinCode:_wallet.coin.code completion:^(NSObject *response) {
        if ([response isKindOfClass:[RCHShare class]]) {
            RCHShare *share = (RCHShare *)response;
            UIView *topView = weakself.tableView.tableHeaderView;
            if (!topView) return;
            
            NSNumberFormatter *formatter = [RCHHelper getNumberFormatterFractionDigits:share.coin.scale fractionDigitsPadded:YES];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setGroupingSize:3];
            
            UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                         topView.frame.size.height + 10,
                                                                         topView.frame.size.width,
                                                                         135)];
            shareView.backgroundColor = [UIColor whiteColor];
            [shareView addSubview:[self createItemView:CGRectMake(0, 15 + 7, kScreenWidth, 21) title:@"挖矿同步待释放总额" value:[formatter stringFromNumber:share.total]]];
            [shareView addSubview:[self createItemView:CGRectMake(0, 50 + 7, kScreenWidth, 21) title:@"已释放" value:[formatter stringFromNumber:share.unlocked]]];
            [shareView addSubview:[self createItemView:CGRectMake(0, 85 + 7, kScreenWidth, 21) title:@"未释放" value:[formatter stringFromNumber:share.remain]]];
            CGRect frame = topView.frame;
            frame.size.height = frame.size.height + 145;
            topView.frame = frame;
            [topView addSubview:shareView];
            
            [weakself.tableView reloadData];
            
            UITapGestureRecognizer *valueTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(history:)];
            valueTapGesture.delegate = self;
            [shareView addGestureRecognizer:valueTapGesture];
        }
    }];
}

#pragma mark -
#pragma mark - UIGestureRecognizer
- (void)history:(UITapGestureRecognizer*)tapGesture
{
    RCHFlowsController *flowsViewController = [[RCHFlowsController alloc] initWithSelectIndex:2];
    [self.navigationController pushViewController:flowsViewController animated:YES];
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
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RCHFlowsController *flowsViewController = [[RCHFlowsController alloc] init];
        [weakself.navigationController pushViewController:flowsViewController animated:YES];
    });
}

@end
