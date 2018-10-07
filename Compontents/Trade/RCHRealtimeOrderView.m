//
//  TradeDetailAskView.m
//  richcore
//
//  Created by WangDong on 2018/7/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRealtimeOrderView.h"

#define SHOWDEPTHCOUNT 15
#define DEPTHFONTSIZE 13.f
#define DEPTHTEXTHEIGHT 20.f
#define DEPTHASKBGCOLOR RGBA(180.f, 57.f, 63.f, 0.3f)
#define DEPTHBIDBGCOLOR RGBA(62.f, 116.f, 63.f, 0.3f)

@implementation DetailDepthItem

- (id)initWithFrame:(CGRect)frame side:(DetailDepthSide)side onSelected:(void (^)(NSString *, DetailDepthSide))onSelected
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
        [UIView drawRoundRectangleInRect:CGRectMake((_side == DetailDepthSideAsk ? 0.0f : rect.size.width - width), 0.0f, width, rect.size.height) withRadius:0.0f color:(_side == DetailDepthSideAsk ? DEPTHASKBGCOLOR : DEPTHBIDBGCOLOR)];
        
    }
    NSMutableParagraphStyle *priceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    priceParagraphStyle.alignment = (_side == DetailDepthSideAsk ? NSTextAlignmentLeft : NSTextAlignmentRight);
    
    NSMutableParagraphStyle *amountParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    amountParagraphStyle.alignment = (_side == DetailDepthSideAsk ? NSTextAlignmentRight : NSTextAlignmentLeft);
    
    CGFloat offset = 2.5f;
    CGRect priceFrame = (_side == DetailDepthSideAsk ? CGRectMake(0, (rect.size.height - DEPTHTEXTHEIGHT) / 2 + offset, rect.size.width * 2 / 3, rect.size.height) : CGRectMake(rect.size.width * 1 / 3, (rect.size.height - DEPTHTEXTHEIGHT) / 2 + offset, rect.size.width / 3 * 2, rect.size.height));
    
    CGRect amountFrame = (_side == DetailDepthSideAsk ? CGRectMake(rect.size.width * 2 / 3, (rect.size.height - DEPTHTEXTHEIGHT) / 2 + offset, rect.size.width / 3, rect.size.height) : CGRectMake(0, (rect.size.height - DEPTHTEXTHEIGHT) / 2 + offset, rect.size.width * 2 / 3, rect.size.height));
    
     [(_price ?: @"--") drawInRect:priceFrame
                    withAttributes:@{
                                     NSForegroundColorAttributeName: (_side == DetailDepthSideAsk ? kTradeNegativeColor : kTradePositiveColor),
                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:DEPTHFONTSIZE],
                                     NSParagraphStyleAttributeName: priceParagraphStyle
                                     }];
     [(_amount ?: @"--") drawInRect:amountFrame
                     withAttributes:@{
                                      NSForegroundColorAttributeName: kTradeBorderColor,
                                      NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:DEPTHFONTSIZE],
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


@interface RCHRealtimeOrderView()
{
    DetailDepthSide _side;
    NSArray *_items;
    NSArray *_itemDatas;
    NSUInteger _currentPrecision;
    NSNumberFormatter *_numberFormatter;
    
}

@end

@implementation RCHRealtimeOrderView


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = newSuperview.backgroundColor;
}

- (id)initWithFrame:(CGRect)frame side:(DetailDepthSide)side
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _side = side;
        _currentPrecision = 8;
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_numberFormatter setPositiveFormat:@"####.##"];
        [_numberFormatter setMaximumFractionDigits:8];
        
        [self createItems];
    }
    return self;
}

#pragma mark -
#pragma mark - CustomFuction

- (void)createItems {
    
    [self removeAllSubviews];
    CGFloat itemHeight = 20.0f;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:SHOWDEPTHCOUNT];

    for (NSUInteger i = 0; i < SHOWDEPTHCOUNT; i++) {
        DetailDepthItem *item = [[DetailDepthItem alloc] initWithFrame:CGRectMake(0, i * itemHeight, self.width - 15.0f - 4.0f, itemHeight)
                                                         side:_side
                                                   onSelected:nil];
        [self addSubview:item];

        [items addObject:item];
    }
    _items = (NSArray *)items;
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

- (void)setItemDatas:(NSArray *)datas {
    _itemDatas = [self filterData:datas];
    [self displayItems:_currentPrecision];
}

- (void)setDisplayPrecision:(NSUInteger)precision
{
    _currentPrecision = precision;
    [self displayItems:_currentPrecision];
}

- (void)displayItems:(NSUInteger)precision {
    NSArray *datas = [self calculateData:_itemDatas precision:precision];
    datas = [datas count] > 0 ? [datas subarrayWithRange:NSMakeRange(0, ([datas count] > SHOWDEPTHCOUNT ? SHOWDEPTHCOUNT : [datas count]))] : datas;
    
    double maxVolume = 0;
    for (NSArray *data in datas) {
        maxVolume = MAX(maxVolume, [data[2] doubleValue]);
    }
    
    for (NSUInteger i = 0; i < [_items count]; i++) {
        if (i < [datas count]) {
            [(DetailDepthItem *)(_items[i]) setPrice:[self formatPrice:datas[i][0]] amount:[self formatAmount:datas[i][1]] depth:(maxVolume > 0 ? [datas[i][2] doubleValue] / maxVolume : 0)];
        } else {
            [(DetailDepthItem *)(_items[i]) setPrice:nil amount:nil depth:0];
        }
    }
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

@end
