//
//  RCHRemoveBindController.m
//  richcore
//
//  Created by WangDong on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRemoveBindController.h"
#import "MJLPickerActionSheet.h"

#import "RCHVerifyRequest.h"
#import "RCHBindRequest.h"

#define kCellHeight 44.0f
#define kCellSpace 52.0f

@interface RCHRemoveBindController ()
{
    UITextField *_passwordField;
    UITextField *_messageTextField;
    UILabel *_submitLabel;
    UIView *_headerView;
    UIView *_footerView;

    UIButton *_checkButton;
}

@property (nonatomic, strong) RCHVerifyRequest *verifyRequest;
@property (nonatomic, strong) RCHBindRequest *bindRequest;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation RCHRemoveBindController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"解除手机验证";
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    [self initCustomView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CustomFunction

- (void)initCustomView
{
    [_headerView removeFromSuperview];
    [_footerView removeFromSuperview];
    
    BOOL hasGoogleAuth = [[RCHHelper valueForKey:kCurrentUserGoogleAuth] boolValue];
    _headerView = [self createHeaderView:(CGRect){{0.0f, kAppOriginY}, {kMainScreenWidth, 0.0f}} hasGoogleAuth:hasGoogleAuth];
    [self.view addSubview:_headerView];
    
    _footerView = [self createFooterViewWithFrame:(CGRect){{0.0f, _headerView.bottom + 20.0f}, {kMainScreenWidth, 100.0f}}];
    [self.view addSubview:_footerView];
    [self.view sendSubviewToBack:_footerView];
}

- (UIView *)createHeaderView:(CGRect)rect hasGoogleAuth:(BOOL)hasGoogleAuth
{
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    [headView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 15.0f;
    CGFloat originY = 20.0f;
    CGFloat lineWidth = [RCHHelper retinaFloat:1.0f];
    UIColor *color = kTextColor_MB;
    
    UIView *backView0 = [[UIView alloc] initWithFrame:(CGRect){{30.0f, originY}, {self.view.frame.size.width - 60.0f, kCellHeight}}];
    backView0.backgroundColor = [UIColor whiteColor];
    backView0.layer.cornerRadius =2.0f;
    backView0.layer.borderWidth = lineWidth;
    backView0.layer.borderColor = [kFontLineGrayColor CGColor];
    backView0.layer.masksToBounds = YES;
    [headView addSubview:backView0];
    
    _passwordField = [[UITextField alloc] initWithFrame:(CGRect){{originX, 0.0f}, {backView0.width  - originX * 2 , backView0.height}}];
    _passwordField.backgroundColor = [UIColor whiteColor];
    _passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordField.adjustsFontSizeToFitWidth = YES;
    _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _passwordField.borderStyle = UITextBorderStyleNone;
    _passwordField.keyboardType = UIKeyboardTypeNumberPad;
    _passwordField.placeholder = @"输入登录密码";
    _passwordField.font = [UIFont systemFontOfSize:14.0f];
    _passwordField.textAlignment = NSTextAlignmentLeft;
    _passwordField.textColor = color;
    _passwordField.tag = 1000;
    [_passwordField setDelegate:self];
    _passwordField.returnKeyType = UIReturnKeyNext;
    [backView0 addSubview:_passwordField];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:(CGRect){{backView0.left, backView0.bottom + 15.0f}, {backView0.width, 22.0f}}];;
    phoneLabel.userInteractionEnabled = YES;
    phoneLabel.backgroundColor = [UIColor clearColor];
    phoneLabel.adjustsFontSizeToFitWidth = YES;
    phoneLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0f];
    phoneLabel.text = [NSString stringWithFormat:@"%@ %@", [RCHHelper getCountryCode:[RCHHelper valueForKey:kCurrentMobileCode]], [RCHHelper valueForKey:kCurrentHideMobile]];
    phoneLabel.textAlignment = NSTextAlignmentLeft;
    phoneLabel.textColor = kTextColor_MB;
    [headView addSubview:phoneLabel];
    
    CGFloat bottom = backView0.bottom + kCellSpace;
    
    CGFloat buttonWidth = 85.0f;
    UIView *backView1 = [[UIView alloc] initWithFrame:(CGRect){{backView0.left, bottom}, {backView0.width - buttonWidth - 10.0f, backView0.height}}];
    backView1.backgroundColor = [UIColor whiteColor];
    backView1.layer.cornerRadius =2.0f;
    backView1.layer.borderWidth = lineWidth;
    backView1.layer.borderColor = [kFontLineGrayColor CGColor];
    backView1.layer.masksToBounds = YES;
    [headView addSubview:backView1];
    
    _messageTextField = [[UITextField alloc] initWithFrame:(CGRect){{originX, 0.0f}, {backView1.width - originX, backView1.height}}];
    _messageTextField.backgroundColor = [UIColor clearColor];
    _messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _messageTextField.adjustsFontSizeToFitWidth = YES;
    _messageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _messageTextField.borderStyle = UITextBorderStyleNone;
    _messageTextField.keyboardType = UIKeyboardTypeNumberPad;
    _messageTextField.secureTextEntry = YES;
    _messageTextField.font = [UIFont systemFontOfSize:14.0f];
    _messageTextField.textAlignment = NSTextAlignmentLeft;
    _messageTextField.placeholder = NSLocalizedString(@"输入短信验证码",nil);
    _messageTextField.textColor = color;
    _messageTextField.tag = 1001;
    [_messageTextField setDelegate:self];
    _messageTextField.returnKeyType = UIReturnKeyNext;
    [backView1 addSubview:_messageTextField];
    
    _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _checkButton.backgroundColor = [UIColor whiteColor];
    _checkButton.layer.cornerRadius = 4.0f;
    _checkButton.layer.borderWidth = lineWidth;
    _checkButton.layer.borderColor = [kYellowColor CGColor];
    _checkButton.layer.masksToBounds = YES;
    _checkButton.frame = CGRectMake((headView.frame.size.width - backView1.left - buttonWidth), (backView1.top + (backView1.height - kCellHeight) / 2.0f), buttonWidth, backView1.height);
    //    [_checkButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    [_checkButton setTitle:NSLocalizedString(@"获取验证码",nil) forState:UIControlStateNormal];
    _checkButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_checkButton setTitleColor:kYellowColor forState:UIControlStateNormal];
    [_checkButton setTitleColor:kFontGrayColor forState:UIControlStateHighlighted];
    [_checkButton addTarget:self action:@selector(getVerifyClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_checkButton];
    bottom = backView1.bottom;

    headView.frame = (CGRect){headView.frame.origin, {headView.width, bottom}};
    
    return headView;
}

- (UIView *)createFooterViewWithFrame:(CGRect)frame
{
    UIView *footView = [[UIView alloc] initWithFrame:frame];
    [footView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat left = 30.0f;
    CGSize size = (CGSize){frame.size.width - left * 2, kCellHeight};
    _submitLabel = [[UILabel alloc] initWithFrame:(CGRect){{left, 0.0f}, size}];
    _submitLabel.backgroundColor = kLoginButtonColor;
    _submitLabel.layer.cornerRadius = 4.0f;
    _submitLabel.userInteractionEnabled = YES;
    _submitLabel.layer.masksToBounds = YES;
    _submitLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    _submitLabel.textAlignment = NSTextAlignmentCenter;
    _submitLabel.text = NSLocalizedString(@"提交",nil);
    _submitLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_submitLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitButtonClicked:)];
    tapGesture.delegate = self;
    [_submitLabel addGestureRecognizer:tapGesture];
    
    NSMutableAttributedString *noticeTitle = [[NSMutableAttributedString alloc] initWithString:@"为了您的资产安全，手机验证关闭后24h以内不允许提币。" attributes:@{
                                                                                                                                           NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f],
                                                                                                                                           NSForegroundColorAttributeName : kFontLightGrayColor
                                                                                                                                           }];
    
    noticeTitle.yy_lineSpacing = 0.0;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(size.width, 40.0f) text:noticeTitle];
    YYLabel *aLabel = [[YYLabel alloc] init];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.frame = CGRectMake(left, _submitLabel.bottom + 30.0f, layout.textBoundingSize.width, layout.textBoundingSize.height);
    aLabel.textLayout = layout;
    [footView addSubview:aLabel];
    
    return footView;
}

- (BOOL)checkAvailable
{
    if (RCHIsEmpty(_passwordField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"登陆密码不能为空",nil) ToView:self.view];
        return NO;
    }
    
    if (RCHIsEmpty(_messageTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"短信验证码不能为空",nil) ToView:self.view];
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark - request

- (void)getVerifyCode:(id)sender
{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    RCHWeak(self);
    if (weakself.verifyRequest.currentTask) {
        [weakself.verifyRequest.currentTask cancel];
    }

    
    
    [MBProgressHUD showLoadToView:self.view];
    [weakself.verifyRequest phoneVerify:^(NSError *error, WDBaseResponse *response) {
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
            if (weakself.timer) {
                dispatch_source_cancel(weakself.timer);
            }
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            weakself.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            [RCHHelper startLableTimer:sender second:59 timer:weakself.timer title:@"重新发送"];
            [MBProgressHUD showSuccess:NSLocalizedString(@"发送成功",nil) ToView:self.view];
        }
    }];
}

- (void)sendSubmitRequest
{
    RCHWeak(self);
    if (weakself.bindRequest.currentTask) {
        [weakself.bindRequest.currentTask cancel];
    }

    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:_passwordField.text forKey:@"password"];
    [info setObject:_messageTextField.text forKey:@"verifyCode"];

    [MBProgressHUD showLoadToView:self.view];
    [weakself.bindRequest unBind:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", errorInfo);
            if (errorInfo) {
                NSDictionary *resultDictionary = [errorInfo objectFromJSONString];
                NSString *message = [resultDictionary objectForKey:@"message"];
                
                if ([message isEqualToString:@"bad code"]) {
                    message = NSLocalizedString(@"短信验证码错误", nil);
                } else if ([message isEqualToString:@"bad password"]) {
                    message = NSLocalizedString(@"登录密码错误", nil);
                } else {
                    message = @"解绑失败，请重试";
                }
                [MBProgressHUD showError:message ToView:self.view];
            } else {
                NSInteger code = ((WDBaseResponse *)response).statusCode;
                NSString *url = ((WDBaseResponse *)response).urlString;
                [RCHHelper showRequestErrorCode:code url:url];
            }
            
        } else {
            [MBProgressHUD showSuccess:NSLocalizedString(@"解绑成功",nil) ToView:self.view];
            [RCHHelper setValue:nil forKey:kCurrentUserMobile];
            [RCHHelper setValue:nil forKey:kCurrentHideMobile];
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetMemverNotification object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } parameters:info];
}


#pragma mark -
#pragma mark - button clicked
- (void)getVerifyClicked:(id)sender
{
    [self getVerifyCode:_checkButton];
}

- (void)submitButtonClicked:(id)sender
{
    if (![self checkAvailable]) {
        return;
    }
    
    [self sendSubmitRequest];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    [self submitButtonClicked:_submitLabel];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}


#pragma mark -
#pragma mark - getter

- (RCHVerifyRequest *)verifyRequest
{
    if(_verifyRequest == nil)
    {
        _verifyRequest = [[RCHVerifyRequest alloc] init];
    }
    return _verifyRequest;
}

- (RCHBindRequest *)bindRequest
{
    if(_bindRequest == nil)
    {
        _bindRequest = [[RCHBindRequest alloc] init];
    }
    return _bindRequest;
}

@end
