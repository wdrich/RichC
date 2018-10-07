//
//  RCHOrderFilterView.m
//  richcore
//
//  Created by WangDong on 2018/7/23.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHOrderFilterView.h"
#import "MJLOnePixLineView.h"

@interface RCHOrderFilterView() <UITextFieldDelegate>
{
    NSString *_filterCoin;
    NSString *_filterCurrency;
    NSString *_filterStatus;
}

@property (weak, nonatomic) UILabel *tradeLabel;
@property (weak, nonatomic) UILabel *orderLabel;
@property (weak, nonatomic) UITextField *coinTextField;
@property (weak, nonatomic) UILabel *divLabel;
@property (weak, nonatomic) UIView *marketView;
@property (weak, nonatomic) UIButton *selectButton;
@property (weak, nonatomic) UIButton *allOrderButton;
@property (weak, nonatomic) UIButton *resolvedOrderButton;
@property (weak, nonatomic) UIButton *revokedOrderButton;
@property (weak, nonatomic) UIButton *resetButton;
@property (weak, nonatomic) UIButton *commitButton;

@end

@implementation RCHOrderFilterView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = newSuperview.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self.tradeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20.0f);
            make.left.mas_equalTo(15.0f);
            make.height.mas_equalTo(20.0f);
        }];
        
        [self.orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(119.0f);
            make.left.mas_equalTo(15.0f);
            make.height.mas_equalTo(20.0f);
        }];
        
        [self.marketView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tradeLabel.mas_bottom).offset(15.0f);
            make.left.mas_equalTo(15.0f);
            make.right.mas_equalTo(self.mas_centerX).offset(-10.0f);
            make.height.mas_equalTo(44.0f);
        }];
        
        [self.divLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.marketView.mas_centerY);
            make.height.mas_equalTo(20.0f);
            make.width.mas_equalTo(7.0f);
        }];
        
        [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.marketView.mas_top);
            make.left.mas_equalTo(self.mas_centerX).offset(10.0f);
            make.right.mas_equalTo(self.mas_right).offset(-15.0f);
            make.height.mas_equalTo(self.marketView.mas_height);
        }];
        
        [self.allOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.orderLabel.mas_bottom).offset(15.0f);
            make.left.mas_equalTo(15.0f);
            make.width.mas_equalTo(85.0f);
            make.height.mas_equalTo(30.0f);
        }];
        
        [self.resolvedOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.allOrderButton.mas_top);
            make.left.mas_equalTo(self.allOrderButton.mas_right).offset(15.0f);
            make.width.mas_equalTo(self.allOrderButton.mas_width);
            make.height.mas_equalTo(self.allOrderButton.mas_height);
        }];
        
        [self.revokedOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.resolvedOrderButton.mas_top);
            make.left.mas_equalTo(self.resolvedOrderButton.mas_right).offset(15.0f);
            make.width.mas_equalTo(self.allOrderButton.mas_width);
            make.height.mas_equalTo(self.allOrderButton.mas_height);
        }];
        
        [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0.0f);
            make.right.mas_equalTo(self.mas_centerX);
            make.height.mas_equalTo(50.0f);
            make.top.mas_equalTo(234.0f);
        }];
        
        
        [self.commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.resetButton.mas_right);
            make.right.mas_equalTo(self.mas_right);
            make.height.mas_equalTo(self.resetButton.mas_height);
            make.bottom.mas_equalTo(self.resetButton.mas_bottom);
        }];
    }
    
    [self layoutIfNeeded];
    return self;
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)changeStatusButtonClick:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    UIButton *buuton = (UIButton *)sender;
    [self changeStatus:buuton.tag];
    switch (buuton.tag) {
        case RCHFilterStatusAll:
            _filterStatus = nil;
            break;
        case RCHFilterStatusResolved:
            _filterStatus = @"resolved";
            break;
        case RCHFilterStatusRevoked:
            _filterStatus = @"revoked";
            break;
        default:
            _filterStatus = nil;
            break;
    }
            
    
}

- (void)selectButtonClick:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    self.selectButton.layer.borderColor = [kYellowColor CGColor];
    !self.changeCoin ?: self.changeCoin();
}

- (void)filterButtonClick:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    NSMutableDictionary *filter = [NSMutableDictionary dictionary];
    if (!RCHIsEmpty(_filterCoin)) {
        [filter  setObject:_filterCoin forKey:@"coin"];
    }
    
    if (!RCHIsEmpty(_filterCurrency)) {
        [filter  setObject:_filterCurrency forKey:@"currency"];
    }
    
    if (!RCHIsEmpty(_filterStatus)) {
        [filter  setObject:_filterStatus forKey:@"status"];
    }
    
    !self.filter ?: self.filter(filter);
}

- (void)resetButtonClick:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    _filterCoin =  nil;
    _filterCurrency =  nil;
    _filterStatus =  nil;
    self.coinTextField.text = @"";
    [self.selectButton setTitle:@"全部" forState:UIControlStateNormal];
    [self changeStatus:RCHFilterStatusAll];
}

#pragma mark -
#pragma mark - CustomFuction

- (void)setDefaultFilter:(NSDictionary *)filter
{
    _filterCoin =  [filter objectForKey:@"coin"] ?: nil;
    if (!RCHIsEmpty(_filterCoin)) _coinTextField.text = _filterCoin;
    
    _filterCurrency =  [filter objectForKey:@"currency"];
    [self.selectButton setTitle:_filterCurrency ?: @"全部" forState:UIControlStateNormal];
    
    _filterStatus =  [filter objectForKey:@"status"] ?: nil;
    RCHFilterStatus status;
    if (RCHIsEmpty(_filterStatus)) {
        status = RCHFilterStatusAll;
    } else {
        if ([_filterStatus isEqualToString:@"resolved"]) {
            status = RCHFilterStatusResolved;
        } else {
            status = RCHFilterStatusRevoked;
        }
    }
    [self changeStatus:status];
    
}

- (void)setCurrency:(NSString *)currency
{
    if (RCHIsEmpty(currency)) {
        return;
    }
    _filterCurrency = currency;
    [self.selectButton setTitle:_filterCurrency forState:UIControlStateNormal];
    self.selectButton.layer.borderColor = [kTradeBorderColor CGColor];
}

- (void) changeStatus:(RCHFilterStatus)status
{
    switch (status) {
        case RCHFilterStatusAll:
            self.allOrderButton.layer.borderColor = [kYellowColor CGColor];
            [self.allOrderButton setSelected:YES];
            self.resolvedOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
            [self.resolvedOrderButton setSelected:NO];
            self.revokedOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
            [self.revokedOrderButton setSelected:NO];
            break;
        case RCHFilterStatusResolved:
            self.allOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
            [self.allOrderButton setSelected:NO];
            self.resolvedOrderButton.layer.borderColor = [kYellowColor CGColor];
            [self.resolvedOrderButton setSelected:YES];
            self.revokedOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
            [self.revokedOrderButton setSelected:NO];
            break;
        case RCHFilterStatusRevoked:
            self.allOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
            [self.allOrderButton setSelected:NO];
            self.resolvedOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
            [self.resolvedOrderButton setSelected:NO];
            self.revokedOrderButton.layer.borderColor = [kYellowColor CGColor];
            [self.revokedOrderButton setSelected:YES];
            break;
        default:
            self.allOrderButton.layer.borderColor = [kYellowColor CGColor];
            [self.allOrderButton setSelected:YES];
            self.resolvedOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
            [self.resolvedOrderButton setSelected:NO];
            self.revokedOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
            [self.revokedOrderButton setSelected:NO];
            break;
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.marketView.layer.borderColor = [kYellowColor CGColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _filterCoin = _coinTextField.text;
    self.marketView.layer.borderColor = [kTradeBorderColor CGColor];
}


#pragma mark -
#pragma mark - getter

- (UILabel *)tradeLabel
{
    if(!_tradeLabel)
    {
        UILabel *tradeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tradeLabel.textAlignment = NSTextAlignmentLeft;
        tradeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        tradeLabel.textColor = kTextUnselectColor;
        tradeLabel.text = @"交易对";
        [tradeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:tradeLabel];
        
        _tradeLabel = tradeLabel;
    }
    return _tradeLabel;
}

- (UILabel *)orderLabel
{
    if(!_orderLabel)
    {
        UILabel *orderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        orderLabel.textAlignment = NSTextAlignmentLeft;
        orderLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        orderLabel.textColor = kTextUnselectColor;
        orderLabel.text = @"订单状态";
        [orderLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:orderLabel];
        
        _orderLabel = orderLabel;
    }
    return _orderLabel;
}

- (UIView *)marketView
{
    if(!_marketView)
    {
        UIView *marketView = [[UIView alloc] init];
        marketView.layer.borderColor = [kTradeBorderColor CGColor];
        marketView.layer.borderWidth = 1.0;
        marketView.layer.cornerRadius = 0.0;
        marketView.layer.masksToBounds = YES;
        [self addSubview:marketView];

        _marketView = marketView;
        
        [self.coinTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f));
        }];
    }
    return _marketView;
}

- (UITextField *)coinTextField
{
    if(!_coinTextField)
    {
        UITextField *coinTextField = [[UITextField alloc] init];
        coinTextField.textAlignment = NSTextAlignmentLeft;
        coinTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters; //默认大些
        coinTextField.autocorrectionType = UITextAutocorrectionTypeNo; //关闭联想
        coinTextField.keyboardType = UIKeyboardTypeASCIICapable;
        coinTextField.placeholder = @"币种";
        
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:coinTextField.placeholder];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:kTextUnselectColor
                            range:NSMakeRange(0, coinTextField.placeholder.length)];
        [placeholder addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"PingFangSC-Regular" size:14.0f]
                            range:NSMakeRange(0, coinTextField.placeholder.length)];
        coinTextField.attributedPlaceholder = placeholder;
        
        coinTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        coinTextField.textColor = kNavigationColor_MB;
        coinTextField.delegate = self;
        coinTextField.text = @"";
        [coinTextField setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.marketView addSubview:coinTextField];
        
        _coinTextField = coinTextField;
    }
    return _coinTextField;
}


- (UILabel *)divLabel
{
    if(!_divLabel)
    {
        UILabel *divLabel = [[UILabel alloc] init];
        divLabel.textAlignment = NSTextAlignmentCenter;
        divLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.f];
        divLabel.textColor = kNavigationColor_MB;
        divLabel.text = @"/";
        [divLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:divLabel];
        
        _divLabel = divLabel;
    }
    return _divLabel;
}

- (UIButton *)selectButton
{
    if(!_selectButton)
    {
        UIImage *image = RCHIMAGEWITHNAMED(@"ico_arrow_country");
        
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchDown];
        [selectButton setImage:image forState:UIControlStateNormal];
        [selectButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [selectButton setTitleColor:kNavigationColor_MB forState:UIControlStateNormal];
        [selectButton setTitle:NSLocalizedString(@"全部", nil) forState:UIControlStateNormal];
        selectButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        [self addSubview:selectButton];
        
        // button标题的偏移量
        selectButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -113.0f, 0.0f, 0.0f);
        // button图片的偏移量
        selectButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 135.0f, 0.0f, 0.0f);
        
        selectButton.layer.borderColor = [kTradeBorderColor CGColor];
        selectButton.layer.borderWidth = 1.0;
        selectButton.layer.cornerRadius = 0.0;
        selectButton.layer.masksToBounds = YES;
        
        _selectButton = selectButton;
    }
    return _selectButton;
}

- (UIButton *)allOrderButton
{
    if(!_allOrderButton)
    {
        UIButton *allOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [allOrderButton addTarget:self action:@selector(changeStatusButtonClick:) forControlEvents:UIControlEventTouchDown];
        [allOrderButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [allOrderButton setTitleColor:kTextUnselectColor forState:UIControlStateNormal];
        [allOrderButton setTitleColor:kAppOrangeColor forState:UIControlStateSelected];
        [allOrderButton setTitle:NSLocalizedString(@"全部", nil) forState:UIControlStateNormal];
        allOrderButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        allOrderButton.tag = RCHFilterStatusAll;
        [self addSubview:allOrderButton];
  
        allOrderButton.layer.borderColor = [kYellowColor CGColor];
        allOrderButton.layer.borderWidth = 1.0;
        allOrderButton.layer.cornerRadius = 0.0;
        allOrderButton.layer.masksToBounds = YES;
        
        _allOrderButton = allOrderButton;
    }
    return _allOrderButton;
}

- (UIButton *)resolvedOrderButton
{
    if(!_resolvedOrderButton)
    {
        UIButton *resolvedOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [resolvedOrderButton addTarget:self action:@selector(changeStatusButtonClick:) forControlEvents:UIControlEventTouchDown];
        [resolvedOrderButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [resolvedOrderButton setTitleColor:kTextUnselectColor forState:UIControlStateNormal];
        [resolvedOrderButton setTitleColor:kAppOrangeColor forState:UIControlStateSelected];
        [resolvedOrderButton setTitle:NSLocalizedString(@"已成交", nil) forState:UIControlStateNormal];
        resolvedOrderButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        resolvedOrderButton.tag = RCHFilterStatusResolved;
        [self addSubview:resolvedOrderButton];
        
        resolvedOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
        resolvedOrderButton.layer.borderWidth = 1.0;
        resolvedOrderButton.layer.cornerRadius = 0.0;
        resolvedOrderButton.layer.masksToBounds = YES;
        
        _resolvedOrderButton = resolvedOrderButton;
    }
    return _resolvedOrderButton;
}

- (UIButton *)revokedOrderButton
{
    if(!_revokedOrderButton)
    {
        UIButton *revokedOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [revokedOrderButton addTarget:self action:@selector(changeStatusButtonClick:) forControlEvents:UIControlEventTouchDown];
        [revokedOrderButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [revokedOrderButton setTitleColor:kTextUnselectColor forState:UIControlStateNormal];
        [revokedOrderButton setTitleColor:kAppOrangeColor forState:UIControlStateSelected];
        [revokedOrderButton setTitle:NSLocalizedString(@"已撤销", nil) forState:UIControlStateNormal];
        revokedOrderButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        revokedOrderButton.tag = RCHFilterStatusRevoked;
        [self addSubview:revokedOrderButton];
        
        revokedOrderButton.layer.borderColor = [kTradeBorderColor CGColor];
        revokedOrderButton.layer.borderWidth = 1.0;
        revokedOrderButton.layer.cornerRadius = 0.0;
        revokedOrderButton.layer.masksToBounds = YES;

        _revokedOrderButton = revokedOrderButton;
    }
    return _revokedOrderButton;
}

- (UIButton *)resetButton
{
    if(!_resetButton)
    {
        UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetButton addTarget:self action:@selector(resetButtonClick:) forControlEvents:UIControlEventTouchDown];
        [resetButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [resetButton setTitleColor:kAppOrangeColor forState:UIControlStateNormal];
        [resetButton setTitle:NSLocalizedString(@"重置", nil) forState:UIControlStateNormal];
        resetButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
        [self addSubview:resetButton];
        
        MJLOnePixLineView *spacelineView = [[MJLOnePixLineView alloc] init];
        [resetButton addSubview:spacelineView];
        [spacelineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0.0f);
            make.height.mas_equalTo([RCHHelper retinaFloat:1.0f]);
            
        }];
 
        _resetButton = resetButton;
    }
    return _resetButton;
}

- (UIButton *)commitButton
{
    if(!_commitButton)
    {
        UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commitButton addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchDown];
        [commitButton setBackgroundColor:kAppOrangeColor forState:UIControlStateNormal];
        [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [commitButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
        commitButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
        [self addSubview:commitButton];
        
        
        _commitButton = commitButton;
    }
    return _commitButton;
}

@end
