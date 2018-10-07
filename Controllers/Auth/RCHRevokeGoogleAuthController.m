//
//  RCHRevokeGoogleAuthControllerr.m
//  richcore
//
//  Created by WangDong on 2018/6/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRevokeGoogleAuthController.h"
#import "RCHGoogleRequest.h"

#define kCellHeight 44.0f

#define kPassword        @"password"                        //登陆密码
#define kGoogleVerifyCode    @"googleVerifyCode"            //谷歌验证码

@interface RCHRevokeGoogleAuthController ()
{
    UITextField *_passwordTextField;
    UITextField *_verifyCodeTextField;
    UIView *_headerView;
    UIView *_footerView;
    UILabel *_commitLabel;
}

@property (nonatomic, strong) RCHGoogleRequest *googleRequest;

@end

@implementation RCHRevokeGoogleAuthController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"解除谷歌验证";
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    [self initCustomView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - CustomFunction

- (void)initCustomView
{
    [_headerView removeFromSuperview];
    [_footerView removeFromSuperview];
    
    _headerView =  [self createHeaderView:(CGRect){{0.0f, kAppOriginY}, {kMainScreenWidth, 0.0f}}];
    [self.view addSubview:_headerView];
    
    _footerView = [self createFooterViewWithFrame:(CGRect){{0.0f, _headerView.bottom + 20.0f}, {kMainScreenWidth, 150.0f}}];
    
    [self.view addSubview:_footerView];
    [self.view sendSubviewToBack:_footerView];
}


- (UIView *)createHeaderView:(CGRect)rect
{
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    [headView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 30.0f;
    CGFloat originY = 25.0f;
    CGFloat space = 15.0f;
    CGFloat width = 15.0f;
    CGFloat lineWidth = [RCHHelper retinaFloat:1.0f];
    
    UIView *backView1 = [[UIView alloc] initWithFrame:(CGRect){{originX, originY}, {self.view.frame.size.width - originX * 2, kCellHeight}}];
    backView1.backgroundColor = [UIColor whiteColor];
    backView1.layer.cornerRadius = 4.0f;
    backView1.layer.borderWidth = lineWidth;
    backView1.layer.borderColor = [kFontLineGrayColor CGColor];
    backView1.layer.masksToBounds = YES;
    [headView addSubview:backView1];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView1.width - width, backView1.height}}];
    _passwordTextField.backgroundColor = [UIColor whiteColor];
    _passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordTextField.adjustsFontSizeToFitWidth = YES;
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.borderStyle = UITextBorderStyleNone;
    _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordTextField.keyboardType = UIKeyboardTypeDefault;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.placeholder = @"输入登录密码";
    _passwordTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    _passwordTextField.textAlignment = NSTextAlignmentLeft;
    _passwordTextField.textColor = kTextColor_MB;
    _passwordTextField.tag = 1000;
    [_passwordTextField setDelegate:self];
    _passwordTextField.returnKeyType = UIReturnKeyNext;
    [backView1 addSubview:_passwordTextField];
    
    UIView *backView2 = [[UIView alloc] initWithFrame:(CGRect){{backView1.left, backView1.bottom + space}, backView1.frame.size}];
    backView2.backgroundColor = [UIColor whiteColor];
    backView2.layer.cornerRadius =2.0f;
    backView2.layer.borderWidth = lineWidth;
    backView2.layer.borderColor = [kFontLineGrayColor CGColor];
    backView2.layer.masksToBounds = YES;
    [headView addSubview:backView2];
    
    _verifyCodeTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView2.width - width, backView2.height}}];
    _verifyCodeTextField.backgroundColor = [UIColor clearColor];
    _verifyCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _verifyCodeTextField.adjustsFontSizeToFitWidth = YES;
    _verifyCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _verifyCodeTextField.borderStyle = UITextBorderStyleNone;
    _verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _verifyCodeTextField.placeholder = NSLocalizedString(@"输入谷歌验证码",nil);
    _verifyCodeTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    _verifyCodeTextField.textAlignment = NSTextAlignmentLeft;
    _verifyCodeTextField.textColor = kTextColor_MB;
    _verifyCodeTextField.tag = 1002;
    _verifyCodeTextField.returnKeyType = UIReturnKeyNext;
    [_verifyCodeTextField setDelegate:self];
    [backView2 addSubview:_verifyCodeTextField];
    
    headView.frame = (CGRect){headView.frame.origin, {headView.width, backView2.bottom}};
    
    return headView;
}


- (UIView *)createFooterViewWithFrame:(CGRect)frame
{
    UIView *footView = [[UIView alloc] initWithFrame:frame];
    [footView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat left = 30.0f;
    CGSize size = (CGSize){frame.size.width - left * 2, kCellHeight};
    _commitLabel = [[UILabel alloc] initWithFrame:(CGRect){{left, 0.0f}, size}];
    _commitLabel.backgroundColor = kLoginButtonColor;
    _commitLabel.layer.cornerRadius = 4.0f;
    _commitLabel.userInteractionEnabled = YES;
    _commitLabel.layer.masksToBounds = YES;
    _commitLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    _commitLabel.textAlignment = NSTextAlignmentCenter;
    _commitLabel.text = NSLocalizedString(@"提交",nil);
    _commitLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_commitLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitButtonClicked:)];
    tapGesture.delegate = self;
    [_commitLabel addGestureRecognizer:tapGesture];
    
    NSMutableAttributedString *noticeTitle = [[NSMutableAttributedString alloc] initWithString:@"为了您的资产安全，谷歌验证关闭后24h以内不允许提币。" attributes:@{
                                                                                                                                        NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f],
                                                                                                                                        NSForegroundColorAttributeName : kFontLightGrayColor
                                                                                                                                        }];
    
    noticeTitle.yy_lineSpacing = 0.0;
//    noticeTitle.yy_minimumLineHeight = 20.0f;
//    noticeTitle.yy_maximumLineHeight = 20.0f;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(size.width, 40.0f) text:noticeTitle];
    YYLabel *aLabel = [[YYLabel alloc] init];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.frame = CGRectMake(left, _commitLabel.bottom + 30.0f, layout.textBoundingSize.width, layout.textBoundingSize.height);
    aLabel.textLayout = layout;
    [footView addSubview:aLabel];
    
    return footView;
}

#pragma mark -
#pragma mark - Request

- (void)revokeGoogleAuth
{
    NSMutableDictionary *password = [NSMutableDictionary dictionary];
    [password setObject:_verifyCodeTextField.text forKey:@"verifyCode"];
    [password setObject:_passwordTextField.text forKey:@"password"];
    
    RCHWeak(self);
    
    if (self.googleRequest.currentTask) {
        [self.googleRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [self.googleRequest revokeAuth:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (response.statusCode > 300) {
            [MBProgressHUD showError:NSLocalizedString(@"原密码错误或者验证码错误", nil) ToView:self.view];
            return;
        }
        [MBProgressHUD showInfo:NSLocalizedString(@"解绑成功", nil) ToView:weakself.view];
        [RCHHelper setValue:[NSNumber numberWithBool:NO] forKey:kCurrentUserGoogleAuth];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetMemverNotification object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself.navigationController popToRootViewControllerAnimated:YES];
        });
    } parameters:password];
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)submitButtonClicked:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (RCHIsEmpty(_passwordTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"登录密码不能为空",nil) ToView:self.view];
        return;
    }
    
    if (RCHIsEmpty(_verifyCodeTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"谷歌验证码不能为空",nil) ToView:self.view];
        return;
    }
    
    [self revokeGoogleAuth];
    
}

#pragma mark -
#pragma mark - getter

- (RCHGoogleRequest *)googleRequest
{
    if(_googleRequest == nil)
    {
        _googleRequest = [[RCHGoogleRequest alloc] init];
    }
    return _googleRequest;
}


@end
