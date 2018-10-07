//
//  RCHAuctionView.m
//  richcore
//
//  Created by WangDong on 2018/7/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAuctionView.h"
#import "ZQCountDownView.h"

#define kDefaultString @"--"

@interface RCHAuctionView () <ZQCountDownViewDelegate>
{
    NSString *_finalPrice;
    RCHAuction *_auction;
}

@property (nonatomic, strong) ZQCountDownView *countDownView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UILabel *totalCountLabel;
@property (nonatomic, strong) UILabel *totalUnitLabel;
@property (nonatomic, strong) UILabel *resolvedLabel;
@property (nonatomic, strong) UILabel *assignLabel;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, strong) UILabel *scheduleLabel;

@property (nonatomic, strong) UIImageView *stautsImageView;


@end

@implementation RCHAuctionView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = [UIColor clearColor];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self createUI];
        
        self.layer.borderColor = [kYellowColor colorWithAlphaComponent:0.5].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 0.0;
        self.layer.masksToBounds = YES;

        [self auctionDefault];
        
#ifdef TEST_MODE_CORP

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self startLottery];
//        });

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self finishLottery];
//        });

        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        if ([market.coin.code isEqualToString:@"RCTKK"] || [market.coin.code isEqualToString:@"SBC"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self auctionUnStart:3600 * 12];
            });

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self auctionStart:3600 * 12];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self auctionStart:3600 * 12 + 30];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self auctionStart:10];
            });
        }
#endif
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - CustomFuction

- (void)createUI {
    
    [self removeAllSubviews];
    [self createTopView];
    
    [self addSubview:self.totalLabel];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(76.0f);
        make.left.mas_equalTo(15.0f);
        make.height.mas_equalTo(15.0f);
    }];
    
    [self addSubview:self.totalCountLabel];
    [self.totalCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.totalLabel.mas_centerY);
        make.left.mas_equalTo(self.totalLabel.mas_right);
        make.height.mas_equalTo(26.0f);
    }];
    
    [self addSubview:self.totalUnitLabel];
    
//    self.totalUnitLabel.hidden = YES;
    [self.totalUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.totalLabel.mas_centerY);
        make.left.mas_equalTo(self.totalCountLabel.mas_right).offset(5.0f);
        make.height.mas_equalTo(26.0f);
    }];
    
    
    [self addSubview:self.resolvedLabel];
    [self.resolvedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalLabel.mas_bottom).offset(11.0f);
        make.left.mas_equalTo(self.totalLabel.mas_left);
        make.height.mas_equalTo(14.0f);
    }];
    
    [self addSubview:self.assignLabel];
    [self.assignLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.resolvedLabel.mas_bottom).offset(5.0f);
        make.left.mas_equalTo(self.totalLabel.mas_left);
        make.height.mas_equalTo(14.0f);
    }];
    
    [self addSubview:self.countDownView];
}


- (void)createTopView {
    
    [self removeAllSubviews];

    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0.0f);
        make.height.mas_equalTo(60.0f);
    }];
    
    [self addSubview:self.stautsImageView];
    self.stautsImageView.image = RCHIMAGEWITHNAMED(@"ico_notice_fail");
    [self.stautsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.left.mas_equalTo(5.0f - self.stautsImageView.image.size.width);
        make.size.mas_equalTo(self.stautsImageView.image.size);
    }];
    
    self.stautsImageView.hidden = YES;
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12.0f);
        make.left.mas_equalTo(self.stautsImageView.mas_right).offset(10.0f);
        make.height.mas_equalTo(16.0f);
    }];
    
    [self addSubview:self.countLabel];
    self.countLabel.text = @"";
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2.0f);
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.height.mas_equalTo(18.0f);
    }];

    [self addSubview:self.countDownLabel];
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6.0f);
        make.right.mas_equalTo(-10.0f);
        make.height.mas_equalTo(14.0f);
    }];
    
    [self addSubview:self.scheduleLabel];
    [self.scheduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23.0f);
        make.right.mas_equalTo(-10.0f);
        make.width.mas_equalTo(89.0f);
        make.height.mas_equalTo(28.0f);
    }];
}


- (void)auctionDefault
{
    self.titleLabel.text =@"";
    
    self.countLabel.text = @"";
    self.assignLabel.text = @"";
    self.resolvedLabel.text = @"";
    self.totalCountLabel.text = @"";
    
    self.stautsImageView.image = nil;
    
    [self.countDownView stopCountDown];
    self.countDownLabel.text = @"";
    self.countDownView.hidden = YES;
    
    self.totalLabel.hidden = YES;
    self.totalCountLabel.hidden = YES;
    self.totalUnitLabel.hidden = YES;
    
    
    self.scheduleLabel.text = @"";
    [self.scheduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.0f);
        make.height.mas_equalTo(0.0f);
    }];
}


- (void)auctionUnStart:(NSTimeInterval)timeInterval
{
    //    [self.countDownView removeFromSuperview];
    //    [self addSubview:self.countDownView];
    
    
    self.totalLabel.hidden = NO;
    self.totalCountLabel.hidden = NO;
    self.totalUnitLabel.hidden = NO;
    
    self.countDownView.hidden = NO;
    self.scheduleLabel.hidden = YES;
    
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
    self.titleLabel.text = NSLocalizedString(@"秒杀即将开始！",nil);
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.left.mas_equalTo(self.stautsImageView.mas_right).offset(10.0f);
        make.height.mas_equalTo(16.0f);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.right.mas_equalTo(-10.0f);
        make.width.mas_equalTo(90.0f);
        make.height.mas_equalTo(28.0f);
    }];
    
    self.countLabel.text = @"";
    self.assignLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已成交数量：%@",nil), _auction.orderCount ?: @"--"];
    self.resolvedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已分配奖励累计：%@ %@",nil), _auction.grantReward ?: kDefaultString, market.currency.code ?: @""];
    self.totalCountLabel.text = [NSString stringWithFormat:@"%@", _auction.sumReward ?: kDefaultString];
    
    self.stautsImageView.image = nil;
    [self.stautsImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.left.mas_equalTo(5.0f - self.stautsImageView.image.size.width);
        make.size.mas_equalTo(self.stautsImageView.image.size);
    }];
    
    
    self.countDownView.countDownTimeInterval = timeInterval;
    [self.countDownView stopCountDown];
    [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23.0f);
        make.right.mas_equalTo(-10.0f);
        make.width.mas_equalTo(90.0f);
        make.height.mas_equalTo(28.0f);
    }];
    
    self.countDownLabel.text = NSLocalizedString(@"距结束剩余",nil);
    [self.countDownLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6.0f);
        make.right.mas_equalTo(-10.0f);
        make.height.mas_equalTo(14.0f);
    }];
    
    
    [self.scheduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.0f);
        make.height.mas_equalTo(0.0f);
    }];
}

- (void)auctionStart:(NSTimeInterval)timeInterval
{
    self.countDownView.hidden = NO;
    
    self.totalLabel.hidden = NO;
    self.totalCountLabel.hidden = NO;
    self.totalUnitLabel.hidden = NO;
    self.scheduleLabel.hidden = YES;
    
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f];
    self.titleLabel.text = NSLocalizedString(@"剩余可能购买数量：",nil);
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12.0f);
        make.left.mas_equalTo(self.stautsImageView.mas_right).offset(10.0f);
        make.height.mas_equalTo(16.0f);
    }];
    
    self.countLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
    self.countLabel.text = _auction.surplusCount ?: @"--";
    [self.countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2.0f);
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.height.mas_equalTo(18.0f);
    }];
    
    [self.countDownView stopCountDown];
    self.countDownView.countDownTimeInterval = timeInterval;
    [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23.0f);
        make.right.mas_equalTo(-10.0f);
        make.width.mas_equalTo(90.0f);
        make.height.mas_equalTo(28.0f);
    }];

    
    self.stautsImageView.image = nil;
    [self.stautsImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.left.mas_equalTo(5.0f - self.stautsImageView.image.size.width);
        make.size.mas_equalTo(self.stautsImageView.image.size);
    }];
    
    self.countDownLabel.text = NSLocalizedString(@"距结束剩余",nil);
    [self.countDownLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6.0f);
        make.right.mas_equalTo(-10.0f);
        make.height.mas_equalTo(14.0f);
    }];
    
    self.assignLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已成交数量：%@",nil), _auction.orderCount ?: @"--"];
    self.resolvedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已分配奖励累计：%@ %@",nil), _auction.grantReward ?: kDefaultString, market.currency.code ?: @""];
    self.totalCountLabel.text = [NSString stringWithFormat:@"%@", _auction.sumReward ?: kDefaultString];
}

- (void)startLottery
{
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    
    self.totalLabel.hidden = NO;
    self.totalCountLabel.hidden = NO;
    self.totalUnitLabel.hidden = NO;
    
    [self.countDownView stopCountDown];
    self.countDownView.hidden = YES;
    
    self.scheduleLabel.hidden = NO;
    
//    [self.countDownView removeFromSuperview];
    self.stautsImageView.hidden = NO;
    self.stautsImageView.image = RCHIMAGEWITHNAMED(@"ico_notice_fail");
    [self.stautsImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.left.mas_equalTo(15.0f);
        make.size.mas_equalTo(self.stautsImageView.image.size);
    }];

    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f];
    self.titleLabel.text = @"抽奖程序已启动，";
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12.0f);
        make.left.mas_equalTo(self.stautsImageView.mas_right).offset(10.0f);
        make.height.mas_equalTo(16.0f);
    }];

    self.countLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
    self.countLabel.text = @"交易可能随时终止！";
    [self.countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2.0f);
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.height.mas_equalTo(18.0f);
    }];

    self.countDownLabel.text = @"下一单中奖率";
    self.scheduleLabel.text = [NSString stringWithFormat:@"%@%%", _auction.winProbable ?: kDefaultString];

    self.assignLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已成交数量：%@",nil), _auction.orderCount ?: @"--"];
    self.resolvedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已分配奖励累计：%@ %@",nil), _auction.grantReward ?: kDefaultString, market.currency.code ?: @""];
    self.totalCountLabel.text = [NSString stringWithFormat:@"%@", _auction.sumReward ?: kDefaultString];

    self.scheduleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
    [self.scheduleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23.0f);
        make.right.mas_equalTo(-10.0f);
        make.width.mas_equalTo(89.0f);
        make.height.mas_equalTo(28.0f);
    }];
}

- (void)finishLottery
{
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    [self.countDownView stopCountDown];
    self.countDownView.hidden = YES;
//    [self.countDownView removeFromSuperview];
    
    self.totalLabel.hidden = NO;
    self.totalCountLabel.hidden = NO;
    self.totalUnitLabel.hidden = NO;
    self.scheduleLabel.hidden = NO;
    
    self.stautsImageView.image = nil;
    [self.stautsImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.left.mas_equalTo(5.0f - self.stautsImageView.image.size.width);
        make.size.mas_equalTo(self.stautsImageView.image.size);
    }];
    
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f];
    self.titleLabel.text = @"最终获奖交易价格：";
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12.0f);
        make.left.mas_equalTo(self.stautsImageView.mas_right).offset(10.0f);
        make.height.mas_equalTo(16.0f);
    }];
    
    self.countLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
    self.countLabel.text = [NSString stringWithFormat:@"%@ %@", _finalPrice ?: kDefaultString , market.currency.code ?: @""];
    [self.countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2.0f);
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.height.mas_equalTo(18.0f);
    }];
    
    self.totalCountLabel.text = [NSString stringWithFormat:@"%@", _auction.sumReward ?: kDefaultString];
    
    self.assignLabel.text = [NSString stringWithFormat:NSLocalizedString(@"活动成交数量：%@",nil), _auction.orderCount ?: kDefaultString];
    self.resolvedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已分配奖励累计：%@ %@",nil), _auction.grantReward ?: kDefaultString, market.currency.code ?: @""];

    self.countDownLabel.text = @"";
    self.scheduleLabel.text = @"抽奖已结束";
    self.scheduleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f];
    [self.scheduleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.right.mas_equalTo(-10.0f);
        make.width.mas_equalTo(80.0f);
        make.height.mas_equalTo(28.0f);
    }];
}

- (void)updateInfo
{
    NSTimeInterval startInterval = [[NSDate dateWithISOFormatString:_auction.activtedAt] timeIntervalSinceNow];
    NSTimeInterval timeInterval = [[NSDate dateWithISOFormatString:_auction.closedDate] timeIntervalSinceNow];
    
    if (startInterval > 0) {
        NSInteger time = [_auction.duration integerValue];
        [self auctionUnStart:time];
        return;
    }
    
    if (timeInterval > 0) {
        if (_auction.isDraw) {
            [self startLottery];
        }  else {
            [self auctionStart:timeInterval];
        }
    } else {
        [self finishLottery];
    }
}

- (void)setAuctionTxInfo:(RCHAuctionTx *)auctionTx
{
    if (RCHIsEmpty(auctionTx)) {
        return;
    }
    
    NSTimeInterval timeInterval = [[NSDate dateWithISOFormatString:_auction.closedDate] timeIntervalSinceNow];
    _finalPrice = [RCHHelper getNSDecimalString:[NSDecimalNumber numberWithString:auctionTx.price] defaultString:@"--" precision:8];
    if (timeInterval <= 0) {
#ifdef TEST_MODE_CORP
        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        if ([market.coin.code isEqualToString:@"RCTKK"] || [market.coin.code isEqualToString:@"SBC"]) {
        } else {
            [self updateInfo];
        }
#else
        [self updateInfo];
#endif
    }
}

- (void)setAuctionInfo:(RCHAuction *)auction
{
    if (RCHIsEmpty(auction)) {
        return;
    }
    _auction = auction;
#ifdef TEST_MODE_CORP
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    if ([market.coin.code isEqualToString:@"RCTKK"] || [market.coin.code isEqualToString:@"SBC"]) {
    } else {
        [self updateInfo];
    }
#else
    [self updateInfo];
#endif
    
}


#pragma mark -
#pragma mark - setter
- (ZQCountDownView *)countDownView
{
    if(!_countDownView)
    {
        ZQCountDownView *countDownView = [[ZQCountDownView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {90.0f, 28.0f}}];
        countDownView.themeColor = [UIColor whiteColor];
        countDownView.textColor = kYellowColor;
        countDownView.textFont = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
        countDownView.colonColor = [UIColor whiteColor];
        countDownView.lableCornerRadius = 2.0f;
        countDownView.delegate = self;
        _countDownView = countDownView;
    }
    return _countDownView;
}

- (UIView *)topView
{
    if(!_topView)
    {
        UIView *topView = [[UIView alloc] initWithFrame:CGRectZero];
        topView.backgroundColor = kYellowColor;
        _topView = topView;
    }
    return _topView;
}


- (UILabel *)titleLabel
{
    if(!_titleLabel)
    {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = NSLocalizedString(@"剩余可能购买数量：",nil);
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)countLabel
{
    if(!_countLabel)
    {
        UILabel *countLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {90.0f, 28.0f}}];
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.textColor = [UIColor whiteColor];
        countLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
        countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel = countLabel;
    }
    return _countLabel;
}

- (UILabel *)totalLabel
{
    if(!_totalLabel)
    {
        UILabel *totalLabel = [[UILabel alloc] init];
        totalLabel.backgroundColor = [UIColor clearColor];
        totalLabel.textColor = kYellowColor;
        totalLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f];
        totalLabel.textAlignment = NSTextAlignmentLeft;
        totalLabel.text = NSLocalizedString(@"最终奖励累计：",nil);
        _totalLabel = totalLabel;
    }
    return _totalLabel;
}

- (UILabel *)resolvedLabel
{
    if(!_resolvedLabel)
    {
        UILabel *resolvedLabel = [[UILabel alloc] init];
        resolvedLabel.backgroundColor = [UIColor clearColor];
        resolvedLabel.textColor = kTextUnselectColor;
        resolvedLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        resolvedLabel.textAlignment = NSTextAlignmentLeft;
        resolvedLabel.text = NSLocalizedString(@"已分配奖励累计：",nil);
        _resolvedLabel = resolvedLabel;
    }
    return _resolvedLabel;
}

- (UILabel *)assignLabel
{
    if(!_assignLabel)
    {
        UILabel *assignLabel = [[UILabel alloc] init];
        assignLabel.backgroundColor = [UIColor clearColor];
        assignLabel.textColor = kTextUnselectColor;
        assignLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        assignLabel.textAlignment = NSTextAlignmentLeft;
        assignLabel.text = NSLocalizedString(@"已成交数量：",nil);
        _assignLabel = assignLabel;
    }
    return _assignLabel;
}

- (UILabel *)countDownLabel
{
    if(!_countDownLabel)
    {
        UILabel *countDownLabel = [[UILabel alloc] init];
        countDownLabel.backgroundColor = [UIColor clearColor];
        countDownLabel.textColor = [UIColor whiteColor];
        countDownLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        countDownLabel.textAlignment = NSTextAlignmentLeft;
        countDownLabel.text = NSLocalizedString(@"距结束剩余",nil);
        _countDownLabel = countDownLabel;
    }
    return _countDownLabel;
}

- (UILabel *)scheduleLabel
{
    if(!_scheduleLabel)
    {
        UILabel *scheduleLabel = [[UILabel alloc] init];
        scheduleLabel.layer.cornerRadius = 2.0;
        scheduleLabel.layer.masksToBounds = YES;
        scheduleLabel.backgroundColor = [UIColor whiteColor];
        scheduleLabel.textColor = kYellowColor;
        scheduleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
        scheduleLabel.textAlignment = NSTextAlignmentCenter;
//        scheduleLabel.text = NSLocalizedString(@"32.18%",nil);
//        [self addSubview:scheduleLabel];
        _scheduleLabel = scheduleLabel;
    }
    return _scheduleLabel;
}

- (UILabel *)totalCountLabel
{
    if(!_totalCountLabel)
    {
        UILabel *totalCountLabel = [[UILabel alloc] init];
        totalCountLabel.layer.cornerRadius = 2.0;
        totalCountLabel.layer.masksToBounds = YES;
        totalCountLabel.backgroundColor = [UIColor clearColor];
        totalCountLabel.textColor = kYellowColor;
        totalCountLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24.0f];
        totalCountLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:totalCountLabel];
        _totalCountLabel = totalCountLabel;
    }
    return _totalCountLabel;
}

- (UILabel *)totalUnitLabel
{
    
    if(!_totalUnitLabel)
    {
        RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
        UILabel *totalUnitLabel = [[UILabel alloc] init];
        totalUnitLabel.layer.cornerRadius = 2.0;
        totalUnitLabel.layer.masksToBounds = YES;
        totalUnitLabel.backgroundColor = [UIColor clearColor];
        totalUnitLabel.textColor = kYellowColor;
        totalUnitLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f];
        totalUnitLabel.textAlignment = NSTextAlignmentCenter;
        totalUnitLabel.text = market.currency.code ?: @"";
        [self addSubview:totalUnitLabel];
        _totalUnitLabel = totalUnitLabel;
    }
    return _totalUnitLabel;
}

- (UIImageView *)stautsImageView
{
    if(!_stautsImageView)
    {
        UIImageView *stautsImageView = [[UIImageView alloc] init];
        _stautsImageView = stautsImageView;
    }
    return _stautsImageView;
}

#pragma mark -
#pragma mark - ZQCountDownViewDelegate
- (void)countDownDidFinished
{
//    [self.scheduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(23.0f);
//        make.right.mas_equalTo(-10.0f);
//        make.width.mas_equalTo(89.0f);
//        make.height.mas_equalTo(28.0f);
//    }];
    
#ifdef TEST_MODE_CORP
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    if ([market.coin.code isEqualToString:@"RCTKK"] || [market.coin.code isEqualToString:@"SBC"]) {
        [self startLottery];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self finishLottery];
        });
    } else {
        [self finishLottery];
    }

#else
    [self finishLottery];
#endif


    !self.countFinish ?: self.countFinish();
}

@end
