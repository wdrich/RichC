//
//  RCHRealtimeAgencyView.m
//  richcore
//
//  Created by Apple on 2018/6/2.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRealtimeAgencyView.h"
#import "YBPopupMenu.h"
#import "RCHMenuCell.h"

#define BORDERWIDTH isRetina ? .5f : 1.f
#define SHOWDEPTHCOUNT 8
#define DEPTHFONTSIZE 13.f
#define DEPTHTEXTHEIGHT 19.f
#define DEPTHASKBGCOLOR RGBA(180.f, 57.f, 63.f, 0.08f)
#define DEPTHBIDBGCOLOR RGBA(62.f, 116.f, 63.f, 0.08f)

@implementation DepthItem

- (id)initWithFrame:(CGRect)frame side:(DepthSide)side onSelected:(void (^)(NSString *, DepthSide))onSelected
{
    self = [super initWithFrame:frame];
    if (self) {
        _side = side;
        _onSelected = [onSelected copy];
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _depth = 0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_depth > 0) {
        CGFloat width = rect.size.width * _depth;
        [UIView drawRoundRectangleInRect:CGRectMake(rect.size.width - width, 0, width, rect.size.height) withRadius:0 color:(_side == DepthSideAsk ? DEPTHASKBGCOLOR : DEPTHBIDBGCOLOR)];
    }
    NSMutableParagraphStyle *priceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    priceParagraphStyle.alignment = NSTextAlignmentLeft;
    
    NSMutableParagraphStyle *amountParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    amountParagraphStyle.alignment = NSTextAlignmentRight;
    
    [(_price ?: @"--") drawInRect:CGRectMake(0, (rect.size.height - DEPTHTEXTHEIGHT) / 2, rect.size.width * 2 / 3, rect.size.height)
                   withAttributes:@{
                                    NSForegroundColorAttributeName: (_side == DepthSideAsk ? kTradeNegativeColor : kTradePositiveColor),
                                    NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:DEPTHFONTSIZE],
                                    NSParagraphStyleAttributeName: priceParagraphStyle
                                    }];
    [(_amount ?: @"--") drawInRect:CGRectMake(rect.size.width * 2 / 3, (rect.size.height - DEPTHTEXTHEIGHT) / 2, rect.size.width / 3, rect.size.height)
                   withAttributes:@{
                                    NSForegroundColorAttributeName: kNavigationColor_MB,
                                    NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:DEPTHFONTSIZE],
                                    NSParagraphStyleAttributeName: amountParagraphStyle
                                    }];
}

- (void)setPrice:(NSString *)price amount:(NSString *)amount depth:(CGFloat)depth
{
    _price = price ? [price copy] : nil;
    _amount = amount ? [amount copy] : nil;
    _depth = depth;
    [self setNeedsDisplay];
}

- (void)selected:(UIGestureRecognizer *)recognizer
{
    if (_onSelected) {
        _onSelected(_price, _side);
    }
}

@end

@interface RCHRealtimeAgencyView ()<UIGestureRecognizerDelegate, YBPopupMenuDelegate>
{
    NSArray *_askItems;
    NSArray *_bidItems;
    UILabel *_priceLabel;
    UILabel *_precisionLabel;
    NSUInteger _precision;
    NSUInteger _currentPrecision;
    NSArray *_asks;
    NSArray *_bids;
    NSNumberFormatter *_numberFormatter;
}

@end

@implementation RCHRealtimeAgencyView

- (id)initWithFrame:(CGRect)frame onSelected:(void (^)(NSString *, DepthSide))onSelected {
    self = [super initWithFrame:frame];
    if (self) {
        _currentPrecision = _precision = 8;
        self.backgroundColor = [UIColor clearColor];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 38 + (frame.size.height - 96 - 44) / 2, frame.size.width - 25, 44)];
        _priceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.f];
        [self addSubview:_priceLabel];
        
        UIView *precisionView = [[UIView alloc] initWithFrame:CGRectMake(10, frame.size.height - 46, frame.size.width - 25, 28)];
        precisionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        precisionView.backgroundColor = [UIColor clearColor];
        precisionView.layer.borderColor = kTradeBorderColor.CGColor;
        precisionView.layer.borderWidth = BORDERWIDTH;
        
        _precisionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _precisionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _precisionLabel.backgroundColor = [UIColor clearColor];
        _precisionLabel.textColor = kTextUnselectColor;
        _precisionLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        _precisionLabel.textAlignment = NSTextAlignmentCenter;
        [_precisionLabel sizeToFit];
        _precisionLabel.text = [NSString stringWithFormat:@"%ld 位小数", _currentPrecision];
        [precisionView addSubview:_precisionLabel];
        
        UIImage *image = RCHIMAGEWITHNAMED(@"ico_arrow_country");
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{precisionView.width - 45 - image.size.width, (precisionView.height - image.size.height) / 2}, image.size}];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        imageView.image = image;
        [precisionView addSubview:imageView];
        
        _precisionLabel.frame = CGRectMake(precisionView.width / 3 / 2 - (10 + image.size.width) / 2, 0, precisionView.width * 2 / 3, precisionView.height);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(precisionClicked:)];
        tapGesture.delegate = self;
        [precisionView addGestureRecognizer:tapGesture];
        [self addSubview:precisionView];
        
        CGFloat itemHeight = round((frame.size.height - 96 - 44) / 2 / SHOWDEPTHCOUNT);
        CGFloat padding = (itemHeight * SHOWDEPTHCOUNT - (frame.size.height - 96 - 44) / 2) / 2;
        
        UIView *asksView = [[UIView alloc] initWithFrame:CGRectMake(10,
                                                                    38 - padding,
                                                                    frame.size.width - 25,
                                                                    itemHeight * SHOWDEPTHCOUNT)];
        asksView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        asksView.backgroundColor = [UIColor clearColor];
        [self addSubview:asksView];
        
        UIView *bidsView = [[UIView alloc] initWithFrame:CGRectMake(10,
                                                                    38 + (frame.size.height - 96 - 44) / 2 + 44 - padding,
                                                                    frame.size.width - 25,
                                                                    itemHeight * SHOWDEPTHCOUNT)];
        bidsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        bidsView.backgroundColor = [UIColor clearColor];
        [self addSubview:bidsView];
        
        NSMutableArray *askItems = [NSMutableArray arrayWithCapacity:SHOWDEPTHCOUNT];
        NSMutableArray *bidItems = [NSMutableArray arrayWithCapacity:SHOWDEPTHCOUNT];
        
        for (NSUInteger i = 0; i < SHOWDEPTHCOUNT; i++) {
            DepthItem *askItem = [[DepthItem alloc] initWithFrame:CGRectMake(0, asksView.height - (i + 1) * itemHeight, asksView.width, itemHeight)
                                                             side:DepthSideAsk
                                                       onSelected:onSelected];
            askItem.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [asksView addSubview:askItem];
            [askItems addObject:askItem];
            
            DepthItem *bidItem = [[DepthItem alloc] initWithFrame:CGRectMake(0, i * itemHeight, bidsView.width, itemHeight)
                                                             side:DepthSideBid
                                                       onSelected:onSelected];
            bidItem.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [bidsView addSubview:bidItem];
            [bidItems addObject:bidItem];
        }
        _askItems = (NSArray *)askItems;
        _bidItems = (NSArray *)bidItems;
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_numberFormatter setPositiveFormat:@"####.##"];
        [_numberFormatter setMaximumFractionDigits:8];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSMutableParagraphStyle *priceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    priceParagraphStyle.alignment = NSTextAlignmentLeft;
    
    NSMutableParagraphStyle *amountParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    amountParagraphStyle.alignment = NSTextAlignmentRight;
    
    [[NSString stringWithFormat:@"价格(%@)", self.market ? self.market.currency.code : @"--"] drawInRect:CGRectMake(10,
                                                                                            15,
                                                                                            (rect.size.width - 25) / 2,
                                                                                            18)
                                                                  withAttributes:@{
                                                                                   NSForegroundColorAttributeName: kTextUnselectColor,
                                                                                   NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12.f],
                                                                                   NSParagraphStyleAttributeName: priceParagraphStyle
                                                                                   }];
    [[NSString stringWithFormat:@"数量(%@)", self.market ? self.market.coin.code : @"--"] drawInRect:CGRectMake(10 + (rect.size.width - 25) / 2,
                                                                                        15,
                                                                                        (rect.size.width - 25) / 2,
                                                                                        18)
                                                              withAttributes:@{
                                                                               NSForegroundColorAttributeName: kTextUnselectColor,
                                                                               NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12.f],
                                                                               NSParagraphStyleAttributeName: amountParagraphStyle
                                                                               }];
}

- (void)setMarket:(RCHMarket *)market {
    _market = market;
    [self refreshPrice];
    _currentPrecision = _precision = [self getPrecision];
    _precisionLabel.text = [NSString stringWithFormat:@"%ld 位小数", _currentPrecision];
    [self setNeedsDisplay];
    [self setAsks:@[] bids:@[]];
}

- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids {
    _asks = [self filterData:asks];
    _bids = [self filterData:bids];
    
    [self displayAsksAndBids:_currentPrecision];
}

- (void)displayAsksAndBids:(NSUInteger)precision {
    NSArray *asks = [self calculateData:_asks precision:precision];
    NSArray *bids = [self calculateData:_bids precision:precision];
    
    asks = [asks count] > 0 ? [asks subarrayWithRange:NSMakeRange(0, ([asks count] > SHOWDEPTHCOUNT ? SHOWDEPTHCOUNT : [asks count]))] : asks;
    bids = [bids count] > 0 ? [bids subarrayWithRange:NSMakeRange(0, ([bids count] > SHOWDEPTHCOUNT ? SHOWDEPTHCOUNT : [bids count]))] : bids;
    
    double maxVolume = 0;
    for (NSArray *ask in asks) {
        maxVolume = MAX(maxVolume, [ask[2] doubleValue]);
    }
    for (NSArray *bid in bids) {
        maxVolume = MAX(maxVolume, [bid[2] doubleValue]);
    }
    
    for (NSUInteger i = 0; i < [_askItems count]; i++) {
        if (i < [asks count]) {
            [(DepthItem *)(_askItems[i]) setPrice:[self formatPrice:asks[i][0]] amount:[self formatAmount:asks[i][1]] depth:(maxVolume > 0 ? [asks[i][2] doubleValue] / maxVolume : 0)];
        } else {
            [(DepthItem *)(_askItems[i]) setPrice:nil amount:nil depth:0];
        }
    }
    for (NSUInteger i = 0; i < [_bidItems count]; i++) {
        if (i < [bids count]) {
            [(DepthItem *)(_bidItems[i]) setPrice:[self formatPrice:bids[i][0]] amount:[self formatAmount:bids[i][1]] depth:(maxVolume > 0 ? [bids[i][2] doubleValue] / maxVolume : 0)];
        } else {
            [(DepthItem *)(_bidItems[i]) setPrice:nil amount:nil depth:0];
        }
    }
}

- (NSArray *)calculateData:(NSArray *)data precision:(NSUInteger)precision {
    NSMutableArray *result = [NSMutableArray array];
    
    NSNumberFormatter *formatter = [RCHHelper getNumberFormatterFractionDigits:precision fractionDigitsPadded:YES];
    [formatter setRoundingMode:NSNumberFormatterRoundFloor];
    
    NSNumber *price = nil;
    NSDecimalNumber *amount = [NSDecimalNumber zero];
    NSDecimalNumber *volume = [NSDecimalNumber zero];
    for (NSArray *d in data) {
        NSNumber *thePrice = [NSNumber numberWithString:[formatter stringFromNumber:d[0]]];
        if (price == nil || [price compare:thePrice] == NSOrderedSame) {
            price = thePrice;
            amount = [amount decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[d[1] decimalValue]]];
            volume = [volume decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[d[2] decimalValue]]];
        } else {
            [result addObject:@[price, amount, volume]];
            price = thePrice;
            amount = [NSDecimalNumber decimalNumberWithDecimal:[d[1] decimalValue]];
            volume = [NSDecimalNumber decimalNumberWithDecimal:[d[2] decimalValue]];
        }
    }
    if ([amount compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
        [result addObject:@[price, amount, volume]];
    }
    return (NSArray *)result;
}

- (NSString *)formatPrice:(NSNumber *)price {
    [_numberFormatter setMaximumFractionDigits:8];
    [_numberFormatter setMinimumFractionDigits:_currentPrecision];
    return [_numberFormatter stringFromNumber:price];
}

- (NSString *)formatAmount:(NSNumber *)amount {
    [_numberFormatter setMinimumFractionDigits:0];
    double theAmount = [amount doubleValue];
    NSString *unit = @"";
    if (theAmount < 10) {
        [_numberFormatter setMaximumFractionDigits:3];
    } else if (theAmount < 100) {
        [_numberFormatter setMaximumFractionDigits:2];
    } else if (theAmount < 1000) {
        [_numberFormatter setMaximumFractionDigits:1];
    } else if (theAmount < 1000000) {
        theAmount = theAmount / 1000;
        if (theAmount < 100) {
            [_numberFormatter setMaximumFractionDigits:2];
        } else {
            [_numberFormatter setMaximumFractionDigits:1];
        }
        unit = @"k";
    } else if (theAmount < 1000000000) {
        theAmount = theAmount / 1000000;
        if (theAmount < 100) {
            [_numberFormatter setMaximumFractionDigits:2];
        } else {
            [_numberFormatter setMaximumFractionDigits:1];
        }
        unit = @"m";
    } else {
        theAmount = theAmount / 1000000000;
        [_numberFormatter setMaximumFractionDigits:0];
        unit = @"bn";
    }
    return [NSString stringWithFormat:@"%@%@", [_numberFormatter stringFromNumber:[NSNumber numberWithDouble:theAmount]], unit];
}

- (NSArray *)filterData:(NSArray *)data {
    NSMutableArray *theData = [NSMutableArray array];
    for (NSUInteger i = 0; i < [data count]; i++) {
        if (![data[i] isKindOfClass:[NSArray class]]) continue;
        if ([data[i] count] != 3) continue;
        if (![data[i][0] isKindOfClass:[NSNumber class]] || ![data[i][1] isKindOfClass:[NSNumber class]] || ![data[i][2] isKindOfClass:[NSNumber class]]) continue;
        [theData addObject:data[i]];
    }
    return (NSArray *)theData;
}

- (void)refreshPrice {
    if (!_market || !_market.state) {
        _priceLabel.textColor = kTradeSameColor;
        _priceLabel.text = @"--";
    } else {
        if (_market.state.amplitude == NSOrderedAscending) {
            _priceLabel.textColor = kTradeNegativeColor;
        } else if (_market.state.amplitude == NSOrderedDescending) {
            _priceLabel.textColor = kTradePositiveColor;
        } else {
            _priceLabel.textColor = kTradeSameColor;
        }
        _priceLabel.text = [NSString stringWithFormat:@"%@  ￥%.2f", [[RCHHelper getNumberFormatterFractionDigits:_market.priceScale fractionDigitsPadded:YES] stringFromNumber:_market.state.last_price], [_market.state.cny_price doubleValue]];
    }
}

- (NSUInteger)getPrecision {
    if (_market) {
        NSUInteger precision = floor(log10([[[NSDecimalNumber decimalNumberWithString:@"1"] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithDecimal:[_market.price_step decimalValue]]] integerValue]));
        return precision > 8 ? 8 : precision;
    } else {
        return 8;
    }
}

- (void)precisionClicked:(UIGestureRecognizer *)recognizer {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)recognizer;
    [YBPopupMenu showRelyOnView:tap.view
                         titles:[self precisionTitles]
                          icons:nil
                      menuWidth:tap.view.width
                  otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.priorityDirection = YBPopupMenuPriorityDirectionBottom;
        popupMenu.tag = 2;
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

- (NSArray *)precisionTitles
{
    NSMutableArray *titles = [NSMutableArray array];
    for (NSUInteger i = _precision; i > (_precision > 4 ? _precision - 4 : 0); i--) {
        [titles addObject:[NSString stringWithFormat:@"%ld位小数", i]];
    }
    return (NSArray *)titles;
}

#pragma mark - YBPopupMenuDelegate
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index
{
    if (ybPopupMenu.tag == 2) {
        NSInteger precision = _precision - index;
        if (precision < (_precision > 3 ? _precision - 3 : 1)) return;
        _currentPrecision = precision;
        _precisionLabel.text = [NSString stringWithFormat:@"%ld 位小数", _currentPrecision];
        [self displayAsksAndBids:_currentPrecision];
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
    if (ybPopupMenu.tag == 2) {
        cell.textLabel.text = [self precisionTitles][index];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = RGBA(0X19, 0X1E, 0X3D, 1.0f);
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

@end
