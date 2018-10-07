//
//  RCHCheckEmailController.m
//  richcore
//
//  Created by WangDong on 2018/6/14.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHCheckEmailController.h"
#import <GT3Captcha/GT3Captcha.h>
#import "RCHResetPasswordController.h"
#import "RCHForgotPasswordController.h"
#import "RCHForgotRequest.h"

#define kCellHeight 44.0f

@interface RCHCheckEmailController () <GT3CaptchaManagerDelegate>
{
    UITextField *_emailTextField;
    UILabel *_submitLabel;
    UIView *_headerView;
    UIView *_footerView;
    
    BOOL _isShowErrorInfo;
    
}

@property (nonatomic, strong) RCHForgotRequest *forgotRequest;
@property (nonatomic, strong) GT3CaptchaButton *captchaButton;

@end

@implementation RCHCheckEmailController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找回密码";
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    [self initCustomView];
    [self createCaptchaButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    
    _footerView = [self createFooterViewWithFrame:(CGRect){{0.0f, _headerView.bottom + 30.0f}, {kMainScreenWidth, 100.0f}}];
    [self.view addSubview:_footerView];
    [self.view sendSubviewToBack:_footerView];
}

- (UIView *)createHeaderView:(CGRect)rect
{
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    [headView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 15.0f;
    CGFloat originY = 75.0f;
    CGFloat lineWidth = [RCHHelper retinaFloat:1.0f];
    UIColor *color = kTextColor_MB;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 40.0f}, {rect.size.width, 20.0f}}];;
    titleLabel.userInteractionEnabled = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    titleLabel.text = NSLocalizedString(@"请输入邮箱账号",nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = kTextColor_MB;
    [headView addSubview:titleLabel];
    
    UIView *backView0 = [[UIView alloc] initWithFrame:(CGRect){{30.0f, originY}, {rect.size.width - 60.0f, kCellHeight}}];
    backView0.backgroundColor = [UIColor whiteColor];
    backView0.layer.cornerRadius =2.0f;
    backView0.layer.borderWidth = lineWidth;
    backView0.layer.borderColor = [kFontLineGrayColor CGColor];
    backView0.layer.masksToBounds = YES;
    [headView addSubview:backView0];
    
    _emailTextField = [[UITextField alloc] initWithFrame:(CGRect){{originX, 0.0f}, {backView0.width  - originX * 2 , backView0.height}}];
    _emailTextField.backgroundColor = [UIColor whiteColor];
    _emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _emailTextField.adjustsFontSizeToFitWidth = YES;
    _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _emailTextField.borderStyle = UITextBorderStyleNone;
    _emailTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _emailTextField.placeholder = @"输入邮箱账号";
    _emailTextField.returnKeyType = UIReturnKeyDone;
    _emailTextField.font = [UIFont systemFontOfSize:14.0f];
    _emailTextField.textAlignment = NSTextAlignmentLeft;
    _emailTextField.textColor = color;
    _emailTextField.tag = 1000;
    [_emailTextField setDelegate:self];
    [backView0 addSubview:_emailTextField];

    CGFloat bottom = backView0.bottom;
    headView.frame = (CGRect){headView.frame.origin, {headView.width, bottom}};
    
    return headView;
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
    _submitLabel.text = NSLocalizedString(@"下一步",nil);
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

- (void)createCaptchaButton {
    //添加验证按钮到父视图上
    self.captchaButton.center = CGPointMake(self.view.center.x, self.view.center.y + 76);
    //推荐直接开启验证
    [self.captchaButton startCaptcha];
    [self.view addSubview:self.captchaButton];
    self.captchaButton.hidden = YES;
}

- (BOOL)checkAvailable
{
    if (RCHIsEmpty(_emailTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"邮箱不能为空",nil) ToView:self.view];
        return NO;
    }
    
    if (![self isValidateEmail:_emailTextField.text]) {
        [MBProgressHUD showError:NSLocalizedString(@"邮箱格式错误，请重新输入",nil) ToView:self.view];
        return NO;
    }
    
    return YES;
}

- (void)goToVerify:(RCHMember *)member
{
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RCHForgotPasswordController *controller = [[RCHForgotPasswordController alloc]init];
        controller.member = member;
        controller.finished = ^() {
            RCHResetPasswordController *viewcontroller = [[RCHResetPasswordController alloc] init];
            [weakself.navigationController pushViewController:viewcontroller animated:YES];
        };
        RCHNavigationController *NVController = [[RCHNavigationController alloc] initWithRootViewController:controller];
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        PresentModalViewControllerAnimated(weakself, NVController, YES);
    });
}


#pragma mark -
#pragma mark - request

- (void)checkEmail:(NSString *)email
{
    RCHWeak(self);

    if (weakself.forgotRequest.currentTask) {
        [weakself.forgotRequest.currentTask cancel];
    }

//    [MBProgressHUD showLoadToView:self.view];
    [weakself.forgotRequest checkEmail:^(NSError *error, NSObject *response) {
        if (error) {
            [MBProgressHUD hideHUDForView:self.view];
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", errorInfo);
            if (errorInfo) {
                NSDictionary *resultDictionary = [errorInfo objectFromJSONString];
                NSString *message = [resultDictionary objectForKey:@"message"];
                
                if ([message isEqualToString:@"member not exist"]) {
                    message = NSLocalizedString(@"邮箱未注册", nil);
                } else {
                    message = @"操作失败，请重试";
                }
                [MBProgressHUD showError:message ToView:self.view];
            } else {
                NSInteger code = ((WDBaseResponse *)response).statusCode;
                NSString *url = ((WDBaseResponse *)response).urlString;
                [RCHHelper showRequestErrorCode:code url:url];
            }
        } else {
            [weakself getMember];
        }
    } email:email];
}

- (void)getMember
{
    RCHWeak(self);
    
    if (weakself.forgotRequest.currentTask) {
        [weakself.forgotRequest.currentTask cancel];
    }
//    [MBProgressHUD showLoadToView:self.view];
    [weakself.forgotRequest getMember:^(NSObject *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if ([response isKindOfClass:[RCHMember class]]) {
            [weakself goToVerify:(RCHMember *)response];
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
#pragma mark - button clicked

- (void)submitButtonClicked:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (![self checkAvailable]) {
        return;
    }
    [MBProgressHUD showLoadToView:self.view];
    [self.captchaButton startCaptcha];
    _isShowErrorInfo = YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    [self submitButtonClicked:_submitLabel];
    
    return YES;
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
    [MBProgressHUD hideHUDForView:self.view];
    _isShowErrorInfo = NO;
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy))decisionHandler {
    _isShowErrorInfo = NO;
    if (!error) {
        //处理你的验证结果
        NSLog(@"\n===data:%@===", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        decisionHandler(GT3SecondaryCaptchaPolicyAllow);
        [self checkEmail:_emailTextField.text];
    }
    else {
        [MBProgressHUD hideHUDForView:self.view];
        //二次验证发生错误
        decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
        [MBProgressHUD showError: NSLocalizedString(@"验证失败",nil) ToView:self.view];
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
#pragma mark - getter

- (RCHForgotRequest *)forgotRequest
{
    if(_forgotRequest == nil)
    {
        _forgotRequest = [[RCHForgotRequest alloc] init];
    }
    return _forgotRequest;
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


@end
