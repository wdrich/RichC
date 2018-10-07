//
//  RCHResetPasswordController.m
//  richcore
//
//  Created by WangDong on 2018/6/14.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHResetPasswordController.h"
#import "RCHForgotRequest.h"

#define kCellHeight 44.0f

@interface RCHResetPasswordController ()
{
    UITextField *_newTextField;
    UITextField *_confirmTextField;
    UIView *_headerView;
    UIView *_footerView;
    UILabel *_commitLabel;
    
    UIButton *_newEyeButton;
    UIButton *_confirmEyeButton;
}

@property (nonatomic, strong) RCHForgotRequest *forgotRequest;

@end

@implementation RCHResetPasswordController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"重置登录密码";
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
    CGFloat width = 80.0f;
    CGFloat lineWidth = [RCHHelper retinaFloat:1.0f];
    
    UIView *backView1 = [[UIView alloc] initWithFrame:(CGRect){{originX, originY}, {rect.size.width - originX * 2, kCellHeight}}];
    backView1.backgroundColor = [UIColor whiteColor];
    backView1.layer.cornerRadius =2.0f;
    backView1.layer.borderWidth = lineWidth;
    backView1.layer.borderColor = [kFontLineGrayColor CGColor];
    backView1.layer.masksToBounds = YES;
    [headView addSubview:backView1];
    
    UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView1.height}}];
    titleLabel1.backgroundColor = [UIColor whiteColor];
    titleLabel1.adjustsFontSizeToFitWidth = YES;
    titleLabel1.font = [UIFont systemFontOfSize:14.0f];
    titleLabel1.text = NSLocalizedString(@"新密码",nil);
    titleLabel1.textAlignment = NSTextAlignmentLeft;
    titleLabel1.textColor = kTextColor_MB;
    [backView1 addSubview:titleLabel1];
    
    _newTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView1.width - width, backView1.height}}];
    _newTextField.backgroundColor = [UIColor clearColor];
    _newTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _newTextField.adjustsFontSizeToFitWidth = YES;
    _newTextField.borderStyle = UITextBorderStyleNone;
    _newTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _newTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _newTextField.secureTextEntry = YES;
    _newTextField.placeholder = NSLocalizedString(@"至少8位，英文与数字组合",nil);
    _newTextField.font = [UIFont systemFontOfSize:14.0f];
    _newTextField.textAlignment = NSTextAlignmentLeft;
    _newTextField.textColor = kTextColor_MB;
    _newTextField.tag = 1002;
    _newTextField.returnKeyType = UIReturnKeyNext;
    [_newTextField setDelegate:self];
    [backView1 addSubview:_newTextField];
    
    _newEyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _newEyeButton.frame = CGRectMake(backView1.width - backView1.height, 0, backView1.height, backView1.height);
    _newEyeButton.backgroundColor = [UIColor clearColor];
    _newEyeButton.tag = 1;
    [_newEyeButton setImage:RCHIMAGEWITHNAMED(@"password_hide") forState:UIControlStateNormal];
    [_newEyeButton addTarget:self action:@selector(eyeChange:) forControlEvents:UIControlEventTouchUpInside];
    [backView1 addSubview:_newEyeButton];
    
    UIView *backView2 = [[UIView alloc] initWithFrame:(CGRect){{backView1.left, backView1.bottom + space}, backView1.frame.size}];
    backView2.backgroundColor = [UIColor whiteColor];
    backView2.layer.cornerRadius =2.0f;
    backView2.layer.borderWidth = lineWidth;
    backView2.layer.borderColor = [kFontLineGrayColor CGColor];
    backView2.layer.masksToBounds = YES;
    [headView addSubview:backView2];
    
    UILabel *titleLabe2 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView2.height}}];
    titleLabe2.backgroundColor = [UIColor whiteColor];
    titleLabe2.adjustsFontSizeToFitWidth = YES;
    titleLabe2.font = [UIFont systemFontOfSize:14.0f];
    titleLabe2.text = NSLocalizedString(@"确认密码",nil);
    titleLabe2.textAlignment = NSTextAlignmentLeft;
    titleLabe2.textColor = kTextColor_MB;
    [backView2 addSubview:titleLabe2];
    
    _confirmTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView2.width - width, backView2.height}}];
    _confirmTextField.backgroundColor = [UIColor clearColor];
    _confirmTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _confirmTextField.adjustsFontSizeToFitWidth = YES;
    _confirmTextField.borderStyle = UITextBorderStyleNone;
    _confirmTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _confirmTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _confirmTextField.secureTextEntry = YES;
    _confirmTextField.placeholder = NSLocalizedString(@"至少8位，英文与数字组合",nil);
    _confirmTextField.font = [UIFont systemFontOfSize:14.0f];
    _confirmTextField.textAlignment = NSTextAlignmentLeft;
    _confirmTextField.textColor = kTextColor_MB;
    _confirmTextField.tag = 1002;
    _confirmTextField.returnKeyType = UIReturnKeyDone;
    [_confirmTextField setDelegate:self];
    [backView2 addSubview:_confirmTextField];
    
    _confirmEyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmEyeButton.frame = CGRectMake(backView2.width - backView2.height, 0, backView2.height, backView2.height);
    _confirmEyeButton.backgroundColor = [UIColor clearColor];
    _confirmEyeButton.tag = 2;
    [_confirmEyeButton setImage:RCHIMAGEWITHNAMED(@"password_hide") forState:UIControlStateNormal];
    [_confirmEyeButton addTarget:self action:@selector(eyeChange:) forControlEvents:UIControlEventTouchUpInside];
    [backView2 addSubview:_confirmEyeButton];
    
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
    _commitLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _commitLabel.textAlignment = NSTextAlignmentCenter;
    _commitLabel.text = NSLocalizedString(@"提交",nil);
    _commitLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_commitLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetButtonClicked:)];
    tapGesture.delegate = self;
    [_commitLabel addGestureRecognizer:tapGesture];
    
    
    NSMutableAttributedString *noticeTitle = [[NSMutableAttributedString alloc] initWithString:@"为了您的资产安全，登录密码修改后24h以内不允许提币。" attributes:@{
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

- (void)eyeChange:(UIButton *)btn {
    UITextField *textfield;
    if (btn.tag == 1) {
        textfield = _newTextField;
    } else {
        textfield = _confirmTextField;
    }
    textfield.secureTextEntry = !textfield.secureTextEntry;
    if (textfield.secureTextEntry) {
        [btn setImage:RCHIMAGEWITHNAMED(@"password_hide") forState:UIControlStateNormal];
    } else {
        [btn setImage:RCHIMAGEWITHNAMED(@"password_view") forState:UIControlStateNormal];
    }
}

- (BOOL)checkAvailable
{
    
    if (RCHIsEmpty(_newTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"新密码不能为空",nil) ToView:self.view];
        return NO;
    }
    
    if (![RCHHelper checkPassword:_newTextField.text]) {
        [MBProgressHUD showError:NSLocalizedString(@"密码至少8位，英文与数字组合",nil) ToView:self.view];
        return NO;
    }
    
    if (RCHIsEmpty(_confirmTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"请确认新密码",nil) ToView:self.view];
        return NO;
    }
    
    if (![_newTextField.text isEqualToString:_confirmTextField.text]) {
        [MBProgressHUD showError:NSLocalizedString(@"两次密码不一致",nil) ToView:self.view];
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark - request

- (void)changePassword
{
    NSMutableDictionary *password = [NSMutableDictionary dictionary];
    [password setObject:_newTextField.text forKey:@"password"];
    
    RCHWeak(self);
    
    if (self.forgotRequest.currentTask) {
        [self.forgotRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [weakself.forgotRequest change:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@", errorInfo);
        if (error) {
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", errorInfo);
            if (errorInfo) {
                NSDictionary *resultDictionary = [errorInfo objectFromJSONString];
                NSString *message = [resultDictionary objectForKey:@"message"];
                
                if ([message isEqualToString:@"not valid"]) {
                    message = kConnectionError;
                }
                [MBProgressHUD showError:message ToView:self.view];
            } else {
                NSInteger code = ((WDBaseResponse *)response).statusCode;
                NSString *url = ((WDBaseResponse *)response).urlString;
                [RCHHelper showRequestErrorCode:code url:url];
            }
            
        } else {
            [MBProgressHUD showSuccess:NSLocalizedString(@"密码重置成功",nil) ToView:self.view];
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetMemverNotification object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } parameters:password];
}



#pragma mark -
#pragma mark - ButtonClicked

- (void)resetButtonClicked:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![self checkAvailable]) {
        return;
    }
    [self changePassword];
    
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
