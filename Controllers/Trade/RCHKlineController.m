//
//  RCHKlineController.m
//  richcore
//
//  Created by WangDong on 2018/7/7.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHKlineController.h"
#import "YBPopupMenu.h"
#import "ZXAssemblyView.h"
#import "RCHKlineItem.h"

@interface RCHKlineController () <YBPopupMenuDelegate,  AssemblyViewDelegate, ZXSocketDataReformerDelegate>

@property (weak, nonatomic) UIView *titleView;
@property (weak, nonatomic) ZXAssemblyView *assenblyView;
@property (nonatomic,assign) ZXTopChartType topChartType;

/**
 *所有数据模型
 */
@property (nonatomic,strong) NSMutableArray *dataArray;
/**
 *当前绘制的指标名
 */
@property (nonatomic,strong) NSString *currentDrawQuotaName;
/**
 *所有的指标名数组
 */
@property (nonatomic,strong) NSArray *quotaNameArr;

@end

@implementation RCHKlineController

- (void)viewDidLoad {
    [super viewDidLoad];
    [RCHGlobal sharedGlobal].isPortrait = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveKlineMessage:) name:kReceiveKlineMessageNotification object:nil];

    self.view.backgroundColor = kTradeBackColor;
    self.view.transform = CGAffineTransformMakeRotation(M_PI_2); //横屏
    
    //这句话必须要,否则拖动到两端会出现白屏
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.topChartType = ZXTopChartTypeTimeLine;
    self.currentDrawQuotaName = self.quotaNameArr[0];
    [self configureData];
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(40.0f);
    }];

    [self.assenblyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleView.mas_bottom);
        make.left.mas_equalTo(0.0f);
        make.height.mas_equalTo(TotalHeight);
        make.width.mas_equalTo(TotalWidth);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [RCHGlobal sharedGlobal].isPortrait = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
#pragma mark - ButtonClicked

- (void)fullButtonClicked:(id)sender
{
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DismissModalViewControllerAnimated(weakself, YES);
    });
}

#pragma mark -
#pragma mark - CustomFuction

- (void)configureData
{
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
        NSString *item = [NSString stringWithFormat:@"%f,%@,%@,%@,%@,%@", obj.timestamp, obj.close, obj.open, obj.high, obj.low, obj.volume];
        [allItems addObject:item];
    }];

    //==精度计算
    NSInteger precision = [self calculatePrecisionWithOriginalDataArray:allItems];


    NSArray *transformedDataArray =  [[ZXDataReformer sharedInstance] transformDataWithOriginalDataArray:allItems currentRequestType:@"M1"];
    [self.dataArray addObjectsFromArray:transformedDataArray];


    //====绘制k线图
    RCHMarket *currentMarket = [[RCHGlobal sharedGlobal] currentMarket];
    NSString *symbol = [NSString stringWithFormat:@"%@/%@",  currentMarket.coin.code, currentMarket.currency.code];
    [self.assenblyView drawHistoryCandleWithDataArr:self.dataArray precision:(int)precision stackName:symbol needDrawQuota:self.currentDrawQuotaName];

    //如若有socket实时绘制的需求，需要实现下面的方法
    //socket
    //定时器不再沿用
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

#pragma mark -
#pragma mark - 画指标
//在返回的数据里面。可以调用预置的指标接口绘制指标，也可以根据返回的数据自己计算数据，然后调用绘制接口进行绘制
- (void)drawQuotaWithCurrentDrawQuotaName:(NSString *)currentDrawQuotaName
{
    
    if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[0]])
    {
        //macd绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithMACD];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[1]])
    {
        
        //KDJ绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithKDJ];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[2]])
    {
        
        //BOLL绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithBOLL];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[3]])
    {
        
        //RSI绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithRSI];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[4]])
    {
        
        //Vol绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithVOL];
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
#pragma mark - setter

-(void)setDatas:(NSMutableArray *)datas
{
    _datas = datas;
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
        [view setBackgroundColor:[UIColor redColor]];
        [self.view addSubview:view];
        
        UIButton *full = [UIButton buttonWithType:UIButtonTypeCustom];
        [full setTitle:NSLocalizedString(@"全屏",nil) forState:UIControlStateNormal];
        [full setImage:fullImage forState:UIControlStateNormal];
        [full setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        full.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        [full setTitleColor:kTradeBorderColor forState:UIControlStateNormal];
        [full setTitleColor:kFontLightGrayColor forState:UIControlStateHighlighted];
        [full addTarget:self action:@selector(fullButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:full];
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
        
        _titleView = view;
    }
    return _titleView;
}

- (ZXAssemblyView *)assenblyView
{
    if (!_assenblyView) {
        //仅仅只有k线的初始化方法
        //                _assenblyView = [[ZXAssemblyView alloc] initWithDrawJustKline:YES];
        //带指标的初始化
        ZXAssemblyView *assenblyView = [[ZXAssemblyView alloc] init];
        assenblyView.backgroundColor = [UIColor clearColor];
        assenblyView.delegate = self;
        
        [self.view addSubview:assenblyView];
        _assenblyView = assenblyView;
    }
    return _assenblyView;
}

- (NSArray *)quotaNameArr
{
    if (!_quotaNameArr) {
        _quotaNameArr = @[@"MACD",@"KDJ",@"BOLL",@"RSI",@"VOL"];
    }
    return _quotaNameArr;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
