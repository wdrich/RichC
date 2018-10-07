//
//  RCHOrderDetailViewController.m
//  richcore
//
//  Created by Apple on 2018/6/10.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHOrderDetailViewController.h"

#define NAMEWIDTH 100.f

@interface OrderDetailView: UIView

@end

@implementation OrderDetailView

- (id)initWithFrame:(CGRect)frame order:(RCHOrder *)order
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, frame.size.width - 30, 20)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@ %@", order.market.coin.code, order.market.currency.code, ([order.aim isEqualToString:@"sell"] ? @"卖" : @"买")]];
        [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:17.f] range:NSMakeRange(0, [title length] - 1)];
        [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:15.f] range:NSMakeRange([title length] - 1, 1)];
        [title addAttribute:NSForegroundColorAttributeName value:RGBA(51, 51, 51, 1) range:NSMakeRange(0, [title length] - 1)];
        [title addAttribute:NSForegroundColorAttributeName value:([order.aim isEqualToString:@"sell"] ? kTradeNegativeColor : kTradePositiveColor) range:NSMakeRange([title length] - 1, 1)];
        titleLabel.attributedText = title;
        [self addSubview:titleLabel];
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, frame.size.width - 30, 20)];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.textColor = RGBA(51, 51, 51, 1);
        statusLabel.text = [NSString stringWithFormat:@"%@%@", order.status, [self filledPercentString:[order filledPercent]]];
        [self addSubview:statusLabel];
        
        NSDictionary *attrs = nil;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentRight];
//        [paragraphStyle setLineSpacing:0.f];
        
        attrs = @{
                  NSParagraphStyleAttributeName: paragraphStyle,
                  NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:15.f],
                  NSForegroundColorAttributeName: RGBA(102, 102, 102, 1)
                  };
        
        [self addSubview:[self cellWithFrame:CGRectMake(15, 124, frame.size.width - 30, 22)
                                        name:@"类型"
                                       value:[[NSMutableAttributedString alloc] initWithString:([order._dtype isEqualToString:@"market"] ? @"市价" : @"限价") attributes:attrs]]];
        
        NSNumberFormatter *formatter = [RCHHelper getNumberFormatterFractionDigits:8];
        
        NSString *filledAmount = [formatter stringFromNumber:[order filledAmount]];
        NSMutableAttributedString *amount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", filledAmount, [order._dtype isEqualToString:@"market"] && [order.aim isEqualToString:@"buy"] ? @"-" : [formatter stringFromNumber:order.amount]]];
        
        [amount addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [amount length])];
        [amount addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:16.f] range:NSMakeRange(0, [filledAmount length])];
        [amount addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14.f] range:NSMakeRange([filledAmount length], [amount length] - [filledAmount length])];
        [amount addAttribute:NSForegroundColorAttributeName value:RGBA(87, 100, 212, 1) range:NSMakeRange(0, [filledAmount length])];
        [amount addAttribute:NSForegroundColorAttributeName value:RGBA(102, 102, 102, 1) range:NSMakeRange([filledAmount length], [amount length] - [filledAmount length])];
        
        [self addSubview:[self cellWithFrame:CGRectMake(15, 156, frame.size.width - 30, 22)
                                        name:@"成交量/委托量"
                                       value:amount]];
        
        NSString *averagePrice = [formatter stringFromNumber:[order averagePrice]];
        NSMutableAttributedString *price = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", averagePrice, [order._dtype isEqualToString:@"market"] ? @"-" : [formatter stringFromNumber:order.price]]];
        
        [price addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [price length])];
        [price addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Semibold" size:16.f] range:NSMakeRange(0, [averagePrice length])];
        [price addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14.f] range:NSMakeRange([averagePrice length], [price length] - [averagePrice length])];
        [price addAttribute:NSForegroundColorAttributeName value:RGBA(87, 100, 212, 1) range:NSMakeRange(0, [averagePrice length])];
        [price addAttribute:NSForegroundColorAttributeName value:RGBA(102, 102, 102, 1) range:NSMakeRange([averagePrice length], [price length] - [averagePrice length])];
        
        [self addSubview:[self cellWithFrame:CGRectMake(15, 188, frame.size.width - 30, 22)
                                        name:@"成交均价/价格"
                                       value:price]];
        
        attrs = @{
                  NSParagraphStyleAttributeName: paragraphStyle,
                  NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:16.f],
                  NSForegroundColorAttributeName: RGBA(87, 100, 212, 1)
                  };
        
        [self addSubview:[self cellWithFrame:CGRectMake(15, 250, frame.size.width - 30, 22)
                                        name:@"手续费"
                                       value:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:[order fee]], ([order.aim isEqualToString:@"sell"] ? order.market.currency.code : order.market.coin.code)] attributes:attrs]]];
        
        [self addSubview:[self cellWithFrame:CGRectMake(15, 283, frame.size.width - 30, 22)
                                        name:@"成交额"
                                       value:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:[order filledVolume]], order.market.currency.code] attributes:attrs]]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetLineWidth(context, .5f);
    [RGBA(225.f, 225.f, 225.f, 1.f) setStroke];
    CGContextMoveToPoint(context, 15, 230);
    CGContextAddLineToPoint(context, rect.size.width - 15, 230);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (UIView *)cellWithFrame:(CGRect)frame name:(NSString *)name value:(NSAttributedString *)value
{
    UIView *cell = [[UIView alloc] initWithFrame:frame];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, NAMEWIDTH, 21)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
    nameLabel.textColor = RGBA(51, 51, 51, 1);
    nameLabel.text = name;
    [cell addSubview:nameLabel];
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(NAMEWIDTH, 0, frame.size.width - NAMEWIDTH, frame.size.height)];
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    valueLabel.numberOfLines = 0;
    valueLabel.attributedText = value;
    [cell addSubview:valueLabel];
    
    return cell;
}

- (NSString *)filledPercentString:(NSDecimalNumber *)percent {
    if (percent == nil) return @"";
    NSNumberFormatter *formatter = [RCHHelper getNumberFormatterFractionDigits:2];
    return [NSString stringWithFormat:@"(%@%%)", [formatter stringFromNumber:[percent decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]]]];
}

@end

@interface TransactionsHeader: UIView
@end

@implementation TransactionsHeader

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, frame.size.width - 30, 20)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
        titleLabel.textColor = RGBA(51, 51, 51, 1);
        titleLabel.text = @"成交详情";
        [self addSubview:titleLabel];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 53, (frame.size.width - 30) * 2 / 5, 46)];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.f];
        dateLabel.textColor = RGBA(153, 153, 153, 1);
        dateLabel.text = @"日期";
        [self addSubview:dateLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + (frame.size.width - 30) * 2 / 5, 53, (frame.size.width - 30) * 3 / 10, 46)];
        priceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.f];
        priceLabel.textColor = RGBA(153, 153, 153, 1);
        priceLabel.text = @"成交价";
        [self addSubview:priceLabel];
        
        UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + (frame.size.width - 30) * 7 / 10, 53, (frame.size.width - 30) * 3 / 10, 46)];
        amountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        amountLabel.backgroundColor = [UIColor clearColor];
        amountLabel.textAlignment = NSTextAlignmentRight;
        amountLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.f];
        amountLabel.textColor = RGBA(153, 153, 153, 1);
        amountLabel.text = @"成交量";
        [self addSubview:amountLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetLineWidth(context, .5f);
    [RGBA(225.f, 225.f, 225.f, 1.f) setStroke];
    CGContextMoveToPoint(context, 15, 50);
    CGContextAddLineToPoint(context, rect.size.width - 15, 50);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

@interface TransactionCell: UITableViewCell
{
    UILabel *_dateLabel;
    UILabel *_priceLabel;
    UILabel *_amountLabel;
}
@end

@implementation TransactionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.f];
        _dateLabel.textColor = RGBA(51, 51, 51, 1);
        [self.contentView addSubview:_dateLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.f];
        _priceLabel.textColor = RGBA(51, 51, 51, 1);
        [self.contentView addSubview:_priceLabel];
        
        _amountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _amountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        _amountLabel.backgroundColor = [UIColor clearColor];
        _amountLabel.textAlignment = NSTextAlignmentRight;
        _amountLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.f];
        _amountLabel.textColor = RGBA(51, 51, 51, 1);
        [self.contentView addSubview:_amountLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    _dateLabel.frame = CGRectMake(15, 0, (frame.size.width - 30) * 2 / 5, 35);
    _priceLabel.frame = CGRectMake(15 + (frame.size.width - 30) * 2 / 5, 0, (frame.size.width - 30) * 3 / 10, 35);
    _amountLabel.frame = CGRectMake(15 + (frame.size.width - 30) * 7 / 10, 0, (frame.size.width - 30) * 3 / 10, 35);
}

- (void)reloadWithDate:(NSString *)date price:(NSString *)price amount:(NSString *)amount {
    _dateLabel.text = date;
    _priceLabel.text = price;
    _amountLabel.text = amount;
}

@end

@interface RCHOrderDetailViewController ()
{
    RCHOrder *_order;
}
@end

@implementation RCHOrderDetailViewController

- (id)initWithOrder:(RCHOrder *)order {
    self = [super init];
    if (self) {
        _order = order;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    self.title = @"订单详情";
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 345)];
    header.backgroundColor = [UIColor clearColor];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    OrderDetailView *aHeader = [[OrderDetailView alloc] initWithFrame:CGRectMake(0, 0, header.width, 335) order:_order];
    aHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [header addSubview:aHeader];
    self.tableView.tableHeaderView = header;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Implements UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 99.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[TransactionsHeader alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 99.f)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 23.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 23.f)];
    footer.backgroundColor = [UIColor whiteColor];
    return footer;
}


#pragma mark -
#pragma mark Implements UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_order.transactions isKindOfClass:[NSArray class]] && [_order.transactions count] > 0) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_order.transactions count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCHTransaction *transaction = [_order.transactions objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"transactionCellIdentifier";
    TransactionCell *cell = (TransactionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSNumberFormatter *formatter = [RCHHelper getNumberFormatterFractionDigits:8];
    
    [cell reloadWithDate:[RCHHelper getStempString:transaction.created_at] price:[formatter stringFromNumber:transaction.price] amount:[formatter stringFromNumber:transaction.amount]];
    
    return cell;
    
}


@end
