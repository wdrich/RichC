//
//  RCHKlineView.m
//  richcore
//
//  Created by WangDong on 2018/7/5.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHKlineView.h"
#import "RCHTopBar.h"
#import "YBPopupMenu.h"
#import "RCHPeriodsView.h"
#import "RCHKlineItem.h"
#import "RCHMenuCell.h"
#import "ZXAssemblyView.h"

@interface RCHKlineView() <RCHTopBarDelegate, YBPopupMenuDelegate, ZXSocketDataReformerDelegate>

@property (nonatomic, weak) UIView *titleView;
@property (nonatomic, weak) RCHTopBar *menubar;
@property (nonatomic, assign) NSInteger currentSelected;
@property (nonatomic, strong) NSArray *periodsTitles;
@property (nonatomic, copy) NSString *periodsTitle;
@property (nonatomic, assign) NSInteger currentResolution;
@property (nonatomic, weak) ZXAssemblyView *assenblyView;
@property (nonatomic, assign) ZXTopChartType topChartType;
@property (nonatomic, copy) NSString *requestType;
@property (nonatomic, copy) NSString *requestTypeBak;

@property (nonatomic,strong) NSMutableArray *dataArray; //所有数据模型
@property (nonatomic,strong) NSString *currentDrawQuotaName; //当前绘制的指标名



@end

@implementation RCHKlineView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = newSuperview.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveKlineMessage:) name:kReceiveKlineMessageNotification object:nil];
        
        self.topChartType = ZXTopChartTypeCandle;
        self.periodsTitle = @"15分";
        self.currentResolution = 15;
        self.currentDrawQuotaName = @"VOL";
        self.requestType = @"M15";
        self.requestTypeBak = self.requestType;
//        [self configureData];
        //    self.gotoURL = @"https://www.richcore.com/m/trend/ETH_BTC/1";
        _currentSelected = 0;
        
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self);
            make.height.mas_equalTo(40.0f);
        }];
        
        [self.assenblyView mas_makeConstraints:^(MASConstraintMaker *make) {
            
//            make.top.mas_equalTo(self.titleView.mas_bottom).offset(0.0f);
            make.top.mas_equalTo(40.0f);
            make.left.mas_equalTo(0.0f);
            make.height.mas_equalTo(TotalHeight);
            make.width.mas_equalTo(TotalWidth);
        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - CustomFuction

- (void)configureData
{
    
    //=数据获取
    NSMutableArray *allItems = [NSMutableArray array];
    
    //将请求到的数据数组传递过去，并且精度也是需要你自己传;
    /*
     数组中数据格式:@[@"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"...",
     @"..."];
     */
    [self.datas enumerateObjectsUsingBlock:^(RCHKlineItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *item = [NSString stringWithFormat:@"%f,%@,%@,%@,%@,%@", obj.timestamp / 1000, obj.close, obj.open, obj.high, obj.low, obj.volume];
        [allItems addObject:item];
    }];

    //==精度计算
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    NSInteger precision = [RCHHelper getPrecision:market.price_step];
//    NSInteger precision = [self calculatePrecisionWithOriginalDataArray:allItems];
    
    NSArray *transformedDataArray =  [[ZXDataReformer sharedInstance] transformDataWithOriginalDataArray:allItems currentRequestType:self.requestType]; //@"M1"
    [self.dataArray addObjectsFromArray:transformedDataArray];

    //====绘制k线图
//    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
//    NSString *symbol = [NSString stringWithFormat:@"%@/%@",  currentMarket.coin.code, currentMarket.currency.code];
    [self.assenblyView drawHistoryCandleWithDataArr:self.dataArray precision:(int)precision stackName:@"" needDrawQuota:self.currentDrawQuotaName];
    [ZXSocketDataReformer sharedInstance].delegate = self;
    
}

- (NSInteger)calculatePrecisionWithOriginalDataArray:(NSArray *)dataArray
{
    NSString *dataString = dataArray.lastObject;
    NSArray *strArr = [dataString componentsSeparatedByString:@","];
    //取的最高值
    NSInteger maxPrecision = [self calculatePrecisionWithPrice:strArr[3]];
    return maxPrecision;
}

- (NSInteger)calculatePrecisionWithPrice:(NSString *)price
{
    //计算精度
    NSInteger dig = 0;
    if ([price containsString:@"."]) {
        NSArray *com = [price componentsSeparatedByString:@"."];
        dig = ((NSString *)com.lastObject).length;
    }
    return dig;
}

- (NSArray *)getTitles
{
    return @[@{
                 @"title": self.periodsTitle,
                 @"image": RCHIMAGEWITHNAMED(@"ico_arrow_trade")
                 },
             @{
                 @"title": @"日线"
                 },
             @{
                 @"title": @"周线"
                 }
             ];
}

- (NSInteger)getResolution:(NSInteger)index
{
    NSInteger resolution = 1;
    switch (index) {
        case 1:
            resolution = 1;
            self.requestType = @"M1";
            break;
        case 2:
            resolution = 5;
            self.requestType = @"M5";
            break;
        case 3:
            resolution = 15;
            self.requestType = @"M15";
            break;
        case 4:
            resolution = 30;
            self.requestType = @"M30";
            break;
        case 5:
            resolution = 60;
            self.requestType = @"H1";
            break;
        case 6:
            resolution = 2*60;
            self.requestType = @"H1";
            break;
        case 7:
            resolution = 4*60;
            self.requestType = @"H4";
            break;
        case 8:
            resolution = 6*60;
            self.requestType = @"H4";
            break;
        case 9:
            resolution = 12*60;
            self.requestType = @"H4";
            break;
            
        default:
            resolution = 1;
            self.requestType = @"M1";
            break;
    }
    
    self.requestTypeBak = self.requestType;
    return resolution;
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)fullButtonClicked:(id)sender
{
    !self.fullScreen ?: self.fullScreen();
}

- (void)reloadClick:(id)sender
{
    self.currentResolution = [self getResolution:((UIButton *)sender).tag];
    !self.reloadBlock ?: self.reloadBlock(self.currentResolution);
}

- (void)periodClick:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    [YBPopupMenu showRelyOnView:button titles:@[@""] icons:nil menuWidth:self.width - 20.0f otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.tag = 100;
        popupMenu.dismissOnSelected = YES;
        popupMenu.delegate = self;
        popupMenu.type = YBPopupMenuTypeDefault;
        popupMenu.cornerRadius = 4.0f;
        popupMenu.itemHeight = 105.0f;
        popupMenu.backColor = kTradeBackLightColor;
        popupMenu.borderWidth = 1.0f;
        popupMenu.borderColor = [kNavigationColor_MB colorWithAlphaComponent:0.5];
        popupMenu.isShowShadow = NO;
        popupMenu.offset = 7.0f;
    }];
}

#pragma mark -
#pragma mark - Notification

- (void)receiveKlineMessage:(NSNotification *)notification {
    RCHKlineItem *kline = [RCHKlineItem mj_objectWithKeyValues:[[notification userInfo] objectForKey:@"data"]];
    NSString *stream = [[notification userInfo] objectForKey:@"stream"];
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
    NSString *symbol = [NSString stringWithFormat:@"%@%@",  currentMarket.coin.code, currentMarket.currency.code].lowercaseString;
    if ([stream containsString:symbol]) {
        RCHDispatch_main_async_safe(^{
            [[ZXSocketDataReformer sharedInstance] bulidNewKlineModelWithNewPrice:[kline.close doubleValue] timestamp:kline.timestamp / 1000  volumn:[NSNumber numberWithString:kline.volume] dataArray:self.dataArray isFakeData:NO];
        });
    }
}

#pragma mark -
#pragma mark - ZXSocketDataReformerDelegate

- (void)bulidSuccessWithNewKlineModel:(KlineModel *)newKlineModel
{
    //维护控制器数据源
    if (newKlineModel.isNew) {
        [self.dataArray addObject:newKlineModel];
        [[ZXQuotaDataReformer sharedInstance] handleQuotaDataWithDataArr:self.dataArray model:newKlineModel index:self.dataArray.count-1];
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
    }else{
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
        
        [[ZXQuotaDataReformer alloc] handleQuotaDataWithDataArr:self.dataArray model:newKlineModel index:self.dataArray.count-1];
        
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
    }
    //绘制最后一个蜡烛
    [self.assenblyView drawLastKlineWithNewKlineModel:newKlineModel];
}



#pragma mark -
#pragma mark - YBPopupMenuDelegate
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index
{
}

- (UITableViewCell *)ybPopupMenu:(YBPopupMenu *)ybPopupMenu cellForRowAtIndex:(NSInteger)index
{
    static NSString *MenuCellIdentifer = @"MenuCellIdentifer";
    UITableViewCell * cell = [ybPopupMenu.tableView dequeueReusableCellWithIdentifier:MenuCellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuCellIdentifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;
        cell.contentView.userInteractionEnabled = YES;
    }
    
    RCHWeak(self);
    RCHPeriodsView *view = [[RCHPeriodsView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {345.0f, 105.0f}}];
    view.titles = self.periodsTitles;
    view.onChanged = ^(UIButton *sender) {
        if (weakself.periodsTitles.count > sender.tag) {
            weakself.periodsTitle = [weakself.periodsTitles objectAtIndex:sender.tag];
            [weakself.menubar loadTitleArray:[self getTitles]];
            if (!sender.tag) {
                if (weakself.topChartType == ZXTopChartTypeCandle) {
                    weakself.topChartType = ZXTopChartTypeBrokenLine;
                    [weakself.assenblyView switchTopChartWithTopChartType:weakself.topChartType];
                }
            } else {
                if (weakself.topChartType == ZXTopChartTypeBrokenLine) {
                    weakself.topChartType = ZXTopChartTypeCandle;
                    [weakself.assenblyView switchTopChartWithTopChartType:weakself.topChartType];
                }
                [weakself reloadClick:sender];
            }
            
        }
        [ybPopupMenu dismiss];
    };
    [cell.contentView addSubview:view];

    return cell;
}


#pragma mark -
#pragma mark - RCHTopBarDelegate
- (void)piecewiseView:(RCHTopBar *)piecewiseView button:(UIButton *)button index:(NSInteger)index
{
    NSInteger resolution;
    if (index == _currentSelected) {
        if (index == 0) {
            [self periodClick:button];
        }
    } else {
        _currentSelected = index;
        
        switch (_currentSelected) {
            case 0:
                resolution = self.currentResolution;
                self.requestType = self.requestTypeBak;
                break;
            case 1:
                resolution = KlineModelTypeDay;
                self.requestType = @"D1";
                break;
            case 2:
                resolution = KlineModelTypeWeek;
                self.requestType = @"W1";
                break;
            default:
                resolution = self.currentResolution;
                self.requestType = self.requestTypeBak;
                break;
        }
        
        if (index == 0 && [self.periodsTitle isEqualToString:@"分时"]) {
            if (self.topChartType == ZXTopChartTypeCandle) {
                self.topChartType = ZXTopChartTypeBrokenLine;
                [self.assenblyView switchTopChartWithTopChartType:self.topChartType];
                return;
            }
        } else {
            if (self.topChartType == ZXTopChartTypeBrokenLine) {
                self.topChartType = ZXTopChartTypeCandle;
                [self.assenblyView switchTopChartWithTopChartType:self.topChartType];
            }
        }

        
        !self.reloadBlock ?: self.reloadBlock(resolution);
    }
}

#pragma mark -
#pragma mark - setter

-(void)setDatas:(NSMutableArray *)datas
{
    _datas = datas;
    [self.dataArray removeAllObjects];
    [self configureData];
}

#pragma mark -
#pragma mark - getter

- (UIView *)titleView
{
    if(!_titleView)
    {
        CGFloat fullWidth = 47.0f;
        UIImage *fullImage = RCHIMAGEWITHNAMED(@"btn_fullscreen");
        UIView *view = [[UIView alloc] init];
        [view setBackgroundColor:kTradeBackLightColor];
        [self addSubview:view];
        
        UIButton *full = [UIButton buttonWithType:UIButtonTypeCustom];
        [full setTitle:NSLocalizedString(@"全屏",nil) forState:UIControlStateNormal];
        [full setImage:fullImage forState:UIControlStateNormal];
        [full setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        full.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        [full setTitleColor:kTradeBorderColor forState:UIControlStateNormal];
        [full setTitleColor:kFontLightGrayColor forState:UIControlStateHighlighted];
        [full addTarget:self action:@selector(fullButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:full];
        
        full.hidden = YES;
        
        // button标题的偏移量
        full.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -(full.titleLabel.frame.origin.x + 22.0f), 0.0f, 0.0f);
        // button图片的偏移量
        full.imageEdgeInsets = UIEdgeInsetsMake(0.0f, fullWidth - fullImage.size.width, 0.0f, -(full.frame.size.width - full.imageView.frame.origin.x - full.imageView.frame.size.width));
        
        [full mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(view.mas_centerY);
            make.right.mas_equalTo(-15.0f);
            make.width.mas_equalTo(47.0f);
            make.height.mas_equalTo(18.0f);
        }];
        
        CGFloat menubarWidth = 191.0f;
        RCHTopBar *menubar = [[RCHTopBar alloc] initWithFrame:(CGRect){{0.0, 0.0f}, {menubarWidth, 40.0f}}];
        menubar.backgroundColor = [UIColor clearColor];
        menubar.type = PiecewiseInterfaceTypeCustom;
        menubar.delegate = self;
        menubar.textFont = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        menubar.textNormalColor = kTradeBorderColor;
        menubar.isFitTextWidth = NO;
        menubar.lineHeight = 3.0f;
        menubar.lineWidth = 30.0f;
        menubar.itemPadding = 22.0f;
        menubar.textSeletedColor = kAppOrangeColor;
        menubar.linColor = kAppOrangeColor;
        [menubar loadTitleArray:[self getTitles]];
        [view addSubview:menubar];
        
        _menubar = menubar;
        
        [menubar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15.0f);
            make.top.bottom.mas_equalTo(0.0f);
            make.width.mas_equalTo(menubarWidth);
        }];
        
        _titleView = view;
    }
    return _titleView;
}

- (ZXAssemblyView *)assenblyView
{
    if (!_assenblyView) {
        //带指标的初始化
        ZXAssemblyView *assenblyView = [[ZXAssemblyView alloc] init];
        assenblyView.backgroundColor = [UIColor clearColor];
//        assenblyView.delegate = self;
        
        [assenblyView hidePriceView];//隐藏价格栏
//        [assenblyView hideCandleDetailView:YES]; //隐藏指标显示
        [assenblyView hideRotateBtn:YES];//隐藏旋转全屏图标
        
        [self addSubview:assenblyView];
        _assenblyView = assenblyView;
    }
    return _assenblyView;
}

- (NSArray *)periodsTitles
{
    if(_periodsTitles == nil)
    {
        _periodsTitles = @[@"分时", @"1分", @"5分", @"15分", @"30分", @"1小时", @"2小时", @"4小时", @"6小时", @"12小时"];
    }
    return _periodsTitles;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
