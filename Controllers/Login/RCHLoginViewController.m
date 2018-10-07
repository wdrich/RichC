//
//  RCHLoginViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHLoginViewController.h"
#import "RCHRegisterViewController.h"
#import <GT3Captcha/GT3Captcha.h>
#import "RCHAuthContrroller.h"
#import "RCHSecondAuthController.h"
#import "RCHCheckEmailController.h"


#import "RCHLoginRequest.h"
#import "RCHMemberRequest.h"

#import "RCHAlertView.h"

#define kCellHeight 44.0f

@interface RCHLoginViewController () <UIGestureRecognizerDelegate, GT3CaptchaManagerDelegate>
{
    UITextField *_phoneTextField;
    UITextField *_passwordTextField;
    UIView *_footerView;
    UILabel *_loginLabel;
    UIButton *_eyeButton;
    
    BOOL    _isShowErrorInfo;
    BOOL    _isRegisterSuccess;
}

@property (nonatomic, strong) RCHLoginRequest *loginRequest;
@property (nonatomic, strong) RCHMemberRequest *memberRequest;
@property (nonatomic, strong) GT3CaptchaButton *captchaButton;

@end

@implementation RCHLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.title = @"登录";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSuccessfull:) name:kRegisterDidSuccessNotification object:nil];
    
    [self initCustomView];
    [self createCaptchaButton];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isRegisterSuccess) {
        _isRegisterSuccess = NO;
        NSString *username = [RCHHelper valueForKey:kCurrentRememberName];
        if (!username) {
            username = @"";
        }
        _phoneTextField.text = username;
        [MBProgressHUD showSuccess:NSLocalizedString(@"注册成功，请登录",nil) ToView:self.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - CustomFunction

- (void)initCustomView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    
    CGFloat bottom = [self createHeaderView];
    
    _footerView = [self createFooterViewWithFrame:(CGRect){{0.0f, bottom + 20.0f}, {kMainScreenWidth, 150.0f}}];
    [self.view addSubview:_footerView];
    [self.view sendSubviewToBack:_footerView];
}


- (CGFloat)createHeaderView
{
    CGFloat space = 15.0f;
    CGFloat width = 75.0f;
    CGFloat lineWidth = [RCHHelper retinaFloat:1.0f];
    
    UIView *backView1 = [[UIView alloc] initWithFrame:(CGRect){{30.0f, 25.0f + kAppOriginY}, {self.view.frame.size.width - 60.0f, kCellHeight}}];
    backView1.backgroundColor = [UIColor whiteColor];
    backView1.layer.cornerRadius = 4.0f;
    backView1.layer.borderWidth = lineWidth;
    backView1.layer.borderColor = [kFontLineGrayColor CGColor];
    backView1.layer.masksToBounds = YES;
    [self.view addSubview:backView1];
    
    NSString *title;
    NSString *placeholder;
    NSInteger keyboardType;
    title = NSLocalizedString(@"邮箱",nil);
    placeholder = NSLocalizedString(@"请使用邮箱账号登录",nil);
    keyboardType = UIKeyboardTypeASCIICapable;
    
    UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView1.height}}];
    titleLabel1.userInteractionEnabled = YES;
    titleLabel1.backgroundColor = [UIColor whiteColor];
    titleLabel1.adjustsFontSizeToFitWidth = YES;
    titleLabel1.font = [UIFont systemFontOfSize:14.0f];
    titleLabel1.text = title;
    titleLabel1.textAlignment = NSTextAlignmentLeft;
    titleLabel1.textColor = kTextColor_MB;
    [backView1 addSubview:titleLabel1];
    
    NSString *username = [RCHHelper valueForKey:kCurrentRememberName];
    if (!username) {
        username = @"";
    }
    
    _phoneTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView1.width - width, backView1.height}}];
    _phoneTextField.backgroundColor = [UIColor whiteColor];
    _phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _phoneTextField.adjustsFontSizeToFitWidth = YES;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _phoneTextField.keyboardType = keyboardType;
    _phoneTextField.placeholder = placeholder;
    _phoneTextField.font = [UIFont systemFontOfSize:14.0f];
    _phoneTextField.textAlignment = NSTextAlignmentLeft;
    _phoneTextField.textColor = kTextColor_MB;
    _phoneTextField.tag = 1000;
    _phoneTextField.text = username;
    [_phoneTextField setDelegate:self];
    _phoneTextField.returnKeyType = UIReturnKeyNext;
    [backView1 addSubview:_phoneTextField];
    
    UIView *backView3 = [[UIView alloc] initWithFrame:(CGRect){{backView1.left, backView1.bottom + space}, backView1.frame.size}];
    backView3.backgroundColor = [UIColor whiteColor];
    backView3.layer.cornerRadius =2.0f;
    backView3.layer.borderWidth = lineWidth;
    backView3.layer.borderColor = [kFontLineGrayColor CGColor];
    backView3.layer.masksToBounds = YES;
    [self.view addSubview:backView3];
    
    UILabel *titleLabel3 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView3.height}}];
    titleLabel3.backgroundColor = [UIColor whiteColor];
    titleLabel3.adjustsFontSizeToFitWidth = YES;
    titleLabel3.font = [UIFont systemFontOfSize:14.0f];
    titleLabel3.text = NSLocalizedString(@"密码",nil);
    titleLabel3.textAlignment = NSTextAlignmentLeft;
    titleLabel3.textColor = kTextColor_MB;
    [backView3 addSubview:titleLabel3];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView3.width - width - backView3.height, backView3.height}}];
    _passwordTextField.backgroundColor = [UIColor clearColor];
    _passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordTextField.adjustsFontSizeToFitWidth = YES;
    _passwordTextField.borderStyle = UITextBorderStyleNone;
    _passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.placeholder = NSLocalizedString(@"请输入密码",nil);
    _passwordTextField.font = [UIFont systemFontOfSize:14.0f];
    _passwordTextField.textAlignment = NSTextAlignmentLeft;
    _passwordTextField.textColor = kTextColor_MB;
    _passwordTextField.tag = 1002;
    _passwordTextField.returnKeyType = UIReturnKeyDone;
    [_passwordTextField setDelegate:self];
    [backView3 addSubview:_passwordTextField];
    
    _eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _eyeButton.frame = CGRectMake(backView3.width - backView3.height, 0, backView3.height, backView3.height);
    _eyeButton.backgroundColor = [UIColor clearColor];
    [_eyeButton setImage:RCHIMAGEWITHNAMED(@"password_hide") forState:UIControlStateNormal];
    [_eyeButton addTarget:self action:@selector(eyeChange:) forControlEvents:UIControlEventTouchUpInside];
    [backView3 addSubview:_eyeButton];
    
    CGFloat bottom = backView3.bottom;
    
    return bottom;
}

- (void)eyeChange:(UIButton *)btn {
    _passwordTextField.secureTextEntry = !_passwordTextField.secureTextEntry;
    if (_passwordTextField.secureTextEntry) {
        [_eyeButton setImage:RCHIMAGEWITHNAMED(@"password_hide") forState:UIControlStateNormal];
    } else {
        [_eyeButton setImage:RCHIMAGEWITHNAMED(@"password_view") forState:UIControlStateNormal];
    }
}

- (UIView *)createFooterViewWithFrame:(CGRect)frame
{
    UIView *footView = [[UIView alloc] initWithFrame:frame];
    [footView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat left = 30.0f;
    CGSize size = (CGSize){frame.size.width - left * 2, kCellHeight};
    _loginLabel = [[UILabel alloc] initWithFrame:(CGRect){{left, 0.0f}, size}];
    _loginLabel.backgroundColor = kPlaceholderColor;
    _loginLabel.layer.cornerRadius = 4.0f;
    _loginLabel.userInteractionEnabled = YES;
    _loginLabel.layer.masksToBounds = YES;
    _loginLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _loginLabel.textAlignment = NSTextAlignmentCenter;
    _loginLabel.text = NSLocalizedString(@"登录",nil);
    _loginLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_loginLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginButtonClicked:)];
    tapGesture.delegate = self;
    [_loginLabel addGestureRecognizer:tapGesture];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.frame = (CGRect){{0.0f, 0.0f}, {200.0f, 20.0f}};
    resetButton.backgroundColor = [UIColor clearColor];
    [resetButton setTitle:NSLocalizedString(@"忘记密码？",nil) forState:UIControlStateNormal];
    [resetButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [resetButton setTitleColor:kLoginButtonColor forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [resetButton sizeToFit];
    [footView addSubview:resetButton];
    [resetButton sizeToFit];
    resetButton.frame = (CGRect){{_loginLabel.right - resetButton.width, _loginLabel.bottom + 20.0f - 2.0f}, {resetButton.width, 20.0f}};
    return footView;
}

- (void)createCaptchaButton {
    //添加验证按钮到父视图上
    self.captchaButton.center = CGPointMake(self.view.center.x, self.view.center.y + 76);
    //推荐直接开启验证
    [self.captchaButton startCaptcha];
    [self.view addSubview:self.captchaButton];
    self.captchaButton.hidden = YES;
}

- (GT3CaptchaButton *)captchaButton {
    if (!_captchaButton) {
        //创建验证管理器实例
        GT3CaptchaManager *captchaManager = [[GT3CaptchaManager alloc] initWithAPI1:api_1 API2:api_2 timeout:5.0];
        captchaManager.delegate = self;
        captchaManager.maskColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];

        
        //创建验证视图的实例
        _captchaButton = [[GT3CaptchaButton alloc] initWithFrame:CGRectMake(0, 0, 260, 40) captchaManager:captchaManager];
    }
    return _captchaButton;
}

- (BOOL)checkAvailable
{
    if(_passwordTextField.text == nil
       || _phoneTextField.text == nil
       || (_passwordTextField.text && ([_passwordTextField.text length] < 2))
       || (_phoneTextField.text && ([_phoneTextField.text length] < 2))){
        _loginLabel.backgroundColor = kPlaceholderColor;
        return NO;
    } else {
        _loginLabel.backgroundColor = kAppOrangeColor;
        return YES;
    }
}

- (void)login
{
    [RCHHelper setValue:nil forKey:kCurrentAuthType];
    [RCHHelper setValue:[NSNumber numberWithInteger:0] forKey:kCurrentGoogleLoginId];
    [RCHHelper setValue:[NSNumber numberWithBool:NO] forKey:kCurrentUserGoogleAuth];
    NSString *name = [_phoneTextField.text lowercaseString];
    NSString *password = _passwordTextField.text;
    NSMutableDictionary *user = [NSMutableDictionary dictionary];
    [user setObject:name forKey:@"_username"];
    [user setObject:password forKey:@"_password"];
    
    RCHWeak(self);
    
    if (self.loginRequest.currentTask) {
        [self.loginRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [self.loginRequest login:^(NSError *error, WDBaseResponse *response) {
        if (error) {
            [MBProgressHUD hideHUDForView:self.view];
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", errorInfo);
            if (errorInfo) {
                NSDictionary *resultDictionary = [errorInfo objectFromJSONString];
                NSInteger count = [[resultDictionary objectForKey:@"message"] integerValue];
                
                NSString *message = @"";
                if (count == 0) {
                    message = @"登录过于频繁，请您2小时后再尝试登录";
                } else {
                    message = [NSString stringWithFormat:@"邮箱或密码错误，您还有%ld次机会", (long)count];
                }
                [MBProgressHUD showError:message ToView:self.view];
            } else {
                NSInteger code = ((WDBaseResponse *)response).statusCode;
                NSString *url = ((WDBaseResponse *)response).urlString;
                [RCHHelper showRequestErrorCode:code url:url];
            }

            return;
        }
        
        NSString *cookie = [response.headers objectForKey:@"Set-Cookie"];
        [RCHHelper setValue:cookie forKey:kCurrentCookie];

        NSString *loginID = [response.headers objectForKey:@"Login-ID"];
        if ([loginID integerValue] > 0) {
            [RCHHelper setValue:[NSNumber numberWithInteger:[loginID integerValue]] forKey:kCurrentGoogleLoginId];
        }
        
        NSString *VerifyType = [response.headers objectForKey:@"Verify-Type"];
        if (VerifyType) {
            [RCHHelper setValue:VerifyType forKey:kCurrentAuthType];
        }
        
        NSInteger loginId = [[RCHHelper valueForKey:kCurrentGoogleLoginId] integerValue];
        if (loginId > 0) {
            [MBProgressHUD hideHUDForView:self.view];
            NSString *VerifyType = [RCHHelper valueForKey:kCurrentAuthType];
            if ([VerifyType isEqualToString:@"all" ]) {
                [weakself gotoAllAuth];
            } else if ([VerifyType isEqualToString:@"mobile" ]) {
                [weakself gotoMobileAuth];
            } else if ([VerifyType isEqualToString:@"google" ]) {
                [weakself gotoGoogleAuth];
            } else {
                [weakself gotoAllAuth];
            }
        } else {
            [weakself getMemberInfo];
        }
        
    } user:user];
}

- (void)gotoAllAuth
{
    RCHAuthContrroller *viewcontroller = [[RCHAuthContrroller alloc] init];
    [self.navigationController pushViewController:viewcontroller animated:YES];
}


- (void)gotoMobileAuth
{
    RCHSecondAuthController *viewcontroller = [[RCHSecondAuthController alloc] initWithSecondAuthType:RCHSecondAuthTypeMobie];
    [self.navigationController pushViewController:viewcontroller animated:YES];
}

- (void)gotoGoogleAuth
{
    RCHSecondAuthController *viewcontroller = [[RCHSecondAuthController alloc] initWithSecondAuthType:RCHSecondAuthTypeGoogle];
    [self.navigationController pushViewController:viewcontroller animated:YES];
}

- (void)getMemberInfo
{
    RCHWeak(self);
//    RCHWeak(_hub);
    if (weakself.memberRequest.currentTask) {
        [weakself.memberRequest.currentTask cancel];
    }
    
    [weakself.memberRequest member:^(NSObject *response) {
//        [weak_hub hideAnimated:YES];
        [MBProgressHUD hideHUDForView:self.view];
        if ([response isKindOfClass:[RCHMember class]]) {
            RCHMember *member = (RCHMember *)response;
            [RCHHelper saveUserInfo:member];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginDidSuccessNotification object:nil];
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    }];
}



#pragma mark -
#pragma mark - ButtonClicked

- (void)registerButtonClicked:(id)sender
{
    [_phoneTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)loginButtonClicked:(id)sender
{
    if (![self checkAvailable]) {
        return;
    }
    
    if(_phoneTextField.text == nil
       || _passwordTextField.text == nil
       || (_phoneTextField.text && [[_phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
       || (_passwordTextField.text && [[_passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])) {
        [MBProgressHUD showError:@"用户名和密码都不能为空" ToView:self.view];

        return;
    }
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self.captchaButton startCaptcha];
    _isShowErrorInfo = YES;
    
}

- (void)resetButtonClicked:(id)sender
{
    RCHCheckEmailController *viewcontroller = [[RCHCheckEmailController alloc] init];
    [self.navigationController pushViewController:viewcontroller animated:YES];
}

#pragma mark -
#pragma mark - OverWrite


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    [_phoneTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    [self checkAvailable];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkAvailable];
}

#pragma mark -
#pragma mark -  NavigationDataSource

- (UIImage *)RCHNavigationBarLeftButtonImage:(UIButton *)leftButton navigationBar:(RCHNavigationBar *)navigationBar
{
    [self customButtonInfo:leftButton title:NSLocalizedString(@"取消",nil)];
    return nil;
}

- (UIImage *)RCHNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(RCHNavigationBar *)navigationBar
{
    [self customButtonInfo:rightButton title:NSLocalizedString(@"注册",nil)];
    return nil;
}

#pragma mark -
#pragma mark -  NavigationDelegate

-(void)leftButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar {
    NSLog(@"%s", __func__);
    
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DismissModalViewControllerAnimated(weakself, YES);
    });
}

-(void)rightButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar {
    NSLog(@"%s", __func__);
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RCHRegisterViewController *registerViewController = [[RCHRegisterViewController alloc] init];
        [weakself.navigationController pushViewController:registerViewController animated:YES];
    });
}


#pragma mark -
#pragma mark - GT3CaptchaManagerDelegate

- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
    [MBProgressHUD hideHUDForView:self.view];
    if (error.code == -999) {
        // 请求被意外中断, 一般由用户进行取消操作导致, 可忽略错误
    }
    else if (error.code == -10) {
        // 预判断时被封禁, 不会再进行图形验证
    }
    else if (error.code == -20) {
        // 尝试过多
    }
    else if (error.code == -1001) {
        if (_isShowErrorInfo) {
            [MBProgressHUD showError:@"图形验证失败，请重试" ToView:self.view];
            _isShowErrorInfo = NO;
        }
    }
    else {
        // 网络问题或解析失败, 更多错误码参考开发文档
    }
    
}

- (void)gtCaptchaUserDidCloseGTView:(GT3CaptchaManager *)manager {
    NSLog(@"User Did Close GTView.");
//    [_hub hideAnimated:YES];
    [MBProgressHUD hideHUDForView:self.view];
    _isShowErrorInfo = NO;
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy))decisionHandler {
    _isShowErrorInfo = NO;
    if (!error) {
        //处理你的验证结果
        NSLog(@"\n===data:%@===", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        decisionHandler(GT3SecondaryCaptchaPolicyAllow);
        
        [self login];
        
    }
    else {
        [MBProgressHUD hideHUDForView:self.view];
        //二次验证发生错误
        decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
        [MBProgressHUD showError:kLoginError ToView:self.view];
    }
}

/** 修改API1的请求 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager willSendRequestAPI1:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest *))replacedHandler {
    NSMutableURLRequest *mRequest = [originalRequest mutableCopy];
    NSString *newURL = [NSString stringWithFormat:@"%@?t=%.0f", originalRequest.URL.absoluteString, [[[NSDate alloc] init]timeIntervalSince1970]];
    mRequest.URL = [NSURL URLWithString:newURL];
    
    replacedHandler(mRequest);
}

#pragma mark -
#pragma mark - Notifications

- (void)registerSuccessfull:(NSNotification *)notification
{
    _isRegisterSuccess = YES;
}

#pragma mark -
#pragma mark - getter

- (RCHLoginRequest *)loginRequest
{
    if(_loginRequest == nil)
    {
        _loginRequest = [[RCHLoginRequest alloc] init];
    }
    return _loginRequest;
}

- (RCHMemberRequest *)memberRequest
{
    if(_memberRequest == nil)
    {
        _memberRequest = [[RCHMemberRequest alloc] init];
    }
    return _memberRequest;
}

@end
