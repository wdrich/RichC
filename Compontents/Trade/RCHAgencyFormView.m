//
//  RCHAgencyFormView.m
//  richcore
//
//  Created by Apple on 2018/6/2.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAgencyFormView.h"
#import "RCHNumberEditView.h"
#import "RCHSegmentView.h"

#define BORDERWIDTH isRetina ? .5f : 1.f

@implementation RCHAgency

- (id)initWithType:(RCHAgencyType)type market:(RCHMarket *)market aim:(RCHAgencyAim)aim
{
    self = [super init];
    if (self) {
        self.type = type;
        self.market = market;
        self.aim = aim;
        self.price = type == RCHAgencyTypeMarket || !market || !market.state ? nil : [NSDecimalNumber decimalNumberWithDecimal:[market.state.last_price decimalValue]];
        self.amount = type == RCHAgencyTypeMarket || !market || !market.state ? nil : market.coin.commodity ? [NSDecimalNumber decimalNumberWithDecimal:[market.min_amount decimalValue]] : nil;
    }
    return self;
}

- (BOOL)valid {
    return !(!self.market || !self.amount || [self.amount compare:[NSDecimalNumber notANumber]] == NSOrderedSame || (self.type == RCHAgencyTypeLimit && !self.total));
}

- (NSDecimalNumber *)total {
    if (!self.price || !self.amount) return nil;
    if ([self.price compare:[NSDecimalNumber notANumber]] == NSOrderedSame || [self.amount compare:[NSDecimalNumber notANumber]] == NSOrderedSame) return nil;
    NSDecimalNumber *total = [self.price decimalNumberByMultiplyingBy:self.amount];
    if ([total compare:[NSDecimalNumber zero]] == NSOrderedSame) return nil;
    return total;
}

- (NSDecimalNumber *)priceCNY {
    if (!self.price || !self.market || !self.market.state) return nil;
    if ([self.price compare:[NSDecimalNumber notANumber]] == NSOrderedSame) return nil;
    return [self.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.market.state.cny_rate decimalValue]]];
}

- (NSString *)dtype {
    return self.type == RCHAgencyTypeMarket ? @"market" : @"limit";
}

- (NSString *)_aim {
    return self.aim == RCHAgencyAimBuy ? @"buy" : @"sell";
}

- (NSDictionary *)dispose {
    NSNumberFormatter *formatter = [RCHHelper getNumberFormatterFractionDigits:8];
    
    NSMutableDictionary *agency = [NSMutableDictionary dictionary];
    [agency setObject:self.market.symbol forKey:@"market"];
    [agency setObject:self._aim forKey:@"aim"];
    if (self.type == RCHAgencyTypeLimit) {
        [agency setObject:[formatter stringFromNumber:self.price] forKey:@"price"];
    }
    [agency setObject:[formatter stringFromNumber:self.amount] forKey:@"amount"];
    return [NSDictionary dictionaryWithObject:agency forKey:@"agency"];
}

@end

@interface RCHAgencyFormView ()
{
    void (^_onSubmit)(RCHAgency *);
    RCHAgency *_agency;
    UILabel *_cnyLabel;
    UILabel *_coinLabel;
    UILabel *_totalLabel;
    RCHNumberTextField *_priceTextField;
    RCHNumberTextField *_amountTextField;
    UILabel *_availableLabel;
    RCHWallet *_currencyWallet;
    RCHWallet *_coinWallet;
    
    NSNumberFormatter *_numberFormatter;
}
@end

@implementation RCHAgencyFormView

- (id)initWithFrame:(CGRect)frame onSubmit:(void (^)(RCHAgency *))onSubmit {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _onSubmit = [onSubmit copy];
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_numberFormatter setPositiveFormat:@"####.##"];
        [_numberFormatter setMaximumFractionDigits:8];
        [_numberFormatter setRoundingMode:NSNumberFormatterRoundFloor];
    }
    return self;
}

- (void)setWallets:(NSArray *)wallets {
    if (!wallets || [wallets count] != 2) {
        _currencyWallet = nil;
        _coinWallet = nil;
    } else {
        _currencyWallet = wallets[0];
        _coinWallet = wallets[1];
    }
    [self setAvailable];
}

- (void)setPrice:(NSDecimalNumber *)price {
    if (!_agency || !_agency.market || _agency.type == RCHAgencyTypeMarket) return;
    _agency.price = price;
    if (_priceTextField) {
        _priceTextField.text = _agency.price ? [NSString stringWithFormat:@"%@", _agency.price] : nil;
        _priceTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                                     size:(_priceTextField.text && [_priceTextField.text length] > 0 ? 14.0f : 12.f)];
    }
    [self setPriceCNY];
    [self setTotal];
}


- (void)setAmount:(NSDecimalNumber *)amount {
    if (!_agency || !_agency.market || _agency.type == RCHAgencyTypeMarket) return;
    _agency.amount = amount;
    if (_amountTextField) {
        _amountTextField.text = _agency.amount ? [NSString stringWithFormat:@"%@", _agency.amount] : nil;
        _amountTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                               size:(_amountTextField.text && [_amountTextField.text length] > 0 ? 14.0f : 12.f)];
    }
    [self setTotal];
}

- (void)reloadWithAgency:(RCHAgency *)agency {
    _agency = agency;
    _cnyLabel = nil;
    _totalLabel = nil;
    _priceTextField = nil;
    _amountTextField = nil;
    _availableLabel = nil;
    
    [self removeAllSubviews];
    
    if (!_agency) return;
    
    [self createPriceView];
    [self createPriceCNYView];
    [self createAmountView];
    [self createCoinView];
    [self createSegmentView];
    [self createTotalView];
    [self createAvailableView];
    [self createSubmit];
}

- (void)createPriceView {
    if (!_agency.market || _agency.type == RCHAgencyTypeLimit) {
        RCHNumberEditView *priceView = [[RCHNumberEditView alloc] initWithFrame:(CGRect){{10, 0}, {self.frame.size.width - 20, 44.0f}}];
        priceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        priceView.backgroundColor = [UIColor whiteColor];
        
        priceView.step = [NSString stringWithFormat:@"%@", _agency.market ? [NSDecimalNumber decimalNumberWithDecimal:[_agency.market.price_step decimalValue]] : @"0.00000001"];
        priceView.number = _agency.price;
        priceView.textField.numeric = CGNumeric(20, 8);
        
        priceView.textField.placeholder =[NSString stringWithFormat:@"价格(%@)", _agency.market ? _agency.market.currency.code : @"--"];
        priceView.reduceButton.backgroundColor = kTextUnselectColor;
        priceView.reduceImageNormal = [UIImage imageNamed:@"btn_minus"];
        
        priceView.addButton.backgroundColor = kTextUnselectColor;
        priceView.addImageNormal = [UIImage imageNamed:@"btn_add"];
        
        priceView.borderShow = YES;
        priceView.borderColor = kTradeBorderColor;
        priceView.borderWidth = BORDERWIDTH;
        
        priceView.textColor = kNavigationColor_MB;
        priceView.textFont = [UIFont fontWithName:@"PingFangSC-Regular"
                                             size:(priceView.textField.text && [priceView.textField.text length] > 0 ? 14.0f : 12.0f)];
        priceView.buttonWidth = 36.0f;
        priceView.buttonHeight = 44.0f;
        
        priceView.addTitleNormal = @"";
        priceView.reduceTitleNormal = @"";
        
        priceView.numberEdit = ^(NSString *string) {
            if (self->_priceTextField) {
                self->_priceTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                                             size:(self->_priceTextField.text && [self->_priceTextField.text length] > 0 ? 14.0f : 12.0f)];
            }
            if (!self->_agency.market) return;
            self->_agency.price = [NSDecimalNumber decimalNumberWithString:string];
            [self setPriceCNY];
            [self setTotal];
        };
        priceView.finishEdit = ^(NSString *string) {
            if (!self->_agency.market) return;
            self->_agency.price = [NSDecimalNumber decimalNumberWithString:string];
            [self setPriceCNY];
            [self setTotal];
        };
        [self addSubview:priceView];
        _priceTextField = priceView.textField;
    } else {
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:(CGRect){{10, 0}, {self.frame.size.width - 20, 44.0f}}];
        priceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        priceLabel.backgroundColor = kLightGreenColor;
        priceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        priceLabel.textColor = kTextUnselectColor;
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.text = [NSString stringWithFormat:@"以当前最优价格%@", _agency.aim == RCHAgencyAimBuy ? @"买入" : @"卖出"];
        priceLabel.layer.masksToBounds = YES;
        priceLabel.layer.cornerRadius = 0;
        priceLabel.layer.borderWidth = BORDERWIDTH;
        priceLabel.layer.borderColor = kTradeBorderColor.CGColor;
        [self addSubview:priceLabel];
    }
}

- (void)createPriceCNYView {
    if (_agency.type == RCHAgencyTypeMarket) return;
    
    _cnyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, self.frame.size.width - 20, 20)];
    _cnyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _cnyLabel.backgroundColor = [UIColor clearColor];
    _cnyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    _cnyLabel.textColor = kTextUnselectColor;
    [self setPriceCNY];
    [self addSubview:_cnyLabel];
}

- (void)createAmountView {
    if (_agency.type == RCHAgencyTypeLimit || _agency.aim == RCHAgencyAimSell) {
        RCHNumberEditView *numberView = [[RCHNumberEditView alloc] initWithFrame:(CGRect){{10, 64 + 5.0f}, self.frame.size.width - 20, 44}];
        numberView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        numberView.backgroundColor = [UIColor whiteColor];
        
        numberView.step = [NSString stringWithFormat:@"%@", _agency.market ? [NSDecimalNumber decimalNumberWithDecimal:[_agency.market.amount_step decimalValue]] : @"0.00000001"];
        numberView.number = _agency.amount;
        numberView.textField.numeric = CGNumeric(20, 8);
        
        numberView.textField.placeholder =[NSString stringWithFormat:@"数量(%@)", _agency.market ? _agency.market.coin.code : @"--"];
        numberView.reduceButton.backgroundColor = kTextUnselectColor;
        numberView.reduceImageNormal = [UIImage imageNamed:@"btn_minus"];
        
        numberView.addButton.backgroundColor = kTextUnselectColor;
        numberView.addImageNormal = [UIImage imageNamed:@"btn_add"];
        
        numberView.borderShow = YES;
        numberView.borderColor = kTradeBorderColor;
        numberView.borderWidth = BORDERWIDTH;
        
        numberView.textColor = kNavigationColor_MB;
        numberView.textFont = [UIFont fontWithName:@"PingFangSC-Regular"
                                              size:(numberView.textField.text && [numberView.textField.text length] > 0 ? 14.0f : 12.f)];
        numberView.buttonWidth = 36.0f;
        numberView.buttonHeight = 44.0f;
        
        numberView.addTitleNormal = @"";
        numberView.reduceTitleNormal = @"";
        
        numberView.numberEdit = ^(NSString *string){
            if (self->_amountTextField) {
                self->_amountTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                                             size:(self->_amountTextField.text && [self->_amountTextField.text length] > 0 ? 14.0f : 12.f)];
            }
            if (!self->_agency.market) return;
            self->_agency.amount = [NSDecimalNumber decimalNumberWithString:string];
            [self setTotal];
        };
        numberView.finishEdit = ^(NSString *string){
            if (!self->_agency.market) return;
            self->_agency.amount = [NSDecimalNumber decimalNumberWithString:string];
            [self setTotal];
        };
        [self addSubview:numberView];
        _amountTextField = numberView.textField;
    } else {
        UIView *totalView = [[UIView alloc] initWithFrame:(CGRect){{10, 64}, self.frame.size.width - 20, 44}];
        totalView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        totalView.backgroundColor = [UIColor whiteColor];
        totalView.layer.masksToBounds = YES;
        totalView.layer.cornerRadius = 0;
        totalView.layer.borderWidth = BORDERWIDTH;
        totalView.layer.borderColor = kTradeBorderColor.CGColor;
        
        UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalView.width - 62, 0, 50, 44)];
        unitLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        unitLabel.backgroundColor = [UIColor clearColor];
        unitLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        unitLabel.textColor = kNavigationColor_MB;
        unitLabel.textAlignment = NSTextAlignmentRight;
        unitLabel.text = _agency.market ? _agency.market.currency.code : @"--";
        [totalView addSubview:unitLabel];
        
        RCHNumberTextField *totalTextField = [[RCHNumberTextField alloc] initWithFrame:CGRectMake(12, 0, totalView.width - 74, 44)];
        totalTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        totalTextField.backgroundColor = [UIColor clearColor];
        totalTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        totalTextField.adjustsFontSizeToFitWidth = YES;
        totalTextField.borderStyle = UITextBorderStyleNone;
        totalTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        totalTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        totalTextField.textAlignment = NSTextAlignmentLeft;
        totalTextField.placeholder = @"交易额";
        totalTextField.textColor = kNavigationColor_MB;
        totalTextField.numeric = CGNumeric(20, 8);
        totalTextField.returnKeyType = UIReturnKeyNext;
        totalTextField.onChanged = ^(NSString *string){
            if (self->_amountTextField) {
                self->_amountTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                                              size:(self->_amountTextField.text && [self->_amountTextField.text length] > 0 ? 14.0f : 12.f)];
            }
            if (!self->_agency.market) return;
            self->_agency.amount = [NSDecimalNumber decimalNumberWithString:string];
        };
        totalTextField.finishEdit = ^(NSString *string){
            if (!self->_agency.market) return;
            self->_agency.amount = [NSDecimalNumber decimalNumberWithString:string];
        };
        [totalView addSubview:totalTextField];
        [self addSubview:totalView];
        _amountTextField = totalTextField;
    }
}

- (void)createCoinView {
    if (_agency.type == RCHAgencyTypeMarket) return;
    
    RCHMarket *market = [[RCHGlobal sharedGlobal] currentMarket];
    _coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 115.0f, self.frame.size.width - 20, 20)];
    _coinLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _coinLabel.backgroundColor = [UIColor clearColor];
    _coinLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    _coinLabel.textColor = kTextUnselectColor;
    _coinLabel.text = [NSString stringWithFormat:@"数量(%@)", market.coin.code ?: @"--"];
    [self addSubview:_coinLabel];
}

- (void)createSegmentView {
    RCHSegmentView *percentSegmentView = [[RCHSegmentView alloc] initWithFrame:CGRectMake(10, 138.0f, self.frame.size.width - 20, 24)];
    percentSegmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    percentSegmentView.layer.borderColor = kTradeBorderColor.CGColor;
    percentSegmentView.layer.borderWidth = BORDERWIDTH;
    percentSegmentView.layer.cornerRadius = 0.0;
    percentSegmentView.layer.masksToBounds = YES;
    percentSegmentView.btnTitleArray = @[@"25%",@"50%",@"75%", @"100%"];
    
    percentSegmentView.titleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    percentSegmentView.btnTitleNormalColor = kTextUnselectColor;
    percentSegmentView.btnTitleSelectColor = kAppOrangeColor;
    
    percentSegmentView.btnBackgroundNormalColor = [UIColor clearColor];
    percentSegmentView.btnBackgroundSelectColor = [UIColor clearColor];
    
    percentSegmentView.rchSegmentBtnSelectIndexBlock = ^(NSInteger index) {
        if (!self->_agency.market) return;
        if (!([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0)) return;
        if (!self->_currencyWallet || !self->_coinWallet) return;
        
        RCHWallet *theWallet = self->_agency.aim == RCHAgencyAimBuy ? self->_currencyWallet : self->_coinWallet;
        NSDecimalNumber *number = [theWallet.available decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:(index + 1) * 0.25f] decimalValue]]];
        if (!number) return;
        
        NSDecimalNumber *amount = nil;
        if (self->_agency.type == RCHAgencyTypeLimit && self->_agency.aim == RCHAgencyAimBuy && self->_agency.price && [self->_agency.price compare:[NSDecimalNumber notANumber]] != NSOrderedSame && [self->_agency.price compare:[NSDecimalNumber zero]] != NSOrderedSame) {
            amount = [number decimalNumberByDividingBy:self->_agency.price];
        } else {
            amount = number;
        }
        
        NSDecimalNumber *precision = [[NSDecimalNumber decimalNumberWithString:@"1"] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithDecimal:[self->_agency.market.amount_step decimalValue]]];
        self->_agency.amount = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.0f", floor([[amount decimalNumberByMultiplyingBy:precision] doubleValue])]] decimalNumberByDividingBy:precision];
        
        if (self->_amountTextField) {
            self->_amountTextField.text = [NSString stringWithFormat:@"%@", self->_agency.amount];
            self->_amountTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                                          size:(self->_amountTextField.text && [self->_amountTextField.text length] > 0 ? 14.0f : 12.f)];
        }
        [self setTotal];
    };
    
    [self addSubview:percentSegmentView];
}

- (void)createTotalView {
    if (_agency.type == RCHAgencyTypeMarket) return;
    
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 177.0f, self.frame.size.width - 20, 44)];
    _totalLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _totalLabel.backgroundColor = kLightGreenColor;
    _totalLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    _totalLabel.textAlignment = NSTextAlignmentCenter;
    [self setTotal];
    _totalLabel.layer.masksToBounds = YES;
    _totalLabel.layer.cornerRadius = 0;
    _totalLabel.layer.borderWidth = BORDERWIDTH;
    _totalLabel.layer.borderColor = kTradeBorderColor.CGColor;
    [self addSubview:_totalLabel];
}

- (void)setPriceCNY {
    if (!_cnyLabel) return;
    _cnyLabel.text = [NSString stringWithFormat:@"估值 ￥%.2f", _agency.priceCNY ? [_agency.priceCNY doubleValue] : 0];
}

- (void)setTotal {
    if (!_totalLabel) return;
    
    if (_agency.total) {
        _totalLabel.textColor = kNavigationColor_MB;
        _totalLabel.text = [NSString stringWithFormat:@"%@", [_numberFormatter stringFromNumber:_agency.total]];
    } else {
        _totalLabel.textColor = kTextUnselectColor;
        _totalLabel.text = [NSString stringWithFormat:@"交易额(%@)", _agency.market ? _agency.market.currency.code : @"--"];
    }
}

- (void)createAvailableView {
    UIView *availableView = [[UIView alloc] initWithFrame:CGRectMake(10, 206 - (_agency.type == RCHAgencyTypeMarket ? 49 : 0) + 15.0f , self.frame.size.width - 20, 27)];
    availableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    availableView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, availableView.width / 4, availableView.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    titleLabel.textColor = kTextUnselectColor;
    titleLabel.text = @"可用";
    [availableView addSubview:titleLabel];
    
    NSString *coin;
    if (_agency.aim == RCHAgencyAimBuy) {
        coin = _agency.market.currency.code;
    } else {
        coin = _agency.market.coin.code;
    }
    
    _availableLabel = [[UILabel alloc] initWithFrame:CGRectMake(availableView.width / 6, 0, availableView.width * 5 / 6, availableView.height)];
    _availableLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _availableLabel.backgroundColor = [UIColor clearColor];
    _availableLabel.textAlignment = NSTextAlignmentRight;
    _availableLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.0f];
    _availableLabel.textColor = kNavigationColor_MB;
    [self setAvailable];
    [availableView addSubview:_availableLabel];
    
    UILabel *coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, availableView.width / 4, availableView.height)];
    coinLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    coinLabel.backgroundColor = [UIColor clearColor];
    coinLabel.textAlignment = NSTextAlignmentLeft;
    coinLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.0f];
    coinLabel.textColor = kNavigationColor_MB;
    coinLabel.text = coin;
    [availableView addSubview:coinLabel];
    [coinLabel sizeToFit];
    
    coinLabel.frame = (CGRect){{availableView.width - coinLabel.width, _availableLabel.top}, {coinLabel.width, availableView.height}};
    _availableLabel.frame = (CGRect){{_availableLabel.left, _availableLabel.top}, {_availableLabel.width - coinLabel.width - 5.0f, _availableLabel.height}};
    
    [self addSubview:availableView];
}

- (void)setAvailable {
    if (!_availableLabel || !_agency.market) return;
    
    if (_agency.aim == RCHAgencyAimBuy) {
        _availableLabel.text = [RCHHelper getNSDecimalString:_currencyWallet.available defaultString:@"--" precision:_currencyWallet.coin.scale];
    } else {
        _availableLabel.text = [RCHHelper getNSDecimalString:_coinWallet.available defaultString:@"--" precision:_coinWallet.coin.scale];
    }
}

- (void)createSubmit {
    UIColor *color;
    NSString *title;
    switch (_agency.aim) {
        case RCHAgencyAimBuy:
            color = kTradePositiveColor;
            title = @"买入";
            break;
        case RCHAgencyAimSell:
            color = kTradeNegativeColor;
            title = @"卖出";
            break;
        case RCHAgencyAimAuto:
            color = kAppOrangeColor;
            title = @"自动下单";
            break;
            
        default:
            color = kTradeNegativeColor;
            title = @"卖出";
            break;
    }
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(10, 243 - (_agency.type == RCHAgencyTypeMarket ? 49 : 0) + 15.0f, self.frame.size.width - 20, 44);
    submitButton.backgroundColor = color;
    submitButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitle:title forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:submitButton];
}

- (void)submit:(UIButton *)button {
    if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
        if (!_agency.valid) return;
        _onSubmit(_agency);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGotoLoginNotification object:nil];
    }
}

@end
