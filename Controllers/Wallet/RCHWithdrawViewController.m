//
//  RCHWithdrawViewController.m
//  richcore
//
//  Created by Apple on 2018/6/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWithdrawViewController.h"
#import "RCHWalletsRequest.h"
#import "RCHWithdrawRequest.h"
#import "RCHAuthContrroller.h"
#import "RCHWithdrawSuccessViewController.h"

@interface RCHWithdrawViewController ()
{
    RCHWalletsRequest *_walletRequest;
    RCHWithdrawRequest *_withdrawRequest;
    RCHWallet *_wallet;
    RCHWithdrawInfo *_info;
    RCHWithdrawDraft *_draft;
    
    NSNumberFormatter *_formatter;
    UILabel *_arrivalLabel;
    UIButton *_submitButton;
    UITextField *_addressTextField;
    UITextField *_tagTextField;
    UITextField *_amountTextField;
    UILabel *_errorLabel;
    RCHNavigationController *_verifyController;
}
@end

@implementation RCHWithdrawViewController

+ (void)preLoadWithCoinCode:(NSString *)coinCode
                 onFinished:(void(^)(RCHWithdrawPreLoadError error, RCHWithdrawViewController *controller))onFinished
{
    RCHWithdrawViewController *controller = [[RCHWithdrawViewController alloc] init];
    [controller loadInfoWithCoinCode:coinCode onFinished:^(RCHWithdrawPreLoadError error){
        if (error != RCHWithdrawPreLoadErrorNone) {
            onFinished(error, controller);
        } else {
            [controller loadWalletWithCoinCode:coinCode onFinished:^(RCHWithdrawPreLoadError error){
                onFinished(error, controller);
            }];
        }
    }];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _formatter = [RCHHelper getNumberFormatterFractionDigits:8];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"提币", nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    _draft = [[RCHWithdrawDraft alloc] initWithNeedTag:(_wallet.coin.address != nil)];
    
    [self loadScroll];
    [self loadButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    if (_walletRequest && _walletRequest.currentTask) {
        [_walletRequest.currentTask cancel];
    }
    if (_withdrawRequest && _withdrawRequest.currentTask) {
        [_walletRequest.currentTask cancel];
    }
}

- (void)loadScroll {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kAppOriginY, self.view.frame.size.width, self.view.frame.size.height - kAppOriginY - 74)];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    
    CGFloat height = 30;
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((scrollView.frame.size.width / 2 - 27 - 30), height, 20, 20)];
    iconImageView.backgroundColor = [UIColor clearColor];
    [iconImageView sd_setImageWithURL:[NSURL URLWithString:_wallet.coin.icon]];
    [scrollView addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((scrollView.frame.size.width / 2 - 27), height, scrollView.frame.size.width / 2 + 27 - 15, 20)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", _wallet.coin.code, _wallet.coin.name_en]];
    [title addAttributes:@{
                            NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:17.f],
                            NSForegroundColorAttributeName: RGBA(51, 51, 51, 1)
                            } range:NSMakeRange(0, [_wallet.coin.code length])];
    [title addAttributes:@{
                            NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:13.f],
                            NSForegroundColorAttributeName: RGBA(153, 153, 153, 1)
                            } range:NSMakeRange([_wallet.coin.code length], [title length] - [_wallet.coin.code length])];
    
    [titleLabel setAttributedText:(NSAttributedString *)title];
    [scrollView addSubview:titleLabel];
    
    height = height + 40;
    
    UILabel *availableNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, height, scrollView.frame.size.width - 30, 20)];
    availableNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    availableNameLabel.backgroundColor = [UIColor clearColor];
    availableNameLabel.textAlignment = NSTextAlignmentCenter;
    availableNameLabel.textColor = RGBA(153, 153, 153, 1);
    availableNameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    availableNameLabel.text = @"可用资产";
    [scrollView addSubview:availableNameLabel];
    
    height = height + 20;
    
    UILabel *availableValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, height, scrollView.frame.size.width - 30, 30)];
    availableValueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    availableValueLabel.backgroundColor = [UIColor clearColor];
    availableValueLabel.textAlignment = NSTextAlignmentCenter;
    availableValueLabel.textColor = RGBA(51, 51, 51, 1);
    availableValueLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24.f];
    availableValueLabel.text = [NSString stringWithFormat:@"%@ %@", [_formatter stringFromNumber:_wallet.available], _wallet.coin.code];
    [scrollView addSubview:availableValueLabel];
    
    height = height + 30;
    
    height = height + 30;
    
    UITextField *addressTextField = nil;
    [scrollView addSubview:[self formInputWithFrame:CGRectMake(15, height, scrollView.frame.size.width - 30, 74)
                                              title:[NSString stringWithFormat:@"%@ 提币地址", _wallet.coin.code]
                                      subTitleLabel:nil
                                          rightView:nil
                                          textField:&addressTextField]];
    _addressTextField = addressTextField;
    _addressTextField.placeholder = @"输入或长按粘贴地址";
    height = height + 74;
    
    if (_draft.needTag) {
        height = height + 30;
        UITextField *tagTextField = nil;
        [scrollView addSubview:[self formInputWithFrame:CGRectMake(15, height, scrollView.frame.size.width - 30, 74)
                                                  title:[NSString stringWithFormat:@"%@ 提币Tag", _wallet.coin.code]
                                          subTitleLabel:nil
                                              rightView:nil
                                              textField:&tagTextField]];
        _tagTextField = tagTextField;
        _tagTextField.placeholder = @"输入或长按粘贴Tag";
        height = height + 74;
    }
    
    height = height + 30;
    CGRect amountFormInputFrame = CGRectMake(15, height, scrollView.frame.size.width - 30, 74);
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(amountFormInputFrame.size.width / 4, 0, amountFormInputFrame.size.width * 3 / 4, 20)];
    subTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = kAppOrangeColor;
    subTitleLabel.textAlignment = NSTextAlignmentRight;
    subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    subTitleLabel.text = [NSString stringWithFormat:@"24h提币额度：%@/%@ %@", [_formatter stringFromNumber:_info.was], [_formatter stringFromNumber:_info.max], _wallet.coin.code];
    
    UIButton *totalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    totalButton.frame = CGRectMake(amountFormInputFrame.size.width - 86, 0, 86, 44);
    totalButton.backgroundColor = [UIColor clearColor];
    totalButton.layer.cornerRadius = 4.f;
    totalButton.layer.masksToBounds = YES;
    [totalButton setTitleColor:kAppOrangeColor forState:UIControlStateNormal];
    totalButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [totalButton setTitle:@"全部提币" forState:UIControlStateNormal];
    [totalButton addTarget:self action:@selector(total:) forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *amountTextField = nil;
    [scrollView addSubview:[self formInputWithFrame:amountFormInputFrame
                                              title:@"提币数量"
                                      subTitleLabel:subTitleLabel
                                          rightView:totalButton
                                          textField:&amountTextField]];
    _amountTextField = amountTextField;
    _amountTextField.placeholder = [NSString stringWithFormat:@"最小提币数量 %@", [_formatter stringFromNumber:_info.min]];
    _amountTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _amountTextField.superview.backgroundColor = [UIColor clearColor];
    _amountTextField.superview.layer.borderWidth = .5f;
    _amountTextField.superview.layer.borderColor = kNavigationColor_MB.CGColor;
    height = height + 74;
    
    height = height + 30;
    
    UILabel *feeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, height, (scrollView.frame.size.width - 30) * 2 / 5, 20)];
    feeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    feeLabel.backgroundColor = [UIColor clearColor];
    
    NSString *key = @"手续费：";
    NSMutableAttributedString *fee = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@", key, [_formatter stringFromNumber:_info.fee], _wallet.coin.code]];
    [fee addAttributes:@{
                           NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:14.f],
                           NSForegroundColorAttributeName: kNavigationColor_MB
                           } range:NSMakeRange(0, [key length])];
    [fee addAttributes:@{
                           NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:14.f],
                           NSForegroundColorAttributeName: RGBA(87, 100, 212, 1)
                           } range:NSMakeRange([key length], [fee length] - [key length] - [_wallet.coin.code length])];
    [fee addAttributes:@{
                         NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:14.f],
                         NSForegroundColorAttributeName: kNavigationColor_MB
                         } range:NSMakeRange([fee length] - [_wallet.coin.code length], [_wallet.coin.code length])];
    
    [feeLabel setAttributedText:(NSAttributedString *)fee];
    [scrollView addSubview:feeLabel];
    
    _arrivalLabel = [[UILabel alloc] initWithFrame:CGRectMake((scrollView.frame.size.width - 30) * 2 / 5, height, (scrollView.frame.size.width - 30) * 3 / 5, 20)];
    _arrivalLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    _arrivalLabel.backgroundColor = [UIColor clearColor];
    _arrivalLabel.textAlignment = NSTextAlignmentRight;
    [self setArrivalValue];
    [scrollView addSubview:_arrivalLabel];
    
    height = height + 20;
    
    height = height + 30;
    NSString *note = [NSString stringWithFormat:@"最小提币数量为：%@ %@。\n请务必仔细核对地址标签，否则将造成资产损失并不可找回。\n提币请求申请成功后，请去邮箱点击链接确认本次请求。\n请务必确认电脑及浏览器安全，防止信息被篡改或泄露。", [_formatter stringFromNumber:_info.min], _wallet.coin.code];
    CGSize size = [note sizeForFont:[UIFont fontWithName:@"PingFangSC-Regular" size:13.f]
                               size:CGSizeMake(kScreenWidth - 60, MAXFLOAT)
                               mode:NSLineBreakByWordWrapping];
    
    UIView *noteView = [[UIView alloc] initWithFrame:CGRectMake(15, height, scrollView.frame.size.width - 30, size.height + 30)];
    noteView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    noteView.backgroundColor = RGBA(247, 247, 247, 1);
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, size.width, size.height)];
    noteLabel.backgroundColor = [UIColor clearColor];
    noteLabel.numberOfLines = 0;
    noteLabel.textColor = RGBA(102, 102, 102, 1);
    noteLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.f];
    noteLabel.text = note;
    [noteView addSubview:noteLabel];
    [scrollView addSubview:noteView];
    
    height = height + size.height + 30;
    
    height = height + 10;
    height = height > (kScreenHeight - kAppOriginY - 74) ? height : (kScreenHeight - kAppOriginY - 74);
    
    [scrollView setContentSize:CGSizeMake(kScreenWidth, height)];
    
    _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, scrollView.frame.size.width - 30, 17)];
    _errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _errorLabel.backgroundColor = [UIColor clearColor];
    _errorLabel.textColor = RGBA(180, 57, 63, 1);
    _errorLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
    _errorLabel.hidden = YES;
    [scrollView addSubview:_errorLabel];
    
    [self.view addSubview:scrollView];
}

- (UIView *)formInputWithFrame:(CGRect)frame
                         title:( NSString * _Nonnull )title
                 subTitleLabel:( UILabel * _Nullable )subTitleLabel
                     rightView:( UIView * _Nullable )rightView
                     textField:(UITextField **)textField {
    UIView *formView = [[UIView alloc] initWithFrame:frame];
    formView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    formView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - (subTitleLabel ? subTitleLabel.frame.size.width : 0), 20)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = kNavigationColor_MB;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    titleLabel.text = title;
    [formView addSubview:titleLabel];
    
    if (subTitleLabel) {
        [formView addSubview:subTitleLabel];
    }
    
    UIView *textFieldView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, frame.size.width, 44)];
    textFieldView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textFieldView.backgroundColor = RGBA(235, 241, 245, 1);
    textFieldView.layer.cornerRadius = 4.f;
    textFieldView.layer.masksToBounds = YES;
    
    UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 12, frame.size.width - 30 - (rightView ? rightView.frame.size.width : 0), 20)];
    theTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    theTextField.backgroundColor = [UIColor clearColor];
    theTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    theTextField.adjustsFontSizeToFitWidth = YES;
    theTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    theTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    theTextField.textColor = RGBA(87, 100, 212, 1);
    [theTextField addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    *textField = theTextField;
    [textFieldView addSubview:theTextField];
    
    if (rightView) {
        [textFieldView addSubview:rightView];
    }
    
    [formView addSubview:textFieldView];
    return formView;
}

- (void)textFiledDidChange:(UITextField *)textField {
    if (textField == _addressTextField) {
        _draft.address = _addressTextField.text;
    } else if (textField == _tagTextField) {
        _draft.tag = _tagTextField.text;
    } else if (textField == _amountTextField) {
        [self amountChanged];
    }
    [self setSubmitButtonState];
    _errorLabel.hidden = YES;
}

- (void)amountChanged {
    if (_amountTextField.text && [_amountTextField.text length] > 0) {
        _amountTextField.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.f];
        _amountTextField.textColor = kNavigationColor_MB;
    } else {
        _amountTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        _amountTextField.textColor = RGBA(87, 100, 212, 1);
    }
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:_amountTextField.text];
    if (amount && [amount compare:[NSDecimalNumber notANumber]] != NSOrderedSame && [amount compare:[NSDecimalNumber zero]] != NSOrderedAscending) {
        _draft.amount = amount;
    } else {
        _draft.amount = nil;
    }
    [self setArrivalValue];
}

- (void)total:(UIButton *)button {
    _amountTextField.text = [_formatter stringFromNumber:_wallet.available];
    
    [self amountChanged];
    [self setSubmitButtonState];
    _errorLabel.hidden = YES;
}

- (void)loadButton {
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 74, self.view.frame.size.width, 74)];
    buttonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    buttonView.backgroundColor = [UIColor whiteColor];
    
    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitButton.frame = CGRectMake((buttonView.frame.size.width - 345) / 2, (buttonView.frame.size.height - 44) / 2, 345, 44);
    _submitButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self setSubmitButtonState];
    _submitButton.layer.cornerRadius = 4.f;
    _submitButton.layer.masksToBounds = YES;
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submitButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    [_submitButton setTitle:@"提币" forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:_submitButton];
    [self.view addSubview:buttonView];
}

- (void)setSubmitButtonState {
    [_submitButton setBackgroundColor:(_draft && _draft.valid ? kAppOrangeColor : kPlaceholderColor) forState:UIControlStateNormal];
    [_submitButton setEnabled:(_draft && _draft.valid)];
}

- (void)setArrivalValue {
    NSString *key = @"实际到账：";
    NSString *value = _draft && _draft.amount != nil && [_draft.amount compare:_info.fee] == NSOrderedDescending ? [_formatter stringFromNumber:[_draft.amount decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[_info.fee decimalValue]]]] : @"0";
    NSMutableAttributedString *arrival = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@", key, value, _wallet.coin.code]];
    [arrival addAttributes:@{
                             NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:14.f],
                             NSForegroundColorAttributeName: kNavigationColor_MB
                             } range:NSMakeRange(0, [key length])];
    [arrival addAttributes:@{
                             NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:14.f],
                             NSForegroundColorAttributeName: RGBA(87, 100, 212, 1)
                             } range:NSMakeRange([key length], [arrival length] - [key length] - [_wallet.coin.code length])];
    [arrival addAttributes:@{
                             NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:14.f],
                             NSForegroundColorAttributeName: kNavigationColor_MB
                             } range:NSMakeRange([arrival length] - [_wallet.coin.code length], [_wallet.coin.code length])];
    
    [_arrivalLabel setAttributedText:(NSAttributedString *)arrival];
}

- (void)loadInfoWithCoinCode:(NSString *)coinCode onFinished:( void(^ _Nonnull )( RCHWithdrawPreLoadError error))onFinished
{
    if ([[self withdrawRequest] currentTask]) {
        [[[self withdrawRequest] currentTask] cancel];
    }
    [[self withdrawRequest] getInfoWithCoinCode:coinCode completion:^(NSObject *response) {
        if ([response isKindOfClass:[RCHWithdrawInfo class]]) {
            if ([(RCHWithdrawInfo *)response verifyType] == RCHWithdrawVerifyTypeNone) {
                onFinished(RCHWithdrawPreLoadErrorVerify);
            } else {
                self->_info = (RCHWithdrawInfo *)response;
                onFinished(RCHWithdrawPreLoadErrorNone);
            }
        } else {
            onFinished(RCHWithdrawPreLoadErrorOther);
        }
    }];
}

- (void)loadWalletWithCoinCode:(NSString *)coinCode onFinished:( void(^ _Nonnull )( RCHWithdrawPreLoadError error))onFinished
{
    if ([[self walletRequest] currentTask]) {
        [[[self walletRequest] currentTask] cancel];
    }
    [[self walletRequest] walletWithCoinCode:coinCode completion:^(NSObject *response) {
        if ([response isKindOfClass:[RCHWallet class]]) {
            self->_wallet = (RCHWallet *)response;
            onFinished(RCHWithdrawPreLoadErrorNone);
        } else {
            onFinished(RCHWithdrawPreLoadErrorOther);
        }
    }];
}

- (void)submit:(UIButton *)button
{
    [self submitWithVerifyMethod:nil verifyCode:nil];
}

- (void)submitWithVerifyMethod:(NSString *)verifyMethod verifyCode:(NSString *)verifyCode {
    if (!(_draft && _draft.valid)) return;
    
    BOOL checkOnly = verifyMethod == nil || verifyCode == nil;
    
    if ([[self withdrawRequest] currentTask]) {
        [[[self withdrawRequest] currentTask] cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [[self withdrawRequest] withdraw:_draft
                            coinCode:_wallet.coin.code
                           checkOnly:checkOnly
                        verifyMethod:verifyMethod
                          verifyCode:verifyCode
                          completion:^(NSObject *response) {
                              [MBProgressHUD hideHUDForView:self.view animated:NO];
                              if (response == nil) {
                                  if (checkOnly) {
                                      [self showVerify];
                                  } else {
                                      RCHWithdrawSuccessViewController *controller = [[RCHWithdrawSuccessViewController alloc] init];
                                      [self.navigationController pushViewController:controller animated:YES];
                                  }
                              } else {
                                  if (((WDBaseResponse *)response).statusCode == 403) {
                                      NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                      if ([@[@"ADDRESS", @"MIN", @"MAX", @"NO_ENOUGH_BALANCE"] containsObject:errorInfo]) {
                                          [self showErrorWithMessage:errorInfo];
                                      } else if ([errorInfo isEqualToString:@"VERIFY_CODE"]) {
                                          [MBProgressHUD showError:kVerifyCodeError ToView:self.view];
                                      }
                                  } else {
                                      [MBProgressHUD showError:kDataError ToView:self.view];
                                  }
                              }
                          }];
}

- (void)showVerify {
    if (_verifyController != nil) return;
    if (_info.verifyType == RCHWithdrawVerifyTypeNone) return;
    
    void (^ _Nonnull completion)(RCHSecondAuth, NSString *) = ^(RCHSecondAuth verifyMethod, NSString *verifyCode) {
        if (self->_verifyController) {
            [self->_verifyController dismissViewControllerAnimated:YES completion:^() {
                [self submitWithVerifyMethod:(verifyMethod == RCHSecondAuthTypeMobie ? @"mobile" : @"google")
                                  verifyCode:verifyCode];
            }];
            self->_verifyController = nil;
        }
    };
    
    RCHNavBaseViewController *controller = nil;
    
    if (_info.verifyType == RCHWithdrawVerifyTypeAll) {
        controller = [[RCHAuthContrroller alloc] initWithCompletion:completion];
    } else {
        controller = [[RCHSecondAuthController alloc] initWithSecondAuthType:(_info.verifyType == RCHWithdrawVerifyTypeMobile ? RCHSecondAuthTypeMobie : RCHSecondAuthTypeGoogle) completion:completion];
    }
    _verifyController = [[RCHNavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:_verifyController animated:YES completion:nil];
    
    UIButton *leftView = [UIButton buttonWithType:UIButtonTypeCustom];
    leftView.frame = CGRectMake(0, 0, 50, 44);
    leftView.backgroundColor = [UIColor clearColor];
    leftView.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [leftView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftView setTitle:@"关闭" forState:UIControlStateNormal];
    [leftView addTarget:self action:@selector(closeVerify:) forControlEvents:UIControlEventTouchUpInside];
    [controller.k_navgationBar setLeftView:leftView];
}

- (void)closeVerify:(UIButton *)button {
    if (_verifyController) {
        [_verifyController dismissViewControllerAnimated:YES completion:nil];
        _verifyController = nil;
    }
}

- (void)showErrorWithMessage:(NSString *)errorMessage
{
    if ([errorMessage isEqualToString:@"ADDRESS"]) {
        _errorLabel.frame = CGRectMake(_errorLabel.frame.origin.x, _draft.needTag ? 333 : 229, _errorLabel.frame.size.width, _errorLabel.frame.size.height);
        _errorLabel.text = [NSString stringWithFormat:@"无效的地址%@，请核对地址%@", _draft.needTag ? @"或Tag" : @"", _draft.needTag ? @"或Tag" : @""];
    } else {
        _errorLabel.frame = CGRectMake(_errorLabel.frame.origin.x, _draft.needTag ? 437 : 333, _errorLabel.frame.size.width, _errorLabel.frame.size.height);
        if ([errorMessage isEqualToString:@"MIN"]) {
            _errorLabel.text = [NSString stringWithFormat:@"不能小于最小提币数量 %@", [_formatter stringFromNumber:_info.min]];
        } else if ([errorMessage isEqualToString:@"MAX"]) {
            _errorLabel.text = [NSString stringWithFormat:@"不能大于24h提现额度 %@", [_formatter stringFromNumber:_info.max]];
        } else {
            _errorLabel.text = @"余额不足";
        }
    }
    _errorLabel.hidden = NO;
}

- (RCHWalletsRequest *)walletRequest {
    if (!_walletRequest) {
        _walletRequest = [[RCHWalletsRequest alloc] init];
    }
    return _walletRequest;
}

- (RCHWithdrawRequest *)withdrawRequest {
    if (!_withdrawRequest) {
        _withdrawRequest = [[RCHWithdrawRequest alloc] init];
    }
    return _withdrawRequest;
}

@end


@implementation RCHWithdrawDenyAlert

+ (void)showInView:(UIView *)view content:(NSString *)content
{
    RCHWithdrawDenyAlert *alert = [[RCHWithdrawDenyAlert alloc] initWithFrame:view.bounds content:content];
    alert.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:alert];
}

- (id)initWithFrame:(CGRect)frame content:(NSString *)content {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBA(0, 0, 0, .3f);
        
        [self loadWithContent:content];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)loadWithContent:(NSString *)content
{
    CGSize contentSize = [content sizeForFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.f] size:CGSizeMake(230, MAXFLOAT) mode:NSLineBreakByWordWrapping];
    CGFloat height = 201 + contentSize.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 300) / 2, (self.frame.size.height - height) / 2, 300, height)];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 4.f;
    view.layer.masksToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.frame.size.width - 60) / 2, 40, 60, 52)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.image = RCHIMAGEWITHNAMED(@"pic_bell");
    [view addSubview:imageView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((view.frame.size.width - 230) / 2, 107, 230, contentSize.height)];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = RGBA(51, 51, 51, 1);
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = content;
    [view addSubview:textLabel];
    
    UIButton *knownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    knownButton.frame = CGRectMake((view.frame.size.width - 250) / 2, (107 + contentSize.height + 25), 250, 44);
    knownButton.layer.cornerRadius = 4.f;
    knownButton.layer.masksToBounds = YES;
    [knownButton setBackgroundColor:kAppOrangeColor forState:UIControlStateNormal];
    knownButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    [knownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [knownButton setTitle:@"我知道了" forState:UIControlStateNormal];
    [knownButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:knownButton];
    
    [self addSubview:view];
}

- (void)close:(id)selector
{
    [self removeFromSuperview];
}

@end
