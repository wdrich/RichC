//
//  RCHTradeDetailOrderView.m
//  richcore
//
//  Created by WangDong on 2018/7/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTradeDetailOrderView.h"
#import "RCHRealtimeOrderView.h"
#import "YBPopupMenu.h"

@interface RCHTradeDetailOrderView() <YBPopupMenuDelegate>
{
    NSArray *_asks;
    NSArray *_bids;
    NSUInteger _currentPrecision;
    NSUInteger _precision;
}

@property (weak, nonatomic) UIView *titleView;
@property (weak, nonatomic) UIView *precisionView;
@property (strong, nonatomic) UIButton *precisionButton;
@property (strong, nonatomic) RCHRealtimeOrderView *asksView;
@property (strong, nonatomic) RCHRealtimeOrderView *bidsView;

@end

@implementation RCHTradeDetailOrderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _currentPrecision = _precision = 8;
    
    if (self) {
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0.0f);
            make.height.mas_equalTo(40.0f);
        }];
        
        [self.precisionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleView.mas_bottom);
            make.left.right.bottom.mas_equalTo(0.0f);
        }];
    }
    return self;
}

#pragma mark -
#pragma mark - customFuction

- (void)setAsks:(NSArray *)asks bids:(NSArray *)bids {
    _asks = asks;
    [_asksView setItemDatas:_asks];
    _bids = bids;
    [_bidsView setItemDatas:_bids];
}

- (NSUInteger)getPrecision {
    if (_market) {
        NSUInteger precision = floor(log10([[[NSDecimalNumber decimalNumberWithString:@"1"] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithDecimal:[_market.price_step decimalValue]]] integerValue]));
        return precision > 8 ? 8 : precision;
    } else {
        return 8;
    }
}

- (NSArray *)precisionTitles
{
    NSMutableArray *titles = [NSMutableArray array];
    for (NSUInteger i = _precision; i > (_precision > 4 ? _precision - 4 : 0); i--) {
        [titles addObject:[NSString stringWithFormat:@"%ld", i]];
    }
    return (NSArray *)titles;
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)precisionButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [YBPopupMenu showRelyOnView:button
                         titles:[self precisionTitles]
                          icons:nil
                      menuWidth:button.width
                  otherSettings:^(YBPopupMenu *popupMenu) {
                      popupMenu.priorityDirection = YBPopupMenuPriorityDirectionTop;
                      popupMenu.tag = 2;
                      popupMenu.dismissOnSelected = YES;
                      popupMenu.isShowShadow = NO;
                      popupMenu.delegate = self;
                      popupMenu.type = YBPopupMenuTypeDefault;
                      popupMenu.cornerRadius = 4.0f;
                      popupMenu.itemHeight = 30.0f;
                      popupMenu.backColor = kTradeBackLightColor;
                      popupMenu.borderWidth = 1.0f;
                      popupMenu.borderColor = [kNavigationColor_MB colorWithAlphaComponent:0.5];
                      popupMenu.isShowShadow = NO;
                      popupMenu.offset = 2.0f;
                  }];
//    !self.precisionChanged ?: self.precisionChanged(@"1 2 3 4 5 6 7, 那都不是事儿！");
}

#pragma mark -
#pragma mark - YBPopupMenuDelegate
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index
{
    if (ybPopupMenu.tag == 2) {
        NSInteger precision = _precision - index;
        if (precision < (_precision > 3 ? _precision - 3 : 1)) return;
        _currentPrecision = precision;
        [self.precisionButton setTitle:[NSString stringWithFormat:@"%ld", (unsigned long)_currentPrecision] forState:UIControlStateNormal];
        [_asksView setDisplayPrecision:_currentPrecision];
        [_bidsView setDisplayPrecision:_currentPrecision];
    }
}

- (UITableViewCell *)ybPopupMenu:(YBPopupMenu *)ybPopupMenu cellForRowAtIndex:(NSInteger)index
{
    static NSString *MenuCellIdentifer = @"MenuCellIdentifer";
    UITableViewCell * cell = [ybPopupMenu.tableView dequeueReusableCellWithIdentifier:MenuCellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuCellIdentifer];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    if (ybPopupMenu.tag == 2) {
        cell.textLabel.text = [self precisionTitles][index];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = RGBA(0X19, 0X1E, 0X3D, 1.0f);
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:6.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

#pragma mark -
#pragma mark - setter

- (void)setMarket:(RCHMarket *)market {
    _market = market;
    _currentPrecision = _precision = [self getPrecision];
    [self.precisionButton setTitle:[NSString stringWithFormat:@"%ld", (unsigned long)_currentPrecision] forState:UIControlStateNormal];
    [self setNeedsDisplay];
    
    [self.asksView setDisplayPrecision:_currentPrecision];
    [self.bidsView setDisplayPrecision:_currentPrecision];
    [self setAsks:_asks bids:_bids];
}

#pragma mark -
#pragma mark - getter

- (UIView *)titleView
{
    if(!_titleView)
    {
        UIView *view = [[UIView alloc] init];
        [view setBackgroundColor:kTradeBackLightColor];
        [self addSubview:view];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"委托订单";
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14.0f] range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kTradeBorderColor range:NSMakeRange(0, [titleLabel.text length])];
        titleLabel.attributedText = attributedString;
        [view addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(view.mas_centerY);
            make.left.mas_equalTo(15.0f);
            make.right.mas_equalTo(-15.0f);
            make.height.mas_equalTo(18.0f);
        }];
        
        _titleView = view;
    }
    return _titleView;
}

- (UIView *)precisionButton
{
    if(!_precisionButton)
    {
        UIButton *precision = [UIButton buttonWithType:UIButtonTypeCustom];
        precision.layer.cornerRadius = 0.0f;
        precision.layer.borderColor = kNavigationColor_MB.CGColor;
        precision.layer.borderWidth = 1.0f;
        precision.layer.masksToBounds = YES;
        [precision setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)_precision] forState:UIControlStateNormal];
        [precision setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        precision.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.0f];
        [precision setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [precision addTarget:self action:@selector(precisionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [precision setAdjustsImageWhenHighlighted:NO];
        _precisionButton = precision;
        
        _precisionButton.hidden = YES;
    }
    return _precisionButton;
}


- (RCHRealtimeOrderView *)asksView
{
    if(!_asksView){
        _asksView = [[RCHRealtimeOrderView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth / 2.0f, 300.0f}} side:DetailDepthSideAsk];
    }
    return _asksView;
}

- (RCHRealtimeOrderView *)bidsView
{
    if(!_bidsView){
        _bidsView = [[RCHRealtimeOrderView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth / 2.0f, 160.0f}} side:DetailDepthSideBid];
    }
    return _bidsView;
}

- (UIView *)precisionView
{
    if(!_precisionView)
    {
        UIView *view = [[UIView alloc] init];
        [view setBackgroundColor:[UIColor clearColor]];
        [self addSubview:view];
        
        UILabel *buyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        buyLabel.text = @"买";
        [view addSubview:buyLabel];
        
        UILabel *sellLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        sellLabel.text = @"卖";
        [view addSubview:sellLabel];
        
        {

            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buyLabel.text];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setAlignment:NSTextAlignmentLeft];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [buyLabel.text length])];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:13.0f] range:NSMakeRange(0, [buyLabel.text length])];
            [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [buyLabel.text length])];
            buyLabel.attributedText = attributedString;
            
            [buyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(15.0f);
                make.left.mas_equalTo(15.0f);
                make.width.mas_equalTo(50.0f);
                make.height.mas_equalTo(18.0f);
            }];
        }
        
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:sellLabel.text];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setAlignment:NSTextAlignmentLeft];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [sellLabel.text length])];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:13.0f] range:NSMakeRange(0, [sellLabel.text length])];
            [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [sellLabel.text length])];
            sellLabel.attributedText = attributedString;
            
            [sellLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(15.0f);
                make.left.mas_equalTo(view.mas_centerX).offset(0.0f);
                make.width.mas_equalTo(50.0f);
                make.height.mas_equalTo(18.0f);
            }];
        }
        
        [view addSubview:self.precisionButton];
        [self.precisionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15.0f);
            make.right.mas_equalTo(-15.0f);
            make.width.mas_equalTo(34.0f);
            make.height.mas_equalTo(20.0f);
        }];
        
        [view addSubview:self.bidsView];
        [self.bidsView setBackgroundColor:[UIColor clearColor]];
        [self.bidsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(buyLabel.mas_bottom).offset(10.0f);
            make.left.mas_equalTo(15.0f);
            make.right.mas_equalTo(view.mas_centerX).offset(0.0f);
            make.bottom.mas_equalTo(-20.0f);
        }];
        
        [view addSubview:self.asksView];
        [self.asksView setBackgroundColor:[UIColor clearColor]];
        [self.asksView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bidsView.mas_top);
            make.left.mas_equalTo(view.mas_centerX).offset(0.0f);
            make.right.mas_equalTo(-15.0f);
            make.bottom.mas_equalTo(self.bidsView.mas_bottom);
        }];

        _precisionView = view;
    }
    return _precisionView;
}

@end
