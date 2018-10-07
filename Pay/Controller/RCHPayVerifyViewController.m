//
//  RCHPayVerifyViewController.m
//  richcore
//
//  Created by Apple on 2018/6/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHPayVerifyViewController.h"
#import "RCHPayNavigationBar.h"
#import "RCHPayRequest.h"

@interface RCHPayVerifyViewController ()<UITextFieldDelegate>
{
    RCHPayVerifyInfo *_verifyInfo;
    void (^_onSubmit)(NSString *, void (^)(NSString *));
    void (^_onClose)(void);
    
    UIView *_verifyView;
    UITextField *_codeTextField;
    UIButton *_fetchButton;
    NSUInteger _counter;
    RCHPayRequest *_payRequest;
}
@end

@implementation RCHPayVerifyViewController

- (instancetype)initWithVerifyInfo:(RCHPayVerifyInfo *)verifyInfo
                          onSubmit:(void (^)(NSString *, void (^)(NSString *)))onSubmit
                           onClose:(void (^)(void))onClose {
    self = [super init];
    if (self) {
        _verifyInfo = verifyInfo;
        _onSubmit = [onSubmit copy];
        _onClose = [onClose copy];
        _counter = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadNavigationBar];
    [self loadVerifyView];
    
    if (_verifyInfo.method == RCHPayVerifyMethodGoogle) {
        [_codeTextField becomeFirstResponder];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadNavigationBar {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:RCHIMAGEWITHNAMED(@"btn_pay_back") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    RCHPayNavigationBar *navigationBar = [[RCHPayNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45) title:@"请输入验证码" leftView:backButton rightView:nil];
    [self.view addSubview:navigationBar];
}

- (void)loadVerifyView {
    _verifyView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - 45)];
    _verifyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _verifyView.backgroundColor = [UIColor whiteColor];
    
    UILabel *identifierLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, _verifyView.frame.size.width - 60, 52)];
    identifierLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    identifierLabel.backgroundColor = [UIColor clearColor];
    identifierLabel.textColor = RGBA(77, 90, 134, 1);
    identifierLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:(_verifyInfo.method == RCHPayVerifyMethodGoogle ? 15.f : 16.f)];
    identifierLabel.text = (_verifyInfo.method == RCHPayVerifyMethodGoogle ? @"谷歌验证码" : _verifyInfo.identifier);
    [_verifyView addSubview:identifierLabel];
    
    UIView *codeBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(30, 57, _verifyView.frame.size.width - 60 - (_verifyInfo.method == RCHPayVerifyMethodGoogle ? 0.f : 95.f), 44)];
    codeBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    codeBackgroundView.backgroundColor = [UIColor clearColor];
    codeBackgroundView.layer.cornerRadius = 4;
    codeBackgroundView.layer.borderColor = RGBA(77, 90, 134, 1).CGColor;
    codeBackgroundView.layer.borderWidth = .5f;
    codeBackgroundView.layer.masksToBounds = YES;
    
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 12, codeBackgroundView.frame.size.width - 32, codeBackgroundView.frame.size.height - 24)];
    _codeTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;;
    _codeTextField.backgroundColor = [UIColor clearColor];
    _codeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _codeTextField.adjustsFontSizeToFitWidth = YES;
    _codeTextField.clearButtonMode = UITextFieldViewModeNever;
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.placeholder = @"输入验证码";
    _codeTextField.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.f];
    _codeTextField.textAlignment = NSTextAlignmentLeft;
    _codeTextField.textColor = RGBA(77.0f, 90.0f, 134.0f, 1.0f);
    _codeTextField.delegate = self;
    _codeTextField.keyboardToolbar.frame = CGRectZero;
    _codeTextField.keyboardToolbar.clipsToBounds = YES;
    _codeTextField.keyboardToolbar.hidden = YES;
    [_codeTextField addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    [codeBackgroundView addSubview:_codeTextField];
    [_verifyView addSubview:codeBackgroundView];
    
    if (_verifyInfo.method != RCHPayVerifyMethodGoogle) {
        _fetchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fetchButton.frame = CGRectMake(_verifyView.frame.size.width - 30 - 85, 57, 85, 44);
        _fetchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _fetchButton.backgroundColor = [UIColor clearColor];
        _fetchButton.layer.cornerRadius = 4.f;
        _fetchButton.layer.borderColor = RGBA(252, 160, 1, 1).CGColor;
        _fetchButton.layer.borderWidth = .5f;
        _fetchButton.layer.masksToBounds = YES;
        _fetchButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        [_fetchButton setTitleColor:RGBA(252, 160, 1, 1) forState:UIControlStateNormal];
        [_fetchButton addTarget:self action:@selector(sendVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
        [self setFetchButtonText];
        [_verifyView addSubview:_fetchButton];
    }
    
    [self.view addSubview:_verifyView];
}

- (void)back:(UIButton *)button {
    if (!_codeTextField.userInteractionEnabled) return;
    [_codeTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setFetchButtonText {
    if (!_fetchButton) return;
    if (_counter > 0) {
        [_fetchButton setUserInteractionEnabled:NO];
        [_fetchButton setTitle:[NSString stringWithFormat:@"%lds", _counter] forState:UIControlStateNormal];
    } else {
        [_fetchButton setUserInteractionEnabled:YES];
        [_fetchButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}

- (void)sendVerifyCode:(UIButton *)button {
    if (!_payRequest) {
        _payRequest = [[RCHPayRequest alloc] init];
    }
    if (_payRequest.currentTask) {
        [_payRequest.currentTask cancel];
    }
    
    [_fetchButton setUserInteractionEnabled:NO];
    [_payRequest sendVerifyCodeWithMethod:_verifyInfo.method completion:^(NSObject *resp) {
        if (resp == nil) {
            self->_counter = 60;
            dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(timer, ^{
                self->_counter -= 1;
                if (self->_counter == 0) {
                    dispatch_source_cancel(timer);
                }
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self setFetchButtonText];
                });
            });
            dispatch_resume(timer);
            [self->_codeTextField becomeFirstResponder];
        } else {
            [self->_fetchButton setUserInteractionEnabled:YES];
            [MBProgressHUD showError:@"出错了" ToView:self.view];
        }
    }];
}

- (void)submit {
    [_codeTextField resignFirstResponder];
    [_codeTextField setUserInteractionEnabled:NO];
    
    [MBProgressHUD showLoadToView:_verifyView];
    _onSubmit(_codeTextField.text, ^(NSString *error) {
        [MBProgressHUD hideHUDForView:self->_verifyView animated:NO];
        if (error != nil && [error isEqualToString:@"VERIFY_CODE"]) {
            [MBProgressHUD showInfo:@"验证码错误" ToView:self->_verifyView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self->_codeTextField setUserInteractionEnabled:YES];
                [self->_codeTextField setText:nil];
                [self->_codeTextField becomeFirstResponder];
            });
        } else {
            [self displayResult:(error != nil)];
        }
    });
}

- (void)displayResult:(BOOL)error {
    [_verifyView removeAllSubviews];
    
    UIView *resultView = [[UIView alloc] initWithFrame:CGRectMake((_verifyView.frame.size.width - 140) / 2, (_verifyView.frame.size.height - 140) / 2, 140, 140)];
    resultView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    resultView.backgroundColor = RGBA(152, 157, 173, 1);
    resultView.layer.cornerRadius = 10.f;
    resultView.layer.masksToBounds = YES;
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(47, 30, 46, 46)];
    [icon setImage:RCHIMAGEWITHNAMED(error ? @"ico_pay_fail" : @"ico_pay_success")];
    [resultView addSubview:icon];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 86, 140, 22)];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = (error ? @"支付失败" : @"支付成功");
    [resultView addSubview:title];
    
    [_verifyView addSubview:resultView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_onClose();
    });
}

#pragma market - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

- (void)textFiledDidChange:(UITextField *)textField {
    if (textField.text && [textField.text length] == 6) {
        [self submit];
    }
}

@end
