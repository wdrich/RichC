//
//  ZXHeader.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//


static NSString *const kOpen  = @"kOpen";
static NSString *const kClose = @"kClose";
static NSString *const kHigh  = @"kHigh";
static NSString *const kLow   = @"kLow";
//
static NSString *const kDrawJustKline   = @"kDrawJustKline";
//
static NSString *const kMA1Day = @"MA1Day";
static NSString *const kMA2Day = @"MA2Day";
static NSString *const kMA3Day = @"MA3Day";
/**
 * 请求更多的回掉
 */
typedef NS_ENUM(NSUInteger, RequestMoreResultType) {
    //成功(包括成功后数据个数为0)
    RequestMoreResultTypeSuccess = 0,
    //网络请求失败
    RequestMoreResultTypeFailure,
    //没有实现请求更多的代理方法
    RequestMoreResultTypeNotRealize,
};

typedef void (^SuccessBlock) (RequestMoreResultType resultType,NSArray *result);
/**
 * 上半部分;默认是第一个值,如果需要改默认,可以修改顺序
 * 如果第一个修改为分时线的话,下面的第一个名称也需要切换到成交量
 */
typedef NS_ENUM(NSUInteger,ZXTopChartType)
{
    ZXTopChartTypeCandle,/*蜡烛*/
    ZXTopChartTypeBrokenLine,/*折线*/
    ZXTopChartTypeTimeLine,/*分时线*/
};
/**
 * 绘制的指标类型
 */
typedef NS_ENUM(NSUInteger, QuotaType) {
    QuotaTypeLine = 0,
    QuotaTypeColumn,
    QuotaTypeSynthsis,
};
/**
 * 预置指标的名称，第一个是预设的类型
 */
typedef NS_ENUM(NSUInteger, PresetQuotaName) {
    PresetQuotaNameWithVOL = 0,
    PresetQuotaNameWithKDJ,
    PresetQuotaNameWithBOLL,
    PresetQuotaNameWithRSI,
    PresetQuotaNameWithMACD,
};
/**
 * 线状柱或者柱状柱
 */
typedef NS_ENUM(NSUInteger, ColumnWidthType) {
    ColumnWidthTypeEqualCandle = 0,
    ColumnWidthTypeEqualLine,
};
//只绘制k线
#define DrawJustKline [[NSUserDefaults standardUserDefaults] boolForKey:kDrawJustKline]
//字体
#define FontSize 9.0f

#define BlueColor [UIColor colorWithRed:0.08 green:0.46 blue:0.70 alpha:1]
#define PurpleColor [UIColor colorWithRed:0.91 green:0.28 blue:0.51 alpha:1]
#define YellowColor [UIColor colorWithRed:0.93 green:0.71 blue:0.40 alpha:1]
/**
 * 蜡烛图-上涨颜色
 */
#define RISECOLOR kTradePositiveColor
/**
 * 蜡烛图-下跌颜色
 */
#define DROPCOLOR kTradeNegativeColor

//颜色背景系列
#define DarkBackgroundColor //WhiteBackgroundColor

//均线颜色
#define MA1Color  PurpleColor
#define MA2Color  YellowColor
#define MA3Color  BlueColor


//指标线颜色
#ifdef  DarkBackgroundColor
#define QuotaDIFFCOLOR [UIColor whiteColor]
#define QuotaDEACOLOR  YellowColor

#define QuotaKCOLOR [UIColor whiteColor]
#define QuotaDCOLOR YellowColor
#define QuotaJCOLOR PurpleColor

#define QuotaBOOLUPCOLOR YellowColor
#define QuotaBOOLMBCOLOR [UIColor whiteColor]
#define QuotaBOOLDNCOLOR PurpleColor

#define QuotaRSI_6 [UIColor whiteColor]
#define QuotaRSI_12 YellowColor
#define QuotaRSI_24 PurpleColor
#else
#define QuotaDIFFCOLOR [UIColor darkGrayColor]
#define QuotaDEACOLOR [UIColor blueColor]

#define QuotaKCOLOR [UIColor darkGrayColor]
#define QuotaDCOLOR YellowColor
#define QuotaJCOLOR PurpleColor

#define QuotaBOOLUPCOLOR YellowColor
#define QuotaBOOLMBCOLOR [UIColor darkGrayColor]
#define QuotaBOOLDNCOLOR PurpleColor

#define QuotaRSI_6 [UIColor darkGrayColor]
#define QuotaRSI_12 YellowColor
#define QuotaRSI_24 PurpleColor
#endif


#ifdef DarkBackgroundColor
//黑色背景系列
#define BackgroundColor kTradeBackColor
//长按横竖线和跳跃线颜色
#define CoordinateDisPlayLabelColor kTradeBorderColor
//网格线颜色
#define GrateLineColor [UIColor clearColor]
#define GrateBorderLineColor kNavigationColor_MB
#define GrateTimeBackGroundColor kNavigationColor_MB
#define GrateTimeTitleColor kTradeBorderColor  //网格线显示时间的文字颜色
#define lightGrayBackGroundColor [UIColor colorWithRed:(245.0/255.0f) green:(245.0/255.0f) blue:(245.0/255.0f) alpha:1]
//显示字体颜色
#define lightGrayTextColor kTradeBorderColor
//==============================================
#else
//白色背景系列
#define BackgroundColor [UIColor whiteColor]
#define GrateBorderLineColor kTradeBackLightColor
#define CoordinateDisPlayLabelColor [UIColor blackColor]
#define GrateLineColor [UIColor colorWithRed:(235/255.0f) green:(237/255.0f) blue:(240/255.0f) alpha:1]
#define lightGrayBackGroundColor [UIColor colorWithRed:(245/255.0f) green:(245/255.0f) blue:(245/255.0f) alpha:1]
#define GrateTimeBackGroundColor kTradeBorderColor
#define GrateTimeTitleColor [UIColor whiteColor]
#define lightGrayTextColor [UIColor colorWithRed:(153/255.0f) green:(153/255.0f) blue:(153/255.0f) alpha:1]
//==============================================
#endif



/**
 * 价格坐标系在右边？YES->右边；NO->左边
 */
#define PriceCoordinateIsInRight NO

/**
 * 显示时间的view
 */
#define TimeViewHeight 12.0

#define VerticalCoordinatesWidth (PriceCoordinateIsInRight?80:60)  //jump距离边缘的位置
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
/**
 * 适用于横竖屏的时候，宽度总是小值，高度总是大值
 */
#define KSCREEN_WIDTH    MIN(SCREEN_WIDTH,SCREEN_HEIGHT)
#define KSCREEN_HEIGHT   MAX(SCREEN_WIDTH,SCREEN_HEIGHT)
/**
 * 横竖屏方向
 */
#define Orientation [[UIApplication sharedApplication] statusBarOrientation]
/**
 * 当前屏幕方向是否竖屏  YES—>竖屏  NO->横屏
 */
//#define Portrait (Orientation==UIDeviceOrientationPortrait||Orientation==UIDeviceOrientationPortraitUpsideDown)
#define Portrait [RCHGlobal sharedGlobal].isPortrait
#define LandscapeLeft (Orientation == UIDeviceOrientationLandscapeLeft)

//k线图边框距离画布上下左右距离
//横屏的时候顶部设置距离为40;项目需求
#define TopMargin (Portrait?0.0f:0.0f)
#define BottomMargin (Portrait?0.0f:0.0f)
#define ZXLeftMargin (Portrait?0.0f:TabbarSafeBottomMargin)
#define ZXRightMargin 0.0f


#define CandleTopMargin (DrawJustKline?60:25)
#define CandleBottomMargin (DrawJustKline?100:20)
#define QuotaTopMargin 20
#define QuotaBottomMargin 0


/**
 * 蜡烛高度+指标高度-->针对横屏->KSCREEN_WIDTH相当于屏高
 */
#define LandScapeChartHeight (TotalHeight-TopMargin-BottomMargin-TimeViewHeight-MiddleBlankSpace)
/**
 * 高度比率
 */
#define HeightScale  (KSCREEN_HEIGHT/667.0)
/**
 * 总高度-->这里根据实际情况而定，为屏幕中给k线图预留位置的高度；根据实际需求
 k线图TotalHeight = 屏幕高度 - 其他自定义控件或者系统控件高度和
 */
#define TotalHeight (Portrait ? 340.0f : KSCREEN_WIDTH - 40.0f -40.0f)

/**
 * 蜡烛高度+指标高度-->针对竖屏
 */
#define PortraitChartHeight (TotalHeight-TopMargin-BottomMargin-TimeViewHeight-MiddleBlankSpace)
/**
 * 上部蜡烛高度;
 */
#define CandleChartHeightJustKline  (Portrait ? (PortraitChartHeight) : (LandScapeChartHeight/3.0*2))
//#define CandleChartHeightKlineWithQuota  (Portrait ? (PortraitChartHeight/3.0*2) : (LandScapeChartHeight/3.0*2))
#define CandleChartHeightKlineWithQuota  (Portrait ? (248.0f - TopMargin) : (LandScapeChartHeight/3.0*2))
#define CandleChartHeight  DrawJustKline?CandleChartHeightJustKline:CandleChartHeightKlineWithQuota


/**
 * 下部部指标高度
 */
#define QuotaChartHeightJustKline  (Portrait ? (0.01) : (0.01))
#define QuotaChartHeightKlineWithQuota   (Portrait ? (80.0f - BottomMargin) : (LandScapeChartHeight/3.0*1))
#define QuotaChartHeight   (DrawJustKline ? QuotaChartHeightJustKline : QuotaChartHeightKlineWithQuota)
/**
 * 蜡烛和指标之间的间隔
 */
#define MiddleBlankSpace   (DrawJustKline?0:(Portrait ? 0 : 10))

#define PortraitCandleWidth      (PriceCoordinateIsInRight ? (KSCREEN_WIDTH-VerticalCoordinatesWidth-ZXLeftMargin-ZXRightMargin) : (KSCREEN_WIDTH-ZXLeftMargin-ZXRightMargin))



#define ZX_IS_IPHONE_X (KSCREEN_HEIGHT == 812.0)
#define SafeAreaTopMargin  (LandscapeLeft ? 44 : 34)
#define SafeAreaBottomMargin (LandscapeLeft ? 34 : 44)

#define LanscapeCandleWidth      (PriceCoordinateIsInRight ? (ZX_IS_IPHONE_X?(KSCREEN_HEIGHT-VerticalCoordinatesWidth-SafeAreaTopMargin-SafeAreaBottomMargin):(KSCREEN_HEIGHT-VerticalCoordinatesWidth-ZXLeftMargin-ZXRightMargin)) :(ZX_IS_IPHONE_X?(KSCREEN_HEIGHT-SafeAreaTopMargin-SafeAreaBottomMargin):(KSCREEN_HEIGHT-ZXLeftMargin-ZXRightMargin - 60.0f)))


#define PortraitTotalWidth    KSCREEN_WIDTH
#define LanscapeTotalWidth    KSCREEN_HEIGHT - 60.0f
/**
 * 蜡烛图宽度
 */
#define CandleWidth      (Portrait ? (PortraitCandleWidth) : (LanscapeCandleWidth))
/**
 * 总宽度
 */
#define TotalWidth      (Portrait ? (PortraitTotalWidth) : (LanscapeTotalWidth))

/**
 * 竖虚线之间的距离
 */
#define DottedLineIntervalSpace 80
/**
 * 蜡烛缩放的最大宽度
 */
#define CandleMaxWidth 22
/**
 * 蜡烛缩放的最小宽度
 */
#define CandleMinWidth 5



//k线图中是否需要显示股票名和M1...
#define IsDisplayStockOrQuotaName NO

//指标图中是否需要显示VOL...
#define IsDisplayQuotaTypeName NO

//k线图是否显示JumpView
#define IsDisplayJumpView NO


//蜡烛的信息配置的位置：YES->单独的view显示在view顶部；NO->弹框覆盖在蜡烛上
#define IsDisplayCandelInfoInTop NO

#define MessageBoxBorderColor kTradeBorderColor
#define MessageBoxBorderWidth 0.5f

//分时线一屏数据个数 小于100的时候有BUG 绘制K线会crash
//KlineModel *lastModel = self.needDrawKlineArr[self.validDataCount-1]; 这句地址越界
#define TimeLineDataCount 240

#ifndef ZXHeader_h
#define ZXHeader_h


#endif /* ZXHeader_h */
