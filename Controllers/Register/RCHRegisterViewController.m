//
//  RCHRegisterViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRegisterViewController.h"
#import "MJLPickerActionSheet.h"

#import "RCHCheckEmailRequest.h"
#import "RCHSecurityCodeRequest.h"
#import "RCHRegisterRequest.h"
#import "RCHMemberRequest.h"
#import "RCHCountryRequest.h"


#define kCellHeight 44.0f
#define kCellSpace 10.0f

@interface RCHRegisterViewController () <UIGestureRecognizerDelegate, MJLPickerActionSheetDelegate>
{
    UILabel *_countryLabel;
    UITextField *_phoneTextField;
    UITextField *_passwordTextField;
    UIButton *_eyeButton;
    UITextField *_securityCodeTextField;
    UITextField *_invitationCodeTextField;
    UILabel *_registerLabel;
    UIView *_headerView;
    UIView *_footerView;
    
    NSString *_country;
    NSInteger _countryId;
    NSMutableArray *_titles;
    NSMutableArray *_countries;

    UIButton *_checkButton;
}

@property (nonatomic, strong) RCHRegisterRequest *registerRequest;
@property (nonatomic, strong) RCHCheckEmailRequest *checkEmailRequest;
@property (nonatomic, strong) RCHSecurityCodeRequest *securityCodeRequest;
@property (nonatomic, strong) RCHMemberRequest *memberRequest;
@property (nonatomic, strong) RCHCountryRequest *countryRequest;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation RCHRegisterViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    [self initCustomInfo];
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

- (void)initCustomInfo
{
    if (!_country) {
        _country = NSLocalizedString(@"China", nil);
    }
    
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    
    if (!_countries) {
        _countries = [NSMutableArray array];
        RCHCountry *country = [[RCHCountry alloc] init];
        country.countryId = 29;
        country.name_cn = @"中国";
        country.name_en = @"China"
        ;
        [_countries addObject:country];
        [_titles addObject:[[_countries objectAtIndex:0] name_en]];
        _countryId = country.countryId;
    }

    [self getCountries];
}

- (void)initCustomView
{
    [_headerView removeFromSuperview];
    [_footerView removeFromSuperview];
    
    _headerView = [self createHeaderView:(CGRect){{0.0f, kAppOriginY}, {kMainScreenWidth, 0.0f}}];
    [self.view addSubview:_headerView];
    
    _footerView = [self createFooterViewWithFrame:(CGRect){{0.0f, _headerView.bottom + 10.0f}, {kMainScreenWidth, 100.0f}}];
    [self.view addSubview:_footerView];
    [self.view sendSubviewToBack:_footerView];
}

- (UIView *)createHeaderView:(CGRect)rect
{
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    [headView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 15.0f;
    CGFloat originY = 20.0f;
    CGFloat width = 75.0f;
    CGFloat lineWidth = [RCHHelper retinaFloat:1.0f];
    
    UIView *backView0 = [[UIView alloc] initWithFrame:(CGRect){{30.0f, originY}, {self.view.frame.size.width - 60.0f, kCellHeight}}];
    backView0.backgroundColor = [UIColor whiteColor];
    backView0.layer.cornerRadius =2.0f;
    backView0.layer.borderWidth = lineWidth;
    backView0.layer.borderColor = [kFontLineGrayColor CGColor];
    backView0.layer.masksToBounds = YES;
    [headView addSubview:backView0];
    
    UIImage *image = RCHIMAGEWITHNAMED(@"ico_arrow_country");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, image.size}];
    imageView.image = image;
    [backView0 addSubview:imageView];
    
    _countryLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, 0.0f}, {backView0.width - originX * 2 - imageView.width, backView0.height}}];;
    _countryLabel.userInteractionEnabled = YES;
    _countryLabel.backgroundColor = [UIColor clearColor];
    _countryLabel.adjustsFontSizeToFitWidth = YES;
    _countryLabel.font = [UIFont systemFontOfSize:14.0f];
    _countryLabel.text = _country;
    _countryLabel.textAlignment = NSTextAlignmentLeft;
    _countryLabel.textColor = kTextColor_MB;
    [backView0 addSubview:_countryLabel];
    
    imageView.center = (CGPoint){backView0.width - originX - image.size.width, _countryLabel.center.y};
    
    UITapGestureRecognizer *valueTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCountryValue:)];
    valueTapGesture.delegate = self;
    [_countryLabel addGestureRecognizer:valueTapGesture];
    
    UIView *backView1 = [[UIView alloc] initWithFrame:(CGRect){{backView0.left, backView0.bottom + kCellSpace}, {headView.frame.size.width - 60.0f, kCellHeight}}];
    backView1.backgroundColor = [UIColor whiteColor];
    backView1.layer.cornerRadius =2.0f;
    backView1.layer.borderWidth = lineWidth;
    backView1.layer.borderColor = [kFontLineGrayColor CGColor];
    backView1.layer.masksToBounds = YES;
    [headView addSubview:backView1];
    
    NSString *title;
    NSString *placeholder;
    NSInteger keyboardType;
    UIColor *color;
    CGFloat bottom;
    
    title = @"邮箱";
    placeholder = NSLocalizedString(@"请填写邮箱地址",nil);
    keyboardType = UIKeyboardTypeURL;
    color = kTextColor_MB;
    
    UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView0.height}}];
    titleLabel1.userInteractionEnabled = YES;
    titleLabel1.backgroundColor = [UIColor whiteColor];
    titleLabel1.adjustsFontSizeToFitWidth = YES;
    titleLabel1.font = [UIFont systemFontOfSize:14.0f];
    titleLabel1.text = title;
    titleLabel1.textAlignment = NSTextAlignmentLeft;
    titleLabel1.textColor = color;
    [backView1 addSubview:titleLabel1];
    
    _phoneTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {180.0f, backView1.height}}];
    _phoneTextField.backgroundColor = [UIColor whiteColor];
    _phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _phoneTextField.adjustsFontSizeToFitWidth = YES;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _phoneTextField.placeholder = placeholder;
    _phoneTextField.font = [UIFont systemFontOfSize:14.0f];
    _phoneTextField.textAlignment = NSTextAlignmentLeft;
    _phoneTextField.textColor = color;
    _phoneTextField.tag = 1000;
    [_phoneTextField setDelegate:self];
    _phoneTextField.returnKeyType = UIReturnKeyNext;
    [backView1 addSubview:_phoneTextField];
    
    bottom = backView1.bottom + kCellSpace;
    
    CGFloat buttonWidth = 85.0f;
    UIView *backView2 = [[UIView alloc] initWithFrame:(CGRect){{backView1.left, bottom}, {backView1.width - buttonWidth - 10.0f, backView1.height}}];
    backView2.backgroundColor = [UIColor whiteColor];
    backView2.layer.cornerRadius =2.0f;
    backView2.layer.borderWidth = lineWidth;
    backView2.layer.borderColor = [kFontLineGrayColor CGColor];
    backView2.layer.masksToBounds = YES;
    [headView addSubview:backView2];
    
    _securityCodeTextField = [[UITextField alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {backView2.width - 15.0f, backView2.height}}];
    _securityCodeTextField.backgroundColor = [UIColor clearColor];
    _securityCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _securityCodeTextField.adjustsFontSizeToFitWidth = YES;
    _securityCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _securityCodeTextField.borderStyle = UITextBorderStyleNone;
    _securityCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _securityCodeTextField.font = [UIFont systemFontOfSize:14.0f];
    _securityCodeTextField.textAlignment = NSTextAlignmentLeft;
    _securityCodeTextField.placeholder = NSLocalizedString(@"输入的验证码",nil);
    _securityCodeTextField.textColor = color;
    _securityCodeTextField.tag = 1001;
    [_securityCodeTextField setDelegate:self];
    _securityCodeTextField.returnKeyType = UIReturnKeyNext;
    [backView2 addSubview:_securityCodeTextField];
    
    _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _checkButton.backgroundColor = [UIColor whiteColor];
    _checkButton.layer.cornerRadius = 4.0f;
    _checkButton.layer.borderWidth = lineWidth;
    _checkButton.layer.borderColor = [kYellowColor CGColor];
    _checkButton.layer.masksToBounds = YES;
    _checkButton.frame = CGRectMake((headView.frame.size.width - backView1.left - buttonWidth), (backView2.top + (backView2.height - kCellHeight) / 2.0f), buttonWidth, backView2.height);
    //    [_checkButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    [_checkButton setTitle:NSLocalizedString(@"获取验证码",nil) forState:UIControlStateNormal];
    _checkButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_checkButton setTitleColor:kYellowColor forState:UIControlStateNormal];
    [_checkButton setTitleColor:kFontGrayColor forState:UIControlStateHighlighted];
    [_checkButton addTarget:self action:@selector(getSecurityCode:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_checkButton];
    
    bottom = backView2.bottom + kCellSpace;
    
    UIView *backView3 = [[UIView alloc] initWithFrame:(CGRect){{backView1.left, bottom}, backView1.frame.size}];
    backView3.backgroundColor = [UIColor whiteColor];
    backView3.layer.cornerRadius =2.0f;
    backView3.layer.borderWidth = lineWidth;
    backView3.layer.borderColor = [kFontLineGrayColor CGColor];
    backView3.layer.masksToBounds = YES;
    [headView addSubview:backView3];
    
    UILabel *titleLabel3 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView0.height}}];
    titleLabel3.backgroundColor = [UIColor whiteColor];
    titleLabel3.adjustsFontSizeToFitWidth = YES;
    titleLabel3.font = [UIFont systemFontOfSize:14.0f];
    titleLabel3.text = NSLocalizedString(@"密码",nil);
    titleLabel3.textAlignment = NSTextAlignmentLeft;
    titleLabel3.textColor = color;
    [backView3 addSubview:titleLabel3];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView3.width - width - backView3.height, backView3.height}}];
    _passwordTextField.backgroundColor = [UIColor clearColor];
    _passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordTextField.adjustsFontSizeToFitWidth = YES;
    _passwordTextField.borderStyle = UITextBorderStyleNone;
    _passwordTextField.keyboardType = UIKeyboardTypeDefault;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.placeholder = NSLocalizedString(@"至少8位，英文与数字组合",nil);
    _passwordTextField.font = [UIFont systemFontOfSize:14.0f];
    _passwordTextField.textAlignment = NSTextAlignmentLeft;
    _passwordTextField.textColor = color;
    _passwordTextField.tag = 1002;
    _passwordTextField.returnKeyType = UIReturnKeyNext;
    [_passwordTextField setDelegate:self];
    [backView3 addSubview:_passwordTextField];
    
    _eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _eyeButton.frame = CGRectMake(backView3.width - backView3.height, 0, backView3.height, backView3.height);
    _eyeButton.backgroundColor = [UIColor clearColor];
    [_eyeButton setImage:RCHIMAGEWITHNAMED(@"password_hide") forState:UIControlStateNormal];
    [_eyeButton addTarget:self action:@selector(eyeChange:) forControlEvents:UIControlEventTouchUpInside];
    [backView3 addSubview:_eyeButton];
    
    bottom = backView3.bottom + kCellSpace;
    
    UIView *backView4 = [[UIView alloc] initWithFrame:(CGRect){{backView1.left, bottom}, backView1.frame.size}];
    backView4.backgroundColor = [UIColor whiteColor];
    backView4.layer.cornerRadius =2.0f;
    backView4.layer.borderWidth = lineWidth;
    backView4.layer.borderColor = [kFontLineGrayColor CGColor];
    backView4.layer.masksToBounds = YES;
    [headView addSubview:backView4];
    
    UILabel *titleLabel4 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView0.height}}];
    titleLabel4.backgroundColor = [UIColor whiteColor];
    titleLabel4.adjustsFontSizeToFitWidth = YES;
    titleLabel4.font = [UIFont systemFontOfSize:14.0f];
    titleLabel4.text = NSLocalizedString(@"推荐ID",nil);
    titleLabel4.textAlignment = NSTextAlignmentLeft;
    titleLabel4.textColor = color;
    [backView4 addSubview:titleLabel4];
    
    _invitationCodeTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView4.width - width, backView4.height}}];
    _invitationCodeTextField.backgroundColor = [UIColor clearColor];
    _invitationCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _invitationCodeTextField.adjustsFontSizeToFitWidth = YES;
    _invitationCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _invitationCodeTextField.borderStyle = UITextBorderStyleNone;
    _invitationCodeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _invitationCodeTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _invitationCodeTextField.secureTextEntry = NO;
    _invitationCodeTextField.placeholder = NSLocalizedString(@"选填",nil);
    _invitationCodeTextField.font = [UIFont systemFontOfSize:14.0f];
    _invitationCodeTextField.textAlignment = NSTextAlignmentLeft;
    _invitationCodeTextField.textColor = color;
    _invitationCodeTextField.tag = 1003;
    _invitationCodeTextField.returnKeyType = UIReturnKeyNext;
    [_invitationCodeTextField setDelegate:self];
    [backView4 addSubview:_invitationCodeTextField];
    
    headView.frame = (CGRect){headView.frame.origin, {headView.width, backView4.bottom}};
    
    return headView;
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

    UILabel *agreementLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    agreementLabel.font = [UIFont systemFontOfSize:14.0f];
    agreementLabel.backgroundColor = [UIColor clearColor];
    agreementLabel.textAlignment = NSTextAlignmentLeft;
    agreementLabel.textColor = kFontLightGrayColor;
    agreementLabel.text = NSLocalizedString(@"注册表示您已阅读并同意",nil);
    [footView addSubview:agreementLabel];
    [agreementLabel sizeToFit];
    
    NSString *text = NSLocalizedString(@"《服务协议》",nil);
    UIButton *agreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    agreementButton.frame = (CGRect){{0.0f, 0.0f}, {200.0f, 20.0f}};
    agreementButton.backgroundColor = [UIColor clearColor];
    [agreementButton setTitle:text forState:UIControlStateNormal];
    [agreementButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [agreementButton setTitleColor:kYellowColor forState:UIControlStateNormal];
    [agreementButton addTarget:self action:@selector(agreementbuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:agreementButton];
    [agreementButton sizeToFit];
    
    
    CGFloat left = 30.0f;
    CGSize size = (CGSize){frame.size.width - left * 2, 40.0f};
    _registerLabel = [[UILabel alloc] initWithFrame:(CGRect){{left, 10.0f}, size}];
    _registerLabel.backgroundColor = kPlaceholderColor;
    _registerLabel.layer.cornerRadius =4.0f;
    _registerLabel.userInteractionEnabled = YES;
    _registerLabel.layer.masksToBounds = YES;
    _registerLabel.font = [UIFont systemFontOfSize:14.0f];
    _registerLabel.textAlignment = NSTextAlignmentCenter;
    _registerLabel.text = NSLocalizedString(@"立即注册",nil);
    _registerLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_registerLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerButtonClicked:)];
    tapGesture.delegate = self;
    [_registerLabel addGestureRecognizer:tapGesture];
    
    
    CGFloat originX = (self.view.width - agreementLabel.width - agreementButton.width - 2.0f) / 2.0f;
    agreementLabel.frame =(CGRect){{originX, _registerLabel.bottom + kCellSpace}, agreementLabel.frame.size};
    agreementButton.frame = (CGRect){{agreementLabel.right + 2.0f, agreementLabel.top}, agreementButton.frame.size};
    agreementButton.center = (CGPoint){agreementButton.center.x, agreementLabel.center.y};
    
    return footView;
}

- (void)getCountries
{
    RCHWeak(self);
    __block NSMutableArray *blockTitles = _titles;
    __block NSMutableArray *blockCountries = _countries;
    if (weakself.countryRequest.currentTask) {
        [weakself.countryRequest.currentTask cancel];
    }
    
    [weakself.countryRequest countries:^(NSObject *response) {
        if ([response isKindOfClass:[NSArray class]]) {
            NSArray *countries = (NSMutableArray *)response;
            [blockTitles removeAllObjects];
            [blockCountries removeAllObjects];
            for (RCHCountry *country in countries) {
                if (country.name_en) {
                    if (country.countryId == 29) {
                        [blockTitles insertObject:country.name_en atIndex:0];
                        [blockCountries insertObject:country atIndex:0];
                    } else {
                        [blockTitles addObject:country.name_en];
                        [blockCountries addObject:country];
                    }
                    
                }
                
            }
            
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    }];

}


- (void)sendToRegister
{
    
    if(_securityCodeTextField.text == nil
       || _passwordTextField.text == nil
       || _phoneTextField.text == nil
       || (_securityCodeTextField.text && [[_securityCodeTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
       || (_passwordTextField.text && [[_passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
       || (_phoneTextField.text && [[_phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])){
        [MBProgressHUD showSuccess:NSLocalizedString(@"请完整填写注册信息",nil) ToView:self.view];
        return;
    }
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    
    NSString *name = [_phoneTextField.text lowercaseString];
    NSString *password = _passwordTextField.text;
    NSString *channel = _invitationCodeTextField.text;
    NSString *verifyCode = _securityCodeTextField.text;
    NSMutableDictionary  *referral = [NSMutableDictionary dictionary];
    [referral setObject:channel forKey:@"channel"];
    
    NSMutableDictionary  *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSNumber numberWithInteger:_countryId] forKey:@"country"];
    [dictionary setObject:@"" forKey:@"mobile"];
    [dictionary setObject:name forKey:@"email"];
    [dictionary setObject:password forKey:@"password"];
    [dictionary setObject:referral forKey:@"referral"];
    
    NSMutableDictionary *user = [NSMutableDictionary dictionary];
    [user setObject:dictionary forKey:@"register"];
    
    if (self.registerRequest.currentTask) {
        [self.registerRequest.currentTask cancel];
    }

////    TEST
//    [[NSNotificationCenter defaultCenter] postNotificationName:kRegisterDidSuccessNotification object:nil];
//    [self.navigationController popViewControllerAnimated:YES];
//    [RCHHelper setValue:@"123@123.com" forKey:kCurrentRememberName];
//    return;
    
    [MBProgressHUD showLoadToView:self.view];
    
    RCHWeak(self);
    [self.registerRequest registers:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            [MBProgressHUD showError:kVerifyCodeError ToView:self.view];
            return;
        }
        
        NSString *cookie = [response.headers objectForKey:@"Set-Cookie"];
        [RCHHelper setValue:cookie forKey:kCurrentCookie];
        
        [RCHHelper setValue:name forKey:kCurrentUserName];
        [RCHHelper setValue:name forKey:kCurrentRememberName];
        [RCHHelper setValue:name forKey:kCurrentUserEmail];
        [RCHHelper savePassword:password forUserName:name];
        
        if ([RCHHelper valueForKey:kCurrentUserEmail]) {
            [Appsee setUserID:[RCHHelper valueForKey:kCurrentUserEmail]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kRegisterDidSuccessNotification object:nil];
        [weakself.navigationController popViewControllerAnimated:YES];
        
//         [weakself getMemberInfo];
    } user:user verifyCode:verifyCode];
    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kRegisterDidSuccessNotification object:nil];
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    }];
}

- (void)checkEmail:(NSString *)email
{
    [MBProgressHUD showLoadToView:self.view];
    RCHWeak(self);
    RCHWeak(_checkButton);
    if (weakself.checkEmailRequest.currentTask) {
        [weakself.checkEmailRequest.currentTask cancel];
    }
    
    [weakself.checkEmailRequest checkEmail:^(NSError *error, NSObject *response) {        
        if (error) {
            [MBProgressHUD hideHUDForView:self.view];
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            if (code == 400) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"邮箱已存在，请直接登录",nil) ToView:self.view];
                return;
            }
            [RCHHelper showRequestErrorCode:code url:url];
            return;
        } else {
            [weakself sendSecurityCode:weak_checkButton];
        }
    } email:email];
}

- (BOOL)isValidateMobile:(NSString *)mobile{
    //手机号以13、15、18开头，八个\d数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
    
}

- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


- (BOOL)checkPassword:(NSString*) password
{
    NSString*pattern =@"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,50}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

- (BOOL)checkAvailable
{
    if(_securityCodeTextField.text == nil
       || _passwordTextField.text == nil
       || _phoneTextField.text == nil
       || (_securityCodeTextField.text && ([_securityCodeTextField.text length] < 2))
       || (_passwordTextField.text && ([_passwordTextField.text length] < 2))
       || (_phoneTextField.text && ([_phoneTextField.text length] < 2))){
        _registerLabel.backgroundColor = kPlaceholderColor;
        return NO;
    } else {
        _registerLabel.backgroundColor = kLoginButtonColor;
        return YES;
    }
}


#pragma mark -
#pragma mark - button clicked
- (void)getSecurityCode:(id)sender
{
    if ([self isValidateEmail:_phoneTextField.text]) {
        [self checkEmail:_phoneTextField.text];
    } else {
        [MBProgressHUD showError:NSLocalizedString(@"邮箱格式错误，请重新输入",nil) ToView:self.view];
    }
}

- (void)registerButtonClicked:(id)sender
{
    if (![self checkAvailable]) {
        return;
    }
    
    if (![self isValidateEmail:_phoneTextField.text]) {
        [MBProgressHUD showError:NSLocalizedString(@"邮箱格式错误，请重新输入",nil) ToView:self.view];
        return;
    }
    
    if (_countryId == 0) {
        [MBProgressHUD showError:NSLocalizedString(@"请选择您所在的国家",nil) ToView:self.view];
        return;
    }
    
    if (![self checkPassword:_passwordTextField.text]) {
        [MBProgressHUD showError:NSLocalizedString(@"密码至少8位，英文与数字组合",nil) ToView:self.view];
        return;
    }
    
    [self sendToRegister];
}

- (void)sendSecurityCode:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    RCHWeak(self);
    if (weakself.securityCodeRequest.currentTask) {
        [weakself.securityCodeRequest.currentTask cancel];
    }
    
    [weakself.securityCodeRequest sendVerifyCode:^(NSError *error, WDBaseResponse *response) {
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
        }
    } email:_phoneTextField.text];
}

- (void)agreementbuttonClicked:(id)sender
{
    RCHWebViewController *webviewController = [[RCHWebViewController alloc] init];
    webviewController.gotoURL = kRegisterHelpUrl;
    webviewController.title = NSLocalizedString(@"服务协议",nil);
    [self.navigationController pushViewController:webviewController animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    [self checkAvailable];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    [self registerButtonClicked:_registerLabel];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkAvailable];
}


#pragma mark -
#pragma mark - UIGestureRecognizer
- (void)changeCountryValue:(UITapGestureRecognizer*)tapGesture
{
    NSString *title = NSLocalizedString(@"",nil);
    MJLPickerActionSheetType type = MJLPickerActionSheetTypeDefault;
    NSObject *object = @[_titles];
    MJLPickerActionSheet *pickerView = [[MJLPickerActionSheet alloc] initWithTitle:title object:object key:@"country" type:type];
    [pickerView show];
    pickerView.delegate = self;
    [[[UIApplication sharedApplication] keyWindow] addSubview:pickerView];
    
    [_securityCodeTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_invitationCodeTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
}

#pragma mark -
#pragma mark - MJLPickerActionSheetDelegate

- (void)pickerActionSheet:(MJLPickerActionSheet *)sheet didPickerStrings:(NSArray *)pickedStrings key:(NSString *)key
{
    if ([pickedStrings count] > 0) {
        NSDictionary *dic = [pickedStrings objectAtIndex:0];
        NSString *name = [dic objectForKey:@"text"];
        NSInteger index = [[dic objectForKey:@"index"] integerValue];
        if ([key isEqualToString:@"country"]) {
            if (name && ![name isKindOfClass:[NSNull class]]) {
                if ([_countries count] > index) {
                    RCHCountry *country = [_countries objectAtIndex:index];
                    _countryId = [country countryId];
                } else {
                    _countryId = 0;
                }
                _country = name;
                [self initCustomView];
            }
        } else if ([key isEqualToString:@"type"]) {
            if (name && ![name isKindOfClass:[NSNull class]]) {
                [self initCustomView];
            }
            
        } else {
            
        }
        
    }
}


#pragma mark -
#pragma mark - getter

- (RCHCheckEmailRequest *)checkEmailRequest
{
    if(_checkEmailRequest == nil)
    {
        _checkEmailRequest = [[RCHCheckEmailRequest alloc] init];
    }
    return _checkEmailRequest;
}

- (RCHSecurityCodeRequest *)securityCodeRequest
{
    if(_securityCodeRequest == nil)
    {
        _securityCodeRequest = [[RCHSecurityCodeRequest alloc] init];
    }
    return _securityCodeRequest;
}

- (RCHRegisterRequest *)registerRequest
{
    if(_registerRequest == nil)
    {
        _registerRequest = [[RCHRegisterRequest alloc] init];
    }
    return _registerRequest;
}

- (RCHMemberRequest *)memberRequest
{
    if(_memberRequest == nil)
    {
        _memberRequest = [[RCHMemberRequest alloc] init];
    }
    return _memberRequest;
}

- (RCHCountryRequest *)countryRequest
{
    if(_countryRequest == nil)
    {
        _countryRequest = [[RCHCountryRequest alloc] init];
    }
    return _countryRequest;
}

@end
