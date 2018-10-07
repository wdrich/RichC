//
//  RCHPayViewController.m
//  richcore
//
//  Created by Apple on 2018/5/15.
//  Copyright © 2018年 Sun Lei. All rights reserved.
//

#import "RCHPayViewController.h"
#import "RCHPayVerifyViewController.h"
#import "RCHPayNavigationBar.h"

@interface PayView : UIView {}
@end

@implementation PayView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetLineWidth(context, .5f);
    [RGBA(225.f, 225.f, 225.f, 1.f) setStroke];
    CGContextMoveToPoint(context, 15, 133);
    CGContextAddLineToPoint(context, rect.size.width, 133);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

@interface AmountLabel: UIView {
    NSString *_amount;
    NSString *_unit;
}

- (void)setAmount:(NSString *)amount unit:(NSString *)unit;

@end

@implementation AmountLabel

- (void)drawRect:(CGRect)rect {
    if (!(_amount && _unit)) return;
    
    CGSize amountSize = [_amount sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"PingFangSC-Regular" size:34.f], NSFontAttributeName, nil]];
    CGSize unitSize = [_unit sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"PingFangSC-Regular" size:30.f], NSFontAttributeName, nil]];
    CGFloat paddingX = (rect.size.width - (amountSize.width + 10 + unitSize.width)) / 2;
    [_amount drawInRect:CGRectMake(paddingX,
                                   (rect.size.height - amountSize.height) / 2,
                                   amountSize.width,
                                   amountSize.height)
         withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGBA(51, 51, 51, 1), NSForegroundColorAttributeName, [UIFont fontWithName:@"PingFangSC-Regular" size:34.f], NSFontAttributeName, nil]];
    [_unit drawInRect:CGRectMake(paddingX + amountSize.width + 10,
                                 (rect.size.height - unitSize.height) / 2,
                                 unitSize.width,
                                 unitSize.height)
       withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGBA(51, 51, 51, 1), NSForegroundColorAttributeName, [UIFont fontWithName:@"PingFangSC-Regular" size:30.f], NSFontAttributeName, nil]];
}

- (void)setAmount:(NSString *)amount unit:(NSString *)unit {
    _amount = [amount copy];
    _unit = [unit copy];
    
    [self setNeedsDisplay];
}

@end

@interface RCHPayViewController () {
    RCHPayReq *_req;
    RCHPayInfo *_payInfo;
    void (^_onSubmit)(NSString *, void (^)(NSString *));
    void (^_onClose)(void);
    NSNumberFormatter *_formatter;
}

@end

@implementation RCHPayViewController

- (instancetype)initWithReq:(RCHPayReq *)req
                    payInfo:(RCHPayInfo *)payInfo
                   onSubmit:(void (^)(NSString *, void (^)(NSString *)))onSubmit
                    onClose:(void (^)(void))onClose {
    self = [super init];
    if (self) {
        _req = req;
        _payInfo = payInfo;
        _onSubmit = [onSubmit copy];
        _onClose = [onClose copy];
        
        _formatter = [[NSNumberFormatter alloc] init];
        [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_formatter setPositiveFormat:@"####.##"];
        [_formatter setMaximumFractionDigits:8];
        [_formatter setMinimumFractionDigits:2];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadNavigationBar];
    [self loadPayView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadNavigationBar {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 44, 44);
    [closeButton setImage:RCHIMAGEWITHNAMED(@"btn_pay_close") forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    
    RCHPayNavigationBar *navigationBar = [[RCHPayNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45) title:@"确认支付" leftView:closeButton rightView:nil];
    [self.view addSubview:navigationBar];
}

- (void)loadPayView {
    PayView *payView = [[PayView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - 45)];
    payView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    payView.backgroundColor = [UIColor whiteColor];
    
    AmountLabel *amountLable = [[AmountLabel alloc] initWithFrame:CGRectMake(0, 20, payView.frame.size.width, 36)];
    amountLable.backgroundColor = [UIColor clearColor];
    amountLable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [amountLable setAmount:[_formatter stringFromNumber:_req.amount] unit:_payInfo.official.coinCode];
    [payView addSubview:amountLable];
    
    [payView addSubview:[self cellWithRect:CGRectMake(0, 81, payView.frame.size.width, 52)
                                       name:@"订单信息"
                                      value:_req.comment]];
    
    [payView addSubview:[self cellWithRect:CGRectMake(0, 133, payView.frame.size.width, 52)
                                       name:@"可用余额"
                                      value:(!_payInfo.available || [_req.amount compare:_payInfo.available] == NSOrderedDescending
                                             ? @"余额不足，请充币后重试"
                                             : [_formatter stringFromNumber:_payInfo.available])]];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(15, payView.frame.size.height - 84, payView.frame.size.width - 30, 44);
    submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    submitButton.layer.cornerRadius = 4;
    if (!_payInfo.available || [_req.amount compare:_payInfo.available] == NSOrderedDescending) {
        submitButton.backgroundColor = RGBA(192, 196, 209, 1);
        submitButton.enabled = NO;
    } else {
        submitButton.backgroundColor = RGBA(252, 160, 1, 1);
        [submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    }
    submitButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    submitButton.titleLabel.textColor = [UIColor whiteColor];
    [submitButton setTitle:@"立即支付" forState:UIControlStateNormal];
    [payView addSubview:submitButton];
    
    [self.view addSubview:payView];
}

- (UIView *)cellWithRect:(CGRect)rect name:(NSString *)name value:(NSString *)value {
    UIView *cell = [[UIView alloc] initWithFrame:rect];
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *nameLabel= [[UILabel alloc] initWithFrame:CGRectMake(15,
                                                                  0,
                                                                  (rect.size.width - 30) / 4,
                                                                  rect.size.height)];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    nameLabel.textColor = RGBA(102, 102, 102, 1);
    nameLabel.text = name;
    [cell addSubview:nameLabel];
    
    UILabel *valueLabel= [[UILabel alloc] initWithFrame:CGRectMake((15 + (rect.size.width - 30) / 5),
                                                                   0,
                                                                   (rect.size.width - 30) * 3 / 4,
                                                                   rect.size.height)];
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    valueLabel.textColor = RGBA(51, 51, 51, 1);
    valueLabel.text = value;
    [cell addSubview:valueLabel];
    
    return cell;
}

- (void)close:(UIButton *)button {
    _onClose();
}

- (void)submit:(UIButton *)button {
    RCHPayVerifyViewController *verifyViewController = [[RCHPayVerifyViewController alloc] initWithVerifyInfo:_payInfo.verifyInfo
                                                                                                     onSubmit:_onSubmit
                                                                                                      onClose:_onClose];
    [self.navigationController pushViewController:verifyViewController animated:YES];
}

@end
