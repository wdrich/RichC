//
//  RCHAutoAgencyFormView.m
//  richcore
//
//  Created by WangDong on 2018/6/19.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAutoAgencyFormView.h"
#import "RCHNumberEditView.h"
#import "RCHSegmentView.h"
#import "RCHAlertView.h"
#import "RCHWallet.h"

#define BORDERWIDTH [RCHHelper retinaFloat:1.0f]
#define originX 10.0f

@interface RCHAutoAgencyFormView ()
{
    void (^_onSubmit)(RCHAutoAgency *, UIButton *);
    RCHAutoAgency *_agency;
    UILabel *_miniCnyLabel;
    UILabel *_maxCnyLabel;
    UILabel *_totalLabel;
    RCHNumberTextField *_miniPriceTextField;
    RCHNumberTextField *_maxPriceTextField;
    RCHNumberTextField *_stepPriceTextField;
    RCHNumberTextField *_amountTextField;
    UILabel *_availableLabel;
    UILabel *_availableBaseLabel;
    RCHWallet *_currencyWallet;
    RCHWallet *_coinWallet;
    
    NSNumberFormatter *_numberFormatter;
}
@end

@implementation RCHAutoAgencyFormView

- (id)initWithFrame:(CGRect)frame onSubmit:(void (^)(RCHAutoAgency *, UIButton *))onSubmit {
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
    _agency.price = price;
    [_agency resetPriceRange];
    
    _agency.miniPrice = [_agency price_mini];
    _agency.maxPrice = [_agency price_max];
    
    if (_miniPriceTextField) {
        _miniPriceTextField.text = _agency.miniPrice ? [NSString stringWithFormat:@"%@", _agency.miniPrice] : nil;
        _miniPriceTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                               size:(_miniPriceTextField.text && [_miniPriceTextField.text length] > 0 ? 14.0f : 12.f)];
    }
    if (_maxPriceTextField) {
        _maxPriceTextField.text = _agency.maxPrice ? [NSString stringWithFormat:@"%@", _agency.maxPrice] : nil;
        _maxPriceTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                               size:(_maxPriceTextField.text && [_maxPriceTextField.text length] > 0 ? 14.0f : 12.f)];
    }
    [self setMiniPriceCNY];
    [self setMaxPriceCNY];
//    [self setTotal];
}

- (void)reloadWithAgency:(RCHAutoAgency *)agency {
    _agency = agency;
    _miniCnyLabel = nil;
    _maxCnyLabel= nil;
    _totalLabel = nil;
    _miniPriceTextField = nil;
    _maxPriceTextField = nil;
    _amountTextField = nil;
    _availableLabel = nil;
    _availableBaseLabel = nil;
    
    [self removeAllSubviews];
    
    if (!_agency) return;
    
    CGFloat bottom = 0.0f;
    CGRect frame = [self createLowPriceView:bottom];
    bottom += frame.size.height;
    frame = [self createLowPriceCNYView:bottom];
    bottom += frame.size.height + 5.0f;
    frame = [self createHighPriceView:bottom];
    bottom += frame.size.height;
    frame = [self createHeighPriceCNYView:bottom];
    bottom += frame.size.height + 5.0f;
    frame = [self createStepPriceView:bottom];
    bottom += frame.size.height;
    frame = [self createPriceStepLabelView:bottom];
    bottom += frame.size.height + 5.0f;
    frame = [self createAmountView:bottom];
    bottom += frame.size.height;
    frame = [self createAmountLabelView:bottom];
//    bottom += frame.size.height + 5.0f;
//    frame = [self createSegmentView:bottom];
//    bottom += frame.size.height + 15.0f;
//    frame = [self createTotalView:bottom];
    bottom += frame.size.height + 5.0f;
    frame = [self createAvailableView:bottom];
    bottom += frame.size.height + 10.0f;
    frame = [self createSubmit:bottom];
//    bottom += frame.size.height + 10.0f;
//    [self createNoticeView:bottom];
}


- (CGRect)createLowPriceView:(CGFloat)bottom {
    RCHNumberEditView *priceView = [[RCHNumberEditView alloc] initWithFrame:(CGRect){{originX, bottom}, {self.width - originX * 2, 44.0f}}];
    priceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    priceView.backgroundColor = [UIColor whiteColor];
    
    priceView.step = [NSString stringWithFormat:@"%@", _agency.market ? [NSDecimalNumber decimalNumberWithDecimal:[_agency.market.price_step decimalValue]] : @"0.00000001"];
    priceView.number = _agency.miniPrice;
//    self->_agency.miniPrice = nil;
    priceView.textField.numeric = CGNumeric(20, 8);
    
    priceView.textField.placeholder =[NSString stringWithFormat:@"最低价(%@)", _agency.market ? _agency.market.currency.code : @"--"];
    priceView.reduceButton.backgroundColor = kTextUnselectColor;
    priceView.reduceImageNormal = [UIImage imageNamed:@"btn_minus"];
    
    priceView.addButton.backgroundColor = kTextUnselectColor;
    priceView.addImageNormal = [UIImage imageNamed:@"btn_add"];
    
    priceView.borderShow = YES;
    priceView.borderColor = kTradeBorderColor;
    priceView.borderWidth = BORDERWIDTH;
    
    priceView.textColor = kNavigationColor_MB;
    priceView.textFont = [UIFont fontWithName:@"PingFangSC-Regular"
                                         size:(priceView.textField.text && [priceView.textField.text length] > 0 ? 14.0f : 12.f)];
    priceView.buttonWidth = 36.0f;
    priceView.buttonHeight = 44.0f;
    
    priceView.addTitleNormal = @"";
    priceView.reduceTitleNormal = @"";
    
    priceView.numberEdit = ^(NSString *string) {
        if (self->_miniPriceTextField) {
            self->_miniPriceTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                                            size:(self->_miniPriceTextField.text && [self->_miniPriceTextField.text length] > 0 ? 14.0f : 12.0f)];
        }
        if (!self->_agency.market) return;
        self->_agency.miniPrice = [NSDecimalNumber decimalNumberWithString:string];
        [self setMiniPriceCNY];
//        [self setTotal];
    };
    priceView.finishEdit = ^(NSString *string) {
        if (!self->_agency.market) return;
        self->_agency.miniPrice = [NSDecimalNumber decimalNumberWithString:string];
        [self setMiniPriceCNY];
//        [self setTotal];
    };
    [self addSubview:priceView];
    _miniPriceTextField = priceView.textField;
    return priceView.bounds;
}

- (CGRect)createLowPriceCNYView:(CGFloat)bottom{
    _miniCnyLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, bottom, self.width - originX * 2, 20.0f)];
    _miniCnyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _miniCnyLabel.backgroundColor = [UIColor clearColor];
    _miniCnyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    _miniCnyLabel.textColor = kTextUnselectColor;
    [self setMiniPriceCNY];
    [self addSubview:_miniCnyLabel];
    return _miniCnyLabel.bounds;
}

- (CGRect)createHighPriceView:(CGFloat)bottom{
    RCHNumberEditView *priceView = [[RCHNumberEditView alloc] initWithFrame:(CGRect){{originX, bottom}, {self.width - originX * 2, 44.0f}}];
    priceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    priceView.backgroundColor = [UIColor whiteColor];
    
    priceView.step = [NSString stringWithFormat:@"%@", _agency.market ? [NSDecimalNumber decimalNumberWithDecimal:[_agency.market.price_step decimalValue]] : @"0.00000001"];
    priceView.number = _agency.maxPrice;
//    self->_agency.maxPrice = nil;
    priceView.textField.numeric = CGNumeric(20, 8);
    
    priceView.textField.placeholder =[NSString stringWithFormat:@"最高价(%@)", _agency.market ? _agency.market.currency.code : @"--"];
    priceView.reduceButton.backgroundColor = kTextUnselectColor;
    priceView.reduceImageNormal = [UIImage imageNamed:@"btn_minus"];
    
    priceView.addButton.backgroundColor = kTextUnselectColor;
    priceView.addImageNormal = [UIImage imageNamed:@"btn_add"];
    
    priceView.borderShow = YES;
    priceView.borderColor = kTradeBorderColor;
    priceView.borderWidth = BORDERWIDTH;
    
    priceView.textColor = kNavigationColor_MB;
    priceView.textFont = [UIFont fontWithName:@"PingFangSC-Regular"
                                         size:(priceView.textField.text && [priceView.textField.text length] > 0 ? 14.0f : 12.f)];
    priceView.buttonWidth = 36.0f;
    priceView.buttonHeight = 44.0f;
    
    priceView.addTitleNormal = @"";
    priceView.reduceTitleNormal = @"";
    
    priceView.numberEdit = ^(NSString *string) {
        if (self->_maxPriceTextField) {
            self->_maxPriceTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                                             size:(self->_maxPriceTextField.text && [self->_maxPriceTextField.text length] > 0 ? 14.0f : 12.0f)];
        }
        if (!self->_agency.market) return;
        self->_agency.maxPrice = [NSDecimalNumber decimalNumberWithString:string];
    };
    priceView.finishEdit = ^(NSString *string) {
        if (!self->_agency.market) return;
        self->_agency.maxPrice = [NSDecimalNumber decimalNumberWithString:string];
    };
    [self addSubview:priceView];
    _maxPriceTextField = priceView.textField;
    
    return priceView.bounds;
}

- (CGRect)createHeighPriceCNYView:(CGFloat)bottom{
    _maxCnyLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, bottom, self.width - originX * 2, 20.0f)];
    _maxCnyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _maxCnyLabel.backgroundColor = [UIColor clearColor];
    _maxCnyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    _maxCnyLabel.textColor = kTextUnselectColor;
    [self setMaxPriceCNY];
    [self addSubview:_maxCnyLabel];
    return _maxCnyLabel.bounds;
}


- (CGRect)createStepPriceView:(CGFloat)bottom{
    RCHNumberEditView *priceView = [[RCHNumberEditView alloc] initWithFrame:(CGRect){{originX, bottom}, {self.width - originX * 2, 44.0f}}];
    priceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    priceView.backgroundColor = [UIColor whiteColor];
    
    priceView.step = [NSString stringWithFormat:@"%@", _agency.market ? [NSDecimalNumber decimalNumberWithDecimal:[_agency.market.price_step decimalValue]] : @"0.00000001"];
//    priceView.number = _agency.stepPrice;
   _agency.stepPrice = nil;
    priceView.textField.numeric = CGNumeric(20, 8);
    
    priceView.textField.placeholder = NSLocalizedString(@"挂单间隔",nil);
    priceView.reduceButton.backgroundColor = kTextUnselectColor;
    priceView.reduceImageNormal = [UIImage imageNamed:@"btn_minus"];
    
    priceView.addButton.backgroundColor = kTextUnselectColor;
    priceView.addImageNormal = [UIImage imageNamed:@"btn_add"];
    
    priceView.borderShow = YES;
    priceView.borderColor = kTradeBorderColor;
    priceView.borderWidth = BORDERWIDTH;
    
    priceView.textColor = kNavigationColor_MB;
    priceView.textFont = [UIFont fontWithName:@"PingFangSC-Regular"
                                         size:(priceView.textField.text && [priceView.textField.text length] > 0 ? 14.0f : 12.f)];
    priceView.buttonWidth = 36.0f;
    priceView.buttonHeight = 44.0f;
    
    priceView.addTitleNormal = @"";
    priceView.reduceTitleNormal = @"";
    
    priceView.numberEdit = ^(NSString *string) {
        if (self->_stepPriceTextField) {
            self->_stepPriceTextField.font = [UIFont fontWithName:@"PingFangSC-Regular"
                                                         size:(self->_stepPriceTextField.text && [self->_stepPriceTextField.text length] > 0 ? 14.0f : 12.0f)];
        }
        if (!self->_agency.market) return;
        self->_agency.stepPrice = [NSDecimalNumber decimalNumberWithString:string];
        [self->_agency resetPriceRange];
//        [self setMaxPriceCNY];
        //        [self setTotal];
    };
    priceView.finishEdit = ^(NSString *string) {
        if (!self->_agency.market) return;
        self->_agency.stepPrice = [NSDecimalNumber decimalNumberWithString:string];
        [self->_agency resetPriceRange];
//        [self setMaxPriceCNY];
        //        [self setTotal];
    };
    [self addSubview:priceView];
    _stepPriceTextField = priceView.textField;
    
    return priceView.bounds;
}

- (CGRect)createPriceStepLabelView:(CGFloat)bottom{
    UILabel *steplabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, bottom, self.width - originX * 2, 20.0f)];
    steplabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    steplabel.backgroundColor = [UIColor clearColor];
    steplabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    steplabel.text = [NSString stringWithFormat:NSLocalizedString(@"挂单间隔(%@)",nil), _agency.market.coin.code ?: @"--"];
    steplabel.textColor = kTextUnselectColor;
    [self addSubview:steplabel];
    return steplabel.bounds;
}



- (CGRect)createAmountView:(CGFloat)bottom{
    RCHNumberEditView *numberView = [[RCHNumberEditView alloc] initWithFrame:(CGRect){{originX, bottom}, self.width - originX * 2, 44}];
    numberView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    numberView.backgroundColor = [UIColor whiteColor];
    
    numberView.step = [NSString stringWithFormat:@"%@", _agency.market ? [NSDecimalNumber decimalNumberWithDecimal:[_agency.market.amount_step decimalValue]] : @"0.00000001"];
    numberView.number = _agency.amount;
    numberView.textField.numeric = CGNumeric(20, 8);
    
    numberView.textField.placeholder = NSLocalizedString(@"数量",nil);
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
//        [self setTotal];
    };
    numberView.finishEdit = ^(NSString *string){
        if (!self->_agency.market) return;
        self->_agency.amount = [NSDecimalNumber decimalNumberWithString:string];
//        [self setTotal];
    };
    [self addSubview:numberView];
    _amountTextField = numberView.textField;
    return numberView.bounds;
}

- (CGRect)createAmountLabelView:(CGFloat)bottom{
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, bottom, self.width - originX * 2, 20.0f)];
    amountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    amountLabel.backgroundColor = [UIColor clearColor];
    amountLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    amountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"数量(%@)",nil), _agency.market.currency.code ?: @"--"];
    amountLabel.textColor = kTextUnselectColor;
    [self addSubview:amountLabel];
    return amountLabel.bounds;
}


- (CGRect)createSegmentView:(CGFloat)bottom{
    RCHSegmentView *percentSegmentView = [[RCHSegmentView alloc] initWithFrame:CGRectMake(originX, bottom, self.width - originX * 2, 24)];
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
        }
//        [self setTotal];
    };
    
    [self addSubview:percentSegmentView];
    return percentSegmentView.bounds;
}

- (CGRect)createTotalView:(CGFloat)bottom{
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, bottom, self.width - originX * 2, 44)];
    _totalLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _totalLabel.backgroundColor = kLightGreenColor;
    _totalLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    _totalLabel.textAlignment = NSTextAlignmentCenter;
//    [self setTotal];
    _totalLabel.layer.masksToBounds = YES;
    _totalLabel.layer.cornerRadius = 0;
    _totalLabel.layer.borderWidth = BORDERWIDTH;
    _totalLabel.layer.borderColor = kTradeBorderColor.CGColor;
    [self addSubview:_totalLabel];
    return _totalLabel.bounds;
}

- (void)setMiniPriceCNY {
    if (!_miniCnyLabel) return;
    _miniCnyLabel.text = [NSString stringWithFormat:@"挂单最低价 ≈ ￥%.2f", _agency.priceCNY ? [[_agency price_CNY:_agency.miniPrice] doubleValue] : 0];
}

- (void)setMaxPriceCNY {
    if (!_maxCnyLabel) return;
    _maxCnyLabel.text = [NSString stringWithFormat:@"挂单最高价 ≈ ￥%.2f", _agency.priceCNY ? [[_agency price_CNY:_agency.maxPrice] doubleValue] : 0];
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

- (CGRect)createAvailableView:(CGFloat)bottom {
    
    CGFloat height = 17.0f;
    
    UIView *availableView = [[UIView alloc] initWithFrame:CGRectMake(originX, bottom, self.width - originX * 2, 36.0f)];
    availableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    availableView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, availableView.width / 4, height)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    titleLabel.textColor = kTextUnselectColor;
    titleLabel.text = @"可用";
    [availableView addSubview:titleLabel];
    
    _availableBaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(availableView.width / 6, 0, availableView.width * 5 / 6, height)];
    _availableBaseLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _availableBaseLabel.backgroundColor = [UIColor clearColor];
    _availableBaseLabel.textAlignment = NSTextAlignmentRight;
    _availableBaseLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.0f];
    _availableBaseLabel.textColor = kNavigationColor_MB;
    [availableView addSubview:_availableBaseLabel];
    
    UILabel *baseCoinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, availableView.width / 4, height)];
    baseCoinLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    baseCoinLabel.backgroundColor = [UIColor clearColor];
    baseCoinLabel.textAlignment = NSTextAlignmentLeft;
    baseCoinLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.0f];
    baseCoinLabel.textColor = kNavigationColor_MB;
    baseCoinLabel.text = _agency.market.currency.code;
    [availableView addSubview:baseCoinLabel];
    [baseCoinLabel sizeToFit];
    
    baseCoinLabel.frame = (CGRect){{availableView.width - baseCoinLabel.width, _availableBaseLabel.top}, {baseCoinLabel.width, height}};
    _availableBaseLabel.size = (CGSize){_availableBaseLabel.width - baseCoinLabel.width - 5.0f, _availableBaseLabel.height};
    
    
    _availableLabel = [[UILabel alloc] initWithFrame:CGRectMake(_availableBaseLabel.left, _availableBaseLabel.bottom + 2.0f, availableView.width * 5 / 6, height)];
    _availableLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _availableLabel.backgroundColor = [UIColor clearColor];
    _availableLabel.textAlignment = NSTextAlignmentRight;
    _availableLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.0f];
    _availableLabel.textColor = kNavigationColor_MB;
    [availableView addSubview:_availableLabel];
    
    UILabel *coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, availableView.width / 4, height)];
    coinLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    coinLabel.backgroundColor = [UIColor clearColor];
    coinLabel.textAlignment = NSTextAlignmentLeft;
    coinLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.0f];
    coinLabel.textColor = kNavigationColor_MB;
    coinLabel.text = _agency.market.coin.code;
    [availableView addSubview:coinLabel];
    [coinLabel sizeToFit];
    
    coinLabel.frame = (CGRect){{availableView.width - coinLabel.width, _availableLabel.top}, {coinLabel.width, height}};
    _availableLabel.frame = (CGRect){{_availableLabel.left, _availableLabel.top}, {_availableLabel.width - coinLabel.width - 5.0f, _availableLabel.height}};
    
    [self setAvailable];
    
    
    [self addSubview:availableView];
    
    return availableView.bounds;
}

- (void)setAvailable {
    if (!_availableLabel || !_agency.market) return;
    
    _availableLabel.text = [RCHHelper getNSDecimalString:_coinWallet.available defaultString:@"--" precision:_coinWallet.coin.scale];
    _availableBaseLabel.text = [RCHHelper getNSDecimalString:_currencyWallet.available defaultString:@"--" precision:_currencyWallet.coin.scale];
}

- (CGRect)createSubmit:(CGFloat)bottom {
    
    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitButton.frame = CGRectMake(originX, bottom, self.width - originX * 2, 44.0f);
//    _submitButton.backgroundColor = kTradePositiveColor;
    [_submitButton setBackgroundColor:kTradePositiveColor forState:UIControlStateNormal];
    [_submitButton setBackgroundColor:kTradeNegativeColor forState:UIControlStateSelected];
    _submitButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0f];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitButton setTitle:NSLocalizedString(@"开始挂单",nil) forState:UIControlStateNormal];
    [_submitButton setTitle:NSLocalizedString(@"停止挂单",nil) forState:UIControlStateSelected];
    [_submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_submitButton];
    
    return _submitButton.bounds;
}

- (CGRect)createNoticeView:(CGFloat)bottom {
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    
    NSMutableAttributedString *notice = [[NSMutableAttributedString alloc] initWithString:@"了解自动交易"];
    notice.yy_font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    notice.yy_underlineStyle = NSUnderlineStyleSingle;

    RCHWeak(self);
    [notice yy_setTextHighlightRange:notice.yy_rangeOfAll
                            color:kYellowColor
                  backgroundColor:[UIColor clearColor]
                        tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                            if (weakself.showNotice)
                            {
                                weakself.showNotice();
                            }
                        }];
    
    [text appendAttributedString:notice];
    
    YYLabel *label = [YYLabel new];
    label.attributedText = text;
    label.width = self.width;
    label.height = 17.0f;
    label.top = bottom;
    label.textAlignment = NSTextAlignmentCenter;
    label.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];

    return label.bounds;
}

- (void)submit:(UIButton *)button {
    if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
//        if (!_agency.valid) return;
        _onSubmit(_agency, button);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGotoLoginNotification object:nil];
    }
}


@end
