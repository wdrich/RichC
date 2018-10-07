//
//  RCHKlineLandscapeView.m
//  richcore
//
//  Created by WangDong on 2018/7/10.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHKlineLandscapeView.h"
#import "YBPopupMenu.h"
#import "ZXAssemblyView.h"

@interface RCHKlineLandscapeView() <YBPopupMenuDelegate,  AssemblyViewDelegate, ZXSocketDataReformerDelegate>

@property (nonatomic,weak) ZXAssemblyView *assenblyView;
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

@implementation RCHKlineLandscapeView


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = newSuperview.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = kYellowColor;
        
        self.topChartType = ZXTopChartTypeTimeLine;
        self.currentDrawQuotaName = self.quotaNameArr[0];
        [self configureData];

//        [self.assenblyView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(40.0f);
//            make.left.mas_equalTo(0.0f);
//            make.height.mas_equalTo(TotalHeight);
//            make.width.mas_equalTo(TotalWidth);
//        }];
        CGFloat height = TotalHeight;
        NSLog(@"%f", height);
    }
    return self;
}

#pragma mark -
#pragma mark - CustomFuction

- (void)configureData
{
    
    //=数据获取
    NSString *path = [[NSBundle mainBundle] pathForResource:@"kData" ofType:@"plist"];
    NSArray *kDataArr = [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i<100
         ; i++) {
        [tempArray addObject:kDataArr[i]];
    }
    
    
    
    
    //==精度计算
    NSInteger precision = [self calculatePrecisionWithOriginalDataArray:kDataArr];
    
    
    
    
    //将请求到的数据数组传递过去，并且精度也是需要你自己传;
    /*
     数组中数据格式:@[@"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"...",
     @"..."];
     */
    /*如果的数据格式和此demo中不同，那么你需要点进去看看，并且修改响应的取值为你的数据格式;
     修改数据格式→  ↓↓↓↓↓↓↓点它↓↓↓↓↓↓↓↓↓  ←
     */
    //===数据处理
    NSArray *transformedDataArray =  [[ZXDataReformer sharedInstance] transformDataWithOriginalDataArray:tempArray currentRequestType:@"M1"];
    [self.dataArray addObjectsFromArray:transformedDataArray];
    
    
    
    
    //====绘制k线图
    [self.assenblyView drawHistoryCandleWithDataArr:self.dataArray precision:(int)precision stackName:@"ETHBTC" needDrawQuota:self.currentDrawQuotaName];
    
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
#pragma mark - getter

- (ZXAssemblyView *)assenblyView
{
    if (!_assenblyView) {
        //仅仅只有k线的初始化方法
        //                _assenblyView = [[ZXAssemblyView alloc] initWithDrawJustKline:YES];
        //带指标的初始化
        ZXAssemblyView *assenblyView = [[ZXAssemblyView alloc] init];
        assenblyView.backgroundColor = [UIColor clearColor];
        assenblyView.delegate = self;
        
        [self addSubview:assenblyView];
        _assenblyView = assenblyView;
    }
    return _assenblyView;
}

- (UIInterfaceOrientation)orientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
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
