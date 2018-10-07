//
//  RCHSecondAuthController.m
//  MeiBe
//
//  Created by WangDong on 2018/3/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHSecondAuthController.h"
#import "RCHSendMobileCodeRequest.h"
#import "RCHGoogleRequest.h"
#import "MBProgressHUD.h"
#import "RCHMemberRequest.h"

#define kNumbers     @"0123456789 "

@interface RCHSecondAuthController ()  <UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    UILabel *_submitLabel;
    
    NSString *_placeholder;
    
    UIView *_headerView;
    UIView *_footerView;
    UITextField *_keyTextField;
    
    NSArray *_guidelines;
    
    RCHSecondAuth _secondAuthType;
    RCHSendMobileCodeRequest *_sendMobileCodeRequest;
    RCHGoogleRequest *_googleRequest;
    MBProgressHUD *_hub;
    void (^ _Nonnull _completion)(RCHSecondAuth, NSString *);
}

@property (nonatomic, strong) RCHSendMobileCodeRequest *sendMobileCodeRequest;
@property (nonatomic, strong) RCHGoogleRequest *googleRequest;
@property (nonatomic, strong) RCHMemberRequest *memberRequest;
@property (nonatomic, strong) UITextField *keyTextField;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation RCHSecondAuthController

- (id)initWithSecondAuthType:(RCHSecondAuth)type
{
    if(self = [super init]) {
        _secondAuthType = type;
    }
    return self;
}

- (id)initWithSecondAuthType:(RCHSecondAuth)type completion:( void (^ _Nonnull )(RCHSecondAuth, NSString *))completion
{
    self = [self initWithSecondAuthType:type];
    if (self) {
        _completion = [completion copy];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTabbleViewBackgroudColor;

    [self initCustomView];
    
    _hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hub];

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[WDRequestManager sharedManager].operationQueue cancelAllOperations];
}

#pragma mark -
#pragma mark - CustomFunction

- (void)initCustomView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    
    NSString *description =nil;
    NSString *navigationTitle = nil;
    NSString *submitTitle = NSLocalizedString(@"提交", nil);
    CGFloat originY = 40.0f;
    CGFloat headerHeight = 149.0f;
    _placeholder = NSLocalizedString(@"输入验证码", nil);
    
    switch (_secondAuthType) {
        case RCHSecondAuthTypeGoogle:
            navigationTitle= NSLocalizedString(@"谷歌验证",nil);
            description = NSLocalizedString(@"请输入由谷歌身份验证器生成的验证码", nil);
            break;
        case RCHSecondAuthTypeMobie:
            navigationTitle= NSLocalizedString(@"短信验证",nil);
            description = NSLocalizedString(@"请输入短信验证码进行二次验证", nil);
            break;
        default:
            navigationTitle= NSLocalizedString(@"",nil);
            description = NSLocalizedString(@"", nil);
            break;
    }
    
    
    self.title = navigationTitle;
    
    _headerView = [self createHeaderView:(CGRect){{0.0f, kAppOriginY}, {kMainScreenWidth, headerHeight}} description:description placeholder:_placeholder originY:originY];
    [self.view addSubview:_headerView];
    
    _footerView = [self createFootView:(CGRect){{0.0f, _headerView.bottom}, {kMainScreenWidth, 60.0f}} submitTitle:submitTitle];
    [self.view addSubview:_footerView];
}


- (UIView *)createHeaderView:(CGRect)rect description:(NSString *)description placeholder:(NSString *)placeholder originY:(CGFloat)originY
{
    CGFloat originX = 30.0f;
    
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    headView.backgroundColor = [UIColor clearColor];
    CGFloat labelWidth = 315.0f;
    UILabel *descriptionLabel = nil;
    UIView *inputView = nil;
    
    descriptionLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, originY}, {labelWidth, 0.0f}}];
    descriptionLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.textColor = kTextColor_MB;

    NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:description Font:descriptionLabel.font color:descriptionLabel.textColor alignment:descriptionLabel.textAlignment];
    descriptionLabel.attributedText = attributedString;
    [headView addSubview:descriptionLabel];
    [descriptionLabel sizeToFit];
    
    
    CGFloat width = self.view.width - originX * 2;
    CGFloat height = 44.0f;
    inputView = [[UIView alloc] initWithFrame:(CGRect){{originX, 0.0f}, {width, height}}];
    inputView.backgroundColor = [UIColor whiteColor];
    inputView.userInteractionEnabled = YES;
    inputView.layer.cornerRadius = 4.0f;
    inputView.layer.borderColor = [[UIColor whiteColor] CGColor];
    inputView.layer.borderWidth = 0.5f;
    inputView.layer.masksToBounds = YES;

    CGRect frame = (CGRect){{15.0f, 12.0f}, {inputView.width - 15.0f * 2, inputView.height - 12.0f * 2}};
    
    _keyTextField = [[UITextField alloc] initWithFrame:frame];
    _keyTextField.backgroundColor = [UIColor clearColor];//RGBA(29.9f, 36.0f, 45.0f, 1.0f);
    _keyTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _keyTextField.adjustsFontSizeToFitWidth = YES;
    _keyTextField.borderStyle = UITextBorderStyleNone;
    _keyTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    _keyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _keyTextField.textAlignment = NSTextAlignmentLeft;
    _keyTextField.placeholder = NSLocalizedString(@"",nil);
    _keyTextField.enabled = YES;
    _keyTextField.hidden = NO;
    _keyTextField.delegate = self;
    _keyTextField.returnKeyType = UIReturnKeySend;
    if (RCHIsEmpty(_keyTextField.text)) {
        _keyTextField.text = placeholder;
        _keyTextField.textColor = kPlaceholderColor;
        _keyTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    } else {
        _keyTextField.textColor = kTextColor_MB;
        _keyTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    }
    
    [inputView addSubview:_keyTextField];
//    [_keyTextField becomeFirstResponder];
    [headView addSubview:inputView];
    
    descriptionLabel.frame = (CGRect){{(headView.width - descriptionLabel.width) / 2.0f, originY}, {descriptionLabel.width, 20.0f}};
    inputView.frame = (CGRect){{originX, descriptionLabel.bottom + 15.0f}, inputView.frame.size};
    
    if (_secondAuthType == RCHSecondAuthTypeMobie) {
        
        CGFloat buttonWidth = 85.0f;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = 4.0f;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [kYellowColor CGColor];
        button.layer.masksToBounds = YES;
        button.frame = CGRectMake((headView.width - originX - buttonWidth), inputView.top, buttonWidth, height);
        [button setTitle:NSLocalizedString(@"获取验证码",nil) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [button setTitleColor:kYellowColor forState:UIControlStateNormal];
        [button setTitleColor:kFontGrayColor forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(sendMobileCode:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:button];
        
        inputView.frame = (CGRect){{originX, descriptionLabel.bottom + 15.0f}, {button.left - 10.0f - originX, inputView.height}};
    }


    return headView;
}


- (UIView *)createFootView:(CGRect)rect submitTitle:(NSString *)submitTitle
{
    CGFloat height = 44.0f;
    UIView *footView = [[UIView alloc] initWithFrame:rect];
    footView.backgroundColor = [UIColor clearColor];
    
    _submitLabel = [[UILabel alloc] initWithFrame:(CGRect){{30.0f, 0.0f}, {rect.size.width - 30.0f * 2, height}}];
    _submitLabel.backgroundColor = kPlaceholderColor;
    _submitLabel.layer.cornerRadius = 4.0f;
    _submitLabel.layer.masksToBounds = YES;
    _submitLabel.userInteractionEnabled = YES;
    _submitLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    _submitLabel.textAlignment = NSTextAlignmentCenter;
    _submitLabel.text = submitTitle;
    _submitLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_submitLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitClicked:)];
    tapGesture.delegate = self;
    [_submitLabel addGestureRecognizer:tapGesture];

    return footView;
}

- (void)verifyCodeRequest:(NSString *)code
{
    if (_completion) {
        _completion(_secondAuthType, code);
        return;
    }
    if (self.googleRequest.currentTask) {
        [self.googleRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    RCHWeak(self);
    [_googleRequest postVerify:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            [MBProgressHUD showError:kVerifyCodeError ToView:self.view];
            return;
        }
        [weakself getMemberInfo];
    } verifyCode:code];

}

- (void)sendMobileCodeRequestRequest:(id)sender
{
    RCHWeak(self);

    if (weakself.sendMobileCodeRequest.currentTask) {
        [weakself.sendMobileCodeRequest.currentTask cancel];
    }
    
    [MBProgressHUD showLoadToView:self.view];
    
    [self.sendMobileCodeRequest getVerify:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            [MBProgressHUD hideHUDForView:self.view];
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
            return;
        } else {
            if (weakself.timer) {
                dispatch_source_cancel(weakself.timer);
            }
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            weakself.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            [RCHHelper startLableTimer:sender second:59 timer:weakself.timer title:@"重新发送"];
            [MBProgressHUD showSuccess:NSLocalizedString(@"发送成功",nil) ToView:self.view];
            [weakself.keyTextField becomeFirstResponder];
        }
    }];
}

- (void)verifyMobileCodeRequestRequest:(NSString *)code
{
    if (_completion) {
        _completion(_secondAuthType, code);
        return;
    }
    if (self.sendMobileCodeRequest.currentTask) {
        [self.sendMobileCodeRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    RCHWeak(self);
    [self.sendMobileCodeRequest sendVerify:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            [MBProgressHUD showError:kVerifyCodeError ToView:self.view];
            return;
        }
        [weakself getMemberInfo];
    } verifyCode:code];
}


- (void)getMemberInfo
{
    RCHWeak(self);
    //    RCHWeak(_hub);
    if (weakself.memberRequest.currentTask) {
        [weakself.memberRequest.currentTask cancel];
    }
    
    [weakself.memberRequest member:^(NSObject *response) {
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

- (void)sendMobileCode:(id)sender
{
    [self sendMobileCodeRequestRequest:sender];
}

- (void)submitClicked:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (_secondAuthType == RCHSecondAuthTypeGoogle) {
        if ([_keyTextField.text length] < 6) {
            return;
        }
        [self verifyCodeRequest:_keyTextField.text];
    } else if (_secondAuthType == RCHSecondAuthTypeMobie) {
        if ([_keyTextField.text length] < 6) {
            return;
        }
        [self verifyMobileCodeRequestRequest:_keyTextField.text];
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:_placeholder]) {
        textField.text = @"";
        textField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        textField.textColor = kTextColor_MB;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    NSLog(@"text:%@,insert:==%@==", textField.text, string);
    if ((range.location + string.length) > 6) {
        return NO;
    } else if ((range.location + string.length) == 6) {
        _submitLabel.backgroundColor = kAppOrangeColor;
        NSString *code = [NSString stringWithFormat:@"%@%@", _keyTextField.text, string];
        if (_secondAuthType == RCHSecondAuthTypeGoogle) {
            [self verifyCodeRequest:code];
        } else if (_secondAuthType == RCHSecondAuthTypeMobie) {
            [self verifyMobileCodeRequestRequest:code];
        }
    } else {
        _submitLabel.backgroundColor = kPlaceholderColor;
    }
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (RCHIsEmpty(textField.text)) {
        textField.text = _placeholder;
        textField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        textField.textColor = kPlaceholderColor;
    }
}

#pragma mark -
#pragma mark - getter

- (RCHSendMobileCodeRequest *)sendMobileCodeRequest
{
    if(_sendMobileCodeRequest == nil)
    {
        _sendMobileCodeRequest = [[RCHSendMobileCodeRequest alloc] init];
    }
    return _sendMobileCodeRequest;
}

- (RCHGoogleRequest *)googleRequest
{
    if(_googleRequest == nil)
    {
        _googleRequest = [[RCHGoogleRequest alloc] init];
    }
    return _googleRequest;
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
