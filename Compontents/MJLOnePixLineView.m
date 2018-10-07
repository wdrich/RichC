//
//  MJLOnePixLineView.m
//  MJLMerchantsChatServerPush
//
//  Created by WangDong on 14-8-20.
//  Copyright (c) 2014年 WangDong. All rights reserved.
//

#import "MJLOnePixLineView.h"

@interface MJLOnePixLineView ()
{
    CGFloat _lineWidth;
}
@end

@implementation MJLOnePixLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _lineType = MJLOnePixLineViewdraw;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    switch (_lineType) {
        case MJLOnePixLineViewdraw:
        {
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextBeginPath(context);
            
            CGContextSetLineWidth(context, rect.size.width);
            [kFontLineGrayColor setStroke];
            
            CGContextMoveToPoint(context, rect.origin.x, rect.origin.x
                                 );
            CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
            
            CGContextStrokePath(context);
            CGContextClosePath(context);
        }
            break;
        default:
            [RCHIMAGEWITHNAMED(_lineImageName) drawInRect:rect];
            break;
    }

}

- (void)setLineImageName:(NSString *)lineImageName
{
    _lineImageName = lineImageName;
    [self setNeedsDisplay];
}

@end
