//
//  RCHForgotPasswordController.m
//  richcore
//
//  Created by WangDong on 2018/6/14.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHForgotPasswordController.h"
#import "RCHResetPasswordController.h"
#import "RCHForgotRequest.h"

#define kCellHeight 44.0f
#define kLineWidth 0.5
#define kCellSpace 15.0f

@interface RCHForgotPasswordController ()
{
    UITextField *_emailCodeTextField;
    UITextField *_mobileCodeTextField;
    UITextField *_googleCodeTextField;
    UILabel *_submitLabel;
    UIView *_headerView;
    UIView *_footerView;
    
    UIButton *_emailCodeButton;
    UIButton *_mobileCodeButton;
}

@property (nonatomic, strong) RCHForgotRequest *forgotRequest;
@property (nonatomic, strong) dispatch_source_t messageTimer;
@property (nonatomic, strong) dispatch_source_t mailTimer;

@end

@implementation RCHForgotPasswordController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"验证";
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    [self initCustomView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.messageTimer) {
        dispatch_source_cancel(self.messageTimer);
    }
    if (self.mailTimer) {
        dispatch_source_cancel(self.mailTimer);
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (self.forgotRequest.currentTask) {
        [self.forgotRequest.currentTask cancel];
    }
}

#pragma mark - CustomFunction

- (void)initCustomView
{
    [_headerView removeFromSuperview];
    [_footerView removeFromSuperview];
    
    _headerView = [self createHeaderView:(CGRect){{0.0f, kAppOriginY}, {kMainScreenWidth, 0.0f}}];
    [self.view addSubview:_headerView];
    
    _footerView = [self createFooterViewWithFrame:(CGRect){{0.0f, _headerView.bottom + 20.0f}, {kMainScreenWidth, 100.0f}}];
    [self.view addSubview:_footerView];
    [self.view sendSubviewToBack:_footerView];
}

- (UIView *)createHeaderView:(CGRect)rect
{
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    [headView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 30.0f;
    CGFloat originY = 30.0f;
    CGFloat bottom = 0.0f;
    UIView *emailView = [self createEmailView:(CGRect){{originX, originY}, {rect.size.width - 60.0f, 81.0f}}];
    [headView addSubview:emailView];
    if (self.member.google_auth && self.member.mobile_raw) {
        bottom = emailView.bottom + kCellSpace;
        
        UIView *messageView = [self createMessageView:(CGRect){{originX, bottom}, {rect.size.width - 60.0f, 81.0f}}];
        [headView addSubview:messageView];
        
        bottom = messageView.bottom + kCellSpace;
        
        UIView *googleView = [self createGoogleView:(CGRect){{originX, bottom}, {rect.size.width - 60.0f, kCellHeight}}];
        [headView addSubview:googleView];
        
        bottom = googleView.bottom;

    } else {
        if (self.member.google_auth) {
            bottom = emailView.bottom + kCellSpace;
            UIView *googleView = [self createGoogleView:(CGRect){{originX, bottom}, {rect.size.width - 60.0f, kCellHeight}}];
            [headView addSubview:googleView];
            bottom = googleView.bottom;
        }
        else if (self.member.mobile_raw){
            bottom = emailView.bottom + kCellSpace;
            UIView *messageView = [self createMessageView:(CGRect){{originX, bottom}, {rect.size.width - 60.0f, 81.0f}}];
            [headView addSubview:messageView];
            bottom = messageView.bottom;
        } else {
            bottom = emailView.bottom;
        }
    }
    
    headView.frame = (CGRect){headView.frame.origin, {headView.width, bottom}};
    
    return headView;
}

- (UIView *)createEmailView:(CGRect)rect
{
    CGFloat originX = 15.0f;
    CGFloat buttonWidth = 85.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    
    NSString *showName = [RCHHelper confusedSting:self.member.email_raw ?: @""];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {rect.size.width - 60.0f, 22.0f}}];;
    titleLabel.userInteractionEnabled = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    titleLabel.text = showName;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = kTextColor_MB;
    [view addSubview:titleLabel];
    
    UIView *backView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, titleLabel.bottom + kCellSpace}, {rect.size.width - buttonWidth - 10.0f, kCellHeight}}];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius =2.0f;
    backView.layer.borderWidth = kLineWidth;
    backView.layer.borderColor = [kFontLineGrayColor CGColor];
    backView.layer.masksToBounds = YES;
    [view addSubview:backView];
    
    _emailCodeTextField = [[UITextField alloc] initWithFrame:(CGRect){{originX, 0.0f}, {backView.width - originX, backView.height}}];
    _emailCodeTextField.backgroundColor = [UIColor clearColor];
    _emailCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _emailCodeTextField.adjustsFontSizeToFitWidth = YES;
    _emailCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailCodeTextField.borderStyle = UITextBorderStyleNone;
    _emailCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _emailCodeTextField.font = [UIFont systemFontOfSize:14.0f];
    _emailCodeTextField.textAlignment = NSTextAlignmentLeft;
    _emailCodeTextField.placeholder = NSLocalizedString(@"输入验证码",nil);
    _emailCodeTextField.textColor = kTextColor_MB;
    _emailCodeTextField.tag = 1001;
    [_emailCodeTextField setDelegate:self];
    _emailCodeTextField.returnKeyType = UIReturnKeyNext;
    [backView addSubview:_emailCodeTextField];
    
    _emailCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _emailCodeButton.backgroundColor = [UIColor whiteColor];
    _emailCodeButton.layer.cornerRadius = 4.0f;
    _emailCodeButton.layer.borderWidth = kLineWidth;
    _emailCodeButton.layer.borderColor = [kYellowColor CGColor];
    _emailCodeButton.layer.masksToBounds = YES;
    _emailCodeButton.frame = CGRectMake((view.frame.size.width - backView.left - buttonWidth), (backView.top + (backView.height - kCellHeight) / 2.0f), buttonWidth, backView.height);
    //    [_emailCodeButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    [_emailCodeButton setTitle:NSLocalizedString(@"获取验证码",nil) forState:UIControlStateNormal];
    _emailCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_emailCodeButton setTitleColor:kYellowColor forState:UIControlStateNormal];
    [_emailCodeButton setTitleColor:kFontGrayColor forState:UIControlStateHighlighted];
    [_emailCodeButton addTarget:self action:@selector(getEmailCodeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_emailCodeButton];
    
    return view;
}

- (UIView *)createMessageView:(CGRect)rect
{
    CGFloat originX = 15.0f;
    CGFloat buttonWidth = 85.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    
    NSString *showName = [NSString stringWithFormat:@"%@ %@", [RCHHelper getCountryCode:[self.member.country objectForKey:@"code"]] ?: @"", [RCHHelper confusedSting:self.member.mobile_raw ?: @""]];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {rect.size.width - 60.0f, 22.0f}}];;
    phoneLabel.userInteractionEnabled = YES;
    phoneLabel.backgroundColor = [UIColor clearColor];
    phoneLabel.adjustsFontSizeToFitWidth = YES;
    phoneLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    phoneLabel.text = showName;
    phoneLabel.textAlignment = NSTextAlignmentLeft;
    phoneLabel.textColor = kTextColor_MB;
    [view addSubview:phoneLabel];
    
    UIView *backView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, phoneLabel.bottom + kCellSpace}, {rect.size.width - buttonWidth - 10.0f, kCellHeight}}];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius =2.0f;
    backView.layer.borderWidth = kLineWidth;
    backView.layer.borderColor = [kFontLineGrayColor CGColor];
    backView.layer.masksToBounds = YES;
    [view addSubview:backView];
    
    _mobileCodeTextField = [[UITextField alloc] initWithFrame:(CGRect){{originX, 0.0f}, {backView.width - originX, backView.height}}];
    _mobileCodeTextField.backgroundColor = [UIColor clearColor];
    _mobileCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _mobileCodeTextField.adjustsFontSizeToFitWidth = YES;
    _mobileCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _mobileCodeTextField.borderStyle = UITextBorderStyleNone;
    _mobileCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _mobileCodeTextField.font = [UIFont systemFontOfSize:14.0f];
    _mobileCodeTextField.textAlignment = NSTextAlignmentLeft;
    _mobileCodeTextField.placeholder = NSLocalizedString(@"输入短信验证码",nil);
    _mobileCodeTextField.textColor = kTextColor_MB;
    _mobileCodeTextField.tag = 1001;
    [_mobileCodeTextField setDelegate:self];
    _mobileCodeTextField.returnKeyType = UIReturnKeyNext;
    [backView addSubview:_mobileCodeTextField];
    
    _mobileCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mobileCodeButton.backgroundColor = [UIColor whiteColor];
    _mobileCodeButton.layer.cornerRadius = 4.0f;
    _mobileCodeButton.layer.borderWidth = kLineWidth;
    _mobileCodeButton.layer.borderColor = [kYellowColor CGColor];
    _mobileCodeButton.layer.masksToBounds = YES;
    _mobileCodeButton.frame = CGRectMake((view.frame.size.width - backView.left - buttonWidth), (backView.top + (backView.height - kCellHeight) / 2.0f), buttonWidth, backView.height);
    [_mobileCodeButton setTitle:NSLocalizedString(@"获取验证码",nil) forState:UIControlStateNormal];
    _mobileCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_mobileCodeButton setTitleColor:kYellowColor forState:UIControlStateNormal];
    [_mobileCodeButton setTitleColor:kFontGrayColor forState:UIControlStateHighlighted];
    [_mobileCodeButton addTarget:self action:@selector(getMessageCodeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_mobileCodeButton];
    
    return view;
}

- (UIView *)createGoogleView:(CGRect)rect
{
    CGFloat originX = 15.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *backView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {rect.size.width, kCellHeight}}];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius =2.0f;
    backView.layer.borderWidth = kLineWidth;
    backView.layer.borderColor = [kFontLineGrayColor CGColor];
    backView.layer.masksToBounds = YES;
    [view addSubview:backView];
    
    _googleCodeTextField = [[UITextField alloc] initWithFrame:(CGRect){{originX, 0.0f}, {backView.width  - originX * 2 , backView.height}}];
    _googleCodeTextField.backgroundColor = [UIColor whiteColor];
    _googleCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _googleCodeTextField.adjustsFontSizeToFitWidth = YES;
    _googleCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _googleCodeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _googleCodeTextField.borderStyle = UITextBorderStyleNone;
    _googleCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _googleCodeTextField.placeholder = @"输入谷歌验证码";
    _googleCodeTextField.font = [UIFont systemFontOfSize:14.0f];
    _googleCodeTextField.textAlignment = NSTextAlignmentLeft;
    _googleCodeTextField.textColor = kTextColor_MB;
    _googleCodeTextField.tag = 1000;
    [_googleCodeTextField setDelegate:self];
    _googleCodeTextField.returnKeyType = UIReturnKeyNext;
    [backView addSubview:_googleCodeTextField];
    
    return view;
    
}

- (UIView *)createFooterViewWithFrame:(CGRect)frame
{
    UIView *footView = [[UIView alloc] initWithFrame:frame];
    [footView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat left = 30.0f;
    CGSize size = (CGSize){frame.size.width - left * 2, 40.0f};
    _submitLabel = [[UILabel alloc] initWithFrame:(CGRect){{left, 0.0f}, size}];
    _submitLabel.backgroundColor = kLoginButtonColor;
    _submitLabel.layer.cornerRadius =4.0f;
    _submitLabel.userInteractionEnabled = YES;
    _submitLabel.layer.masksToBounds = YES;
    _submitLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    _submitLabel.textAlignment = NSTextAlignmentCenter;
    _submitLabel.text = NSLocalizedString(@"确认",nil);
    _submitLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_submitLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitButtonClicked:)];
    tapGesture.delegate = self;
    [_submitLabel addGestureRecognizer:tapGesture];
    
    
    return footView;
}

- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)checkAvailable
{
    if (RCHIsEmpty(_emailCodeTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"邮箱验证吗不能为空",nil) ToView:self.view];
        return NO;
    }
    if (RCHIsEmpty(_mobileCodeTextField.text) && self.member.mobile_raw) {
        [MBProgressHUD showError:NSLocalizedString(@"短信验证吗不能为空",nil) ToView:self.view];
        return NO;
    }
    if (RCHIsEmpty(_googleCodeTextField.text) && self.member.google_auth) {
        [MBProgressHUD showError:NSLocalizedString(@"谷歌验证吗不能为空",nil) ToView:self.view];
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark - request


- (void)getMessageCode:(id)sender
{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    RCHWeak(self);
    if (weakself.forgotRequest.currentTask) {
        [weakself.forgotRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [weakself.forgotRequest mobileVerify:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            [MBProgressHUD hideHUDForView:self.view];
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            if (code >= 500) {
                [MBProgressHUD showSuccess:kTimesError ToView:self.view];
            }else {
                [RCHHelper showRequestErrorCode:code url:url];
            }
            
            return;
        } else {
            if (weakself.messageTimer) {
                dispatch_source_cancel(weakself.messageTimer);
            }
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            weakself.messageTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            [RCHHelper startLableTimer:sender second:59 timer:weakself.messageTimer title:@"重新发送"];
            [MBProgressHUD showSuccess:NSLocalizedString(@"发送成功",nil) ToView:self.view];
        }    }];
}

- (void)getEmailCode:(id)sender
{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    RCHWeak(self);
    if (weakself.forgotRequest.currentTask) {
        [weakself.forgotRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [weakself.forgotRequest emailVerify:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            [MBProgressHUD hideHUDForView:self.view];
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            if (code >= 500) {
                [MBProgressHUD showSuccess:kTimesError ToView:self.view];
            }else {
                [RCHHelper showRequestErrorCode:code url:url];
            }
            
            return;
        } else {
            if (weakself.mailTimer) {
                dispatch_source_cancel(weakself.mailTimer);
            }
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            weakself.mailTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            [RCHHelper startLableTimer:sender second:59 timer:weakself.mailTimer title:@"重新发送"];
            [MBProgressHUD showSuccess:NSLocalizedString(@"发送成功",nil) ToView:self.view];
        }
    }];
}

- (void)sendVerifyRequest
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (!RCHIsEmpty(_mobileCodeTextField.text)) {
        [info setObject:_mobileCodeTextField.text forKey:@"mobileCode"];
    }
    
    if (!RCHIsEmpty(_emailCodeTextField.text)) {
        [info setObject:_emailCodeTextField.text forKey:@"emailCode"];
    }
    
    if (!RCHIsEmpty(_googleCodeTextField.text)) {
        [info setObject:_googleCodeTextField.text forKey:@"googleCode"];
    }

    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    RCHWeak(self);
    if (weakself.forgotRequest.currentTask) {
        [weakself.forgotRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [weakself.forgotRequest verify:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", errorInfo);
            if (errorInfo) {
                NSDictionary *resultDictionary = [errorInfo objectFromJSONString];
                NSString *message = [resultDictionary objectForKey:@"message"];
                
                if ([message isEqualToString:@"sms code is error"]) {
                    message = NSLocalizedString(@"短信验证码错误", nil);
                } else if ([message isEqualToString:@"email code is error"]) {
                    message = NSLocalizedString(@"邮箱验证码错误", nil);
                } else if ([message isEqualToString:@"bad verify code"]) {
                    message = NSLocalizedString(@"谷歌验证码错误", nil);
                } else {
                    message = @"验证失败，请重试";
                }
                [MBProgressHUD showError:message ToView:self.view];
            } else {
                NSInteger code = ((WDBaseResponse *)response).statusCode;
                NSString *url = ((WDBaseResponse *)response).urlString;
                [RCHHelper showRequestErrorCode:code url:url];
            }
            
        } else {
            RCHWeak(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                DismissModalViewControllerAnimated(weakself, YES);
                if (weakself.finished)
                {
                    weakself.finished();
                }
            });
        }
    } parameters:info];
}

#pragma mark -
#pragma mark - button clicked

- (void)getMessageCodeClicked:(id)sender
{
    [self getMessageCode:sender];
}

- (void)getEmailCodeClicked:(id)sender
{
    [self getEmailCode:sender];
}


- (void)submitButtonClicked:(id)sender
{
    if (![self checkAvailable]) {
        return;
    }
    [self sendVerifyRequest];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    [self submitButtonClicked:_submitLabel];
    
    return YES;
}

#pragma mark -
#pragma mark -  NavigationDataSource

- (UIImage *)RCHNavigationBarLeftButtonImage:(UIButton *)leftButton navigationBar:(RCHNavigationBar *)navigationBar
{
    [self customButtonInfo:leftButton title:NSLocalizedString(@"取消",nil)];
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



#pragma mark -
#pragma mark - getter

- (RCHForgotRequest *)forgotRequest
{
    if(_forgotRequest == nil)
    {
        _forgotRequest = [[RCHForgotRequest alloc] init];
    }
    return _forgotRequest;
}


@end
