//
//  ZXMessageBoxView.m
//  GJB
//
//  Created by 郑旭 on 2017/9/7.
//  Copyright © 2017年 汇金集团SR. All rights reserved.
//

#import "ZXMessageBoxView.h"
#import "ZXHeader.h"
@interface ZXMessageBoxView()
@property (nonatomic,copy) NSString *open;
@property (nonatomic,copy) NSString *close;
@property (nonatomic,copy) NSString *high;
@property (nonatomic,copy) NSString *low;
@property (nonatomic,copy) NSString *volume;
@property (nonatomic,assign) ArrowPosition arrowPosition;
@property (nonatomic,strong) CAShapeLayer *borderLayer;
@end

@implementation ZXMessageBoxView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
        self.open = @"0";
        self.close = @"0";
        self.high = @"0";
        self.low = @"0";
        self.volume = @"0";
    }
    return self;
}
- (void)setUI
{
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.backgroundColor = [kTradeBackLightColor colorWithAlphaComponent:0.9];
    self.layer.borderColor = kTradeBorderColor.CGColor;
    self.layer.borderWidth = 0.5f;
    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    [self updateMessageWithOpen:self.open close:self.close high:self.high low:self.low volume:self.volume];
//    [self drawBorder];
}

- (void)updateMessageWithOpen:(NSString *)open close:(NSString *)close high:(NSString *)high low:(NSString *)low volume:(NSString *)volume

{
    NSArray *titles = @[@"开:", @"收:", @"高:", @"低:", @"成交量:"];
    NSArray *values = @[open, close, high, low, volume];
    
    CGFloat originX = 5.0f;
    CGFloat originY = 5.0f;
    CGFloat width = self.frame.size.width - originX * 2;
    CGFloat height = 12.0f;
    CGFloat padding = (self.frame.size.height - height * titles.count - originY * 2) / (titles.count - 1);
//    if (KSCREEN_WIDTH==320) {
//
//        padding = 5;
//    }else{
//
//        padding = 10;
//    }
    
    NSInteger i = 0;
    for (NSString *title in titles) {
        
        NSMutableParagraphStyle *titleStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        titleStyle.lineBreakMode = NSLineBreakByClipping;
        titleStyle.alignment = NSTextAlignmentLeft;
        NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FontSize],NSParagraphStyleAttributeName:titleStyle, NSForegroundColorAttributeName:lightGrayTextColor}];
        if (KSCREEN_WIDTH==320) {
            
            [titleString drawInRect:CGRectMake(originX, originY + i*(height+padding), width, height)];
        }else{
            
            [titleString drawInRect:CGRectMake(originX, originY + i*(height+padding), width, height)];
        }
        
        NSMutableParagraphStyle *valueStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        valueStyle.lineBreakMode = NSLineBreakByClipping;
        valueStyle.alignment = NSTextAlignmentRight;
        NSAttributedString *valueString = [[NSAttributedString alloc] initWithString:values[i] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FontSize],NSParagraphStyleAttributeName:valueStyle, NSForegroundColorAttributeName:lightGrayTextColor}];
        if (KSCREEN_WIDTH==320) {
            
            [valueString drawInRect:CGRectMake(originX, originY + i*(height+padding), width, height)];
        }else{
            
            [valueString drawInRect:CGRectMake(originX, originY + i*(height+padding), width, height)];
        }
        
        i ++;
    }
}
- (void)drawBorder
{
    [self.borderLayer removeFromSuperlayer];
    self.borderLayer = nil;
    switch (self.arrowPosition) {
        case ArrowPositionLeftTop:
            [self drawBorderWithArrowLeftTop];
            break;
        case ArrowPositionRightTop:
            [self drawBorderWithArrowRightTop];
            break;
        case ArrowPositionLeftBottom:
            [self drawBorderWithArrowLeftBottom];
            break;
        case ArrowPositionRightBottom:
            [self drawBorderWithArrowRightBottom];
            break;
        case ArrowPositionLeftCenter:
            [self drawBorderWithArrowLeftCenter];
            break;
        case ArrowPositionRightCenter:
            [self drawBorderWithArrowRightCenter];
            break;
        case ArrowPositionNoArrow:
//            [self drawBorderWithArrowRightCenter];
            break;
    }
}

- (void)setNeedsDisplayWithOpen:(NSString *)open close:(NSString *)close high:(NSString *)high low:(NSString *)low arrowPosition:(ArrowPosition)arrowPosition
{
    
    self.arrowPosition = arrowPosition;
    self.open = open;
    self.close = close;
    self.high = high;
    self.low = low;
    [self setNeedsDisplay];
}

- (void)setNeedsDisplayWithOpen:(NSString *)open close:(NSString *)close high:(NSString *)high low:(NSString *)low volume:(NSString *)volume
{
    self.open = open;
    self.close = close;
    self.high = high;
    self.low = low;
    self.volume = volume;
    self.arrowPosition = ArrowPositionNoArrow;
    [self setNeedsDisplay];
}

- (void)drawBorderWithArrowRightCenter
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-arrowLong-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    
    
    
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,(height-arrowLong)/2.0)];
    [beizerPath addLineToPoint:CGPointMake(width,(height)/2.0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,(height-arrowLong)/2.0+arrowLong)];
    
    
    
    //
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,height)];
    [beizerPath addArcWithCenter:CGPointMake(width-arrowLong-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    
    //
    [beizerPath addLineToPoint:CGPointMake(radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [beizerPath addLineToPoint:CGPointMake(0,radius)];
    [beizerPath addArcWithCenter:CGPointMake(radius,radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    self.borderLayer.lineWidth = MessageBoxBorderWidth;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = MessageBoxBorderColor.CGColor;
    [self.layer addSublayer:self.borderLayer];
}

- (void)drawBorderWithArrowLeftCenter
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(arrowLong+radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    //
    [beizerPath addLineToPoint:CGPointMake(width,height-radius)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong+radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(arrowLong+radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong, (height-arrowLong)/2.0+arrowLong)];
    [beizerPath addLineToPoint:CGPointMake(0, (height/2.0))];
    [beizerPath addLineToPoint:CGPointMake(arrowLong, (height-arrowLong)/2.0)];
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong,radius)];
    [beizerPath addArcWithCenter:CGPointMake(arrowLong+radius,radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    self.borderLayer.lineWidth = MessageBoxBorderWidth;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = MessageBoxBorderColor.CGColor;
    [self.layer addSublayer:self.borderLayer];
}


- (void)drawBorderWithArrowLeftTop
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(arrowLong, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(width,height-radius)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong+radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(arrowLong+radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong, arrowLong)];
    [beizerPath addLineToPoint:CGPointMake(0, arrowLong/2.0)];
    [beizerPath addLineToPoint:CGPointMake(arrowLong, 0)];

    self.borderLayer.lineWidth = MessageBoxBorderWidth;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = MessageBoxBorderColor.CGColor;
    [self.layer addSublayer:self.borderLayer];
}

- (void)drawBorderWithArrowLeftBottom
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(arrowLong+radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(width,height-radius)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong,height)];
    [beizerPath addLineToPoint:CGPointMake(0, (height-arrowLong/2.0))];
    [beizerPath addLineToPoint:CGPointMake(arrowLong, (height-arrowLong))];
    
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong, radius)];
    [beizerPath addArcWithCenter:CGPointMake(arrowLong+radius, radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    
    
    self.borderLayer.lineWidth = MessageBoxBorderWidth;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = MessageBoxBorderColor.CGColor;
    [self.layer addSublayer:self.borderLayer];
}

- (void)drawBorderWithArrowRightBottom
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-arrowLong-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    //
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,height-arrowLong)];
    [beizerPath addLineToPoint:CGPointMake(width,height-arrowLong/2.0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,height)];
    
    
    //
    [beizerPath addLineToPoint:CGPointMake(radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [beizerPath addLineToPoint:CGPointMake(0,radius)];
    [beizerPath addArcWithCenter:CGPointMake(radius,radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    self.borderLayer.lineWidth = MessageBoxBorderWidth;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = MessageBoxBorderColor.CGColor;
    [self.layer addSublayer:self.borderLayer];
}
- (void)drawBorderWithArrowRightTop
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong, 0)];
    [beizerPath addLineToPoint:CGPointMake(width, arrowLong/2)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong, arrowLong)];

    
    //
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,height-radius)];
    [beizerPath addArcWithCenter:CGPointMake(width-arrowLong-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    //
    
    [beizerPath addLineToPoint:CGPointMake(radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(0,radius)];
    [beizerPath addArcWithCenter:CGPointMake(radius,radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    self.borderLayer.lineWidth = MessageBoxBorderWidth;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = MessageBoxBorderColor.CGColor;
    [self.layer addSublayer:self.borderLayer];
}




@end
