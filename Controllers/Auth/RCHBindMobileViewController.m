//
//  RCHBindMobileViewController.m
//  richcore
//
//  Created by WangDong on 2018/6/12.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHBindMobileViewController.h"
#import "MJLPickerActionSheet.h"

#import "RCHSecurityCodeRequest.h"
#import "RCHCountryRequest.h"
#import "RCHBindRequest.h"
#import "JSONKit.h"

#define kCellHeight 44.0f
#define kCellSpace 15.0f

@interface RCHBindMobileViewController () <UIGestureRecognizerDelegate, MJLPickerActionSheetDelegate>
{
    UILabel *_countryLabel;
    UITextField *_phoneTextField;
    UITextField *_messageTextField;
    UITextField *_securityCodeTextField;
    UILabel *_submitLabel;
    UIView *_headerView;
    UIView *_footerView;
    
    NSString *_country;
    NSInteger _countryId;
    NSMutableArray *_titles;
    NSMutableArray *_countries;
    
    UIButton *_checkButton;
}

@property (nonatomic, strong) RCHSecurityCodeRequest *securityCodeRequest;
@property (nonatomic, strong) RCHCountryRequest *countryRequest;
@property (nonatomic, strong) RCHBindRequest *bindRequest;
@property (nonatomic, strong) dispatch_source_t timer;

@end


@implementation RCHBindMobileViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定手机验证";
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
        country.name_en = @"China";
        country.code = @"0086";
        [_countries addObject:country];
        [_titles addObject:[[_countries objectAtIndex:0] name_en]];
        _countryId = country.countryId;
        _country = [self getCountryCode:country];
    }
    
    [self getCountries];
}

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
    
    UIImage *image = RCHIMAGEWITHNAMED(@"ico_arrow_country");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, image.size}];
    imageView.image = image;
    [backView0 addSubview:imageView];
    
    CGFloat countryWidth = 59.0f;
    _countryLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, 0.0f}, {countryWidth - originX, backView0.height}}];;
    _countryLabel.userInteractionEnabled = YES;
    _countryLabel.backgroundColor = [UIColor clearColor];
    _countryLabel.adjustsFontSizeToFitWidth = YES;
    _countryLabel.font = [UIFont systemFontOfSize:16.0f];
    _countryLabel.text = _country;
    _countryLabel.textAlignment = NSTextAlignmentLeft;
    _countryLabel.textColor = kTextColor_MB;
    [backView0 addSubview:_countryLabel];
    
    imageView.center = (CGPoint){_countryLabel.right + (image.size.width / 2.0f), _countryLabel.center.y};
    
    UITapGestureRecognizer *valueTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCountryValue:)];
    valueTapGesture.delegate = self;
    [_countryLabel addGestureRecognizer:valueTapGesture];
    
    CGFloat phoneOriginX = 87.0f;
    _phoneTextField = [[UITextField alloc] initWithFrame:(CGRect){{phoneOriginX, 0.0f}, {backView0.width - phoneOriginX - originX , backView0.height}}];
    _phoneTextField.backgroundColor = [UIColor whiteColor];
    _phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _phoneTextField.adjustsFontSizeToFitWidth = YES;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; //默认首字母小写
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.placeholder = @"输入你的手机号";
    _phoneTextField.font = [UIFont systemFontOfSize:14.0f];
    _phoneTextField.textAlignment = NSTextAlignmentLeft;
    _phoneTextField.textColor = color;
    _phoneTextField.tag = 1000;
    [_phoneTextField setDelegate:self];
    _phoneTextField.returnKeyType = UIReturnKeyNext;
    [backView0 addSubview:_phoneTextField];
    
    CGFloat bottom = backView0.bottom + kCellSpace;
    
    CGFloat buttonWidth = 85.0f;
    UIView *backView1 = [[UIView alloc] initWithFrame:(CGRect){{backView0.left, bottom}, {backView0.width - buttonWidth - 10.0f, backView0.height}}];
    backView1.backgroundColor = [UIColor whiteColor];
    backView1.layer.cornerRadius =2.0f;
    backView1.layer.borderWidth = lineWidth;
    backView1.layer.borderColor = [kFontLineGrayColor CGColor];
    backView1.layer.masksToBounds = YES;
    [headView addSubview:backView1];
    
    _messageTextField = [[UITextField alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {backView1.width - 15.0f, backView1.height}}];
    _messageTextField.backgroundColor = [UIColor clearColor];
    _messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _messageTextField.adjustsFontSizeToFitWidth = YES;
    _messageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _messageTextField.borderStyle = UITextBorderStyleNone;
    _messageTextField.keyboardType = UIKeyboardTypeNumberPad;
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
    [_checkButton addTarget:self action:@selector(getSecurityCode:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_checkButton];
    
    if (!hasGoogleAuth) {
        bottom = backView1.bottom;
    } else {
        bottom = backView1.bottom + kCellSpace;
        UIView *backView2 = [[UIView alloc] initWithFrame:(CGRect){{backView0.left, bottom}, backView0.frame.size}];
        backView2.backgroundColor = [UIColor whiteColor];
        backView2.layer.cornerRadius =2.0f;
        backView2.layer.borderWidth = lineWidth;
        backView2.layer.borderColor = [kFontLineGrayColor CGColor];
        backView2.layer.masksToBounds = YES;
        [headView addSubview:backView2];
        
        
        _securityCodeTextField = [[UITextField alloc] initWithFrame:(CGRect){{originX, 0.0f}, {backView2.width - originX * 2, backView2.height}}];
        _securityCodeTextField.backgroundColor = [UIColor clearColor];
        _securityCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _securityCodeTextField.adjustsFontSizeToFitWidth = YES;
        _securityCodeTextField.borderStyle = UITextBorderStyleNone;
        _securityCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _securityCodeTextField.secureTextEntry = NO;
        _securityCodeTextField.placeholder = NSLocalizedString(@"输入谷歌验证码",nil);
        _securityCodeTextField.font = [UIFont systemFontOfSize:14.0f];
        _securityCodeTextField.textAlignment = NSTextAlignmentLeft;
        _securityCodeTextField.textColor = color;
        _securityCodeTextField.tag = 1002;
        _securityCodeTextField.returnKeyType = UIReturnKeyNext;
        [_securityCodeTextField setDelegate:self];
        [backView2 addSubview:_securityCodeTextField];
        
        bottom = backView2.bottom;
    }
    
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
    _submitLabel.text = NSLocalizedString(@"提交",nil);
    _submitLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_submitLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bindButtonClicked:)];
    tapGesture.delegate = self;
    [_submitLabel addGestureRecognizer:tapGesture];
    

    return footView;
}

- (BOOL)isValidateMobile:(NSString *)mobile{
    //手机号以13、15、18开头，八个\d数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
    
}

- (BOOL)checkPhone
{
    if (RCHIsEmpty(_phoneTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"手机号不能为空",nil) ToView:self.view];
        return NO;
    }
    
    
    if (![self isValidateMobile:_phoneTextField.text]) {
        [MBProgressHUD showError:NSLocalizedString(@"请输入正确的手机号码",nil) ToView:self.view];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkAvailable
{
    if (![self checkPhone]) {
        return NO;
    }
    
    
    if (RCHIsEmpty(_messageTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"短信验证码不能为空",nil) ToView:self.view];
        return NO;
    }
    
    BOOL hasGoogleAuth = [[RCHHelper valueForKey:kCurrentUserGoogleAuth] boolValue];
    if (hasGoogleAuth) {
        if (RCHIsEmpty(_securityCodeTextField.text)) {
            [MBProgressHUD showError:NSLocalizedString(@"谷歌验证码不能为空",nil) ToView:self.view];
            return NO;
        }
    }

    if (_countryId == 0) {
        [MBProgressHUD showError:NSLocalizedString(@"请选择您所在的国家",nil) ToView:self.view];
        return NO;
    }
    
    return YES;
}

- (NSString *)getCountryCode:(RCHCountry *)country
{
    NSString *defaultString = @"+86";
    if (!RCHIsEmpty(country) && !RCHIsEmpty(country.code)) {
        return [RCHHelper getCountryCode:country.code];
    } else {
        return defaultString;
    }
}


#pragma mark -
#pragma mark - request

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
                NSString *code = [self getCountryCode:country];
                if (country.name_en) {
                    if (country.countryId == 29) {
                        [blockTitles insertObject:[NSString stringWithFormat:@"%@ %@", country.name_en, code ] atIndex:0];
                        [blockCountries insertObject:country atIndex:0];
                    } else {
                        [blockTitles addObject:[NSString stringWithFormat:@"%@ %@", country.name_en, code]];
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

- (void)sendSecurityCode:(id)sender
{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    RCHWeak(self);
    if (weakself.securityCodeRequest.currentTask) {
        [weakself.securityCodeRequest.currentTask cancel];
    }
    
    [MBProgressHUD showLoadToView:self.view];
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
    } mobile:_phoneTextField.text prefix:_countryId];
}

- (void)sendBindRequest
{
    RCHWeak(self);
    if (weakself.bindRequest.currentTask) {
        [weakself.bindRequest.currentTask cancel];
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:_messageTextField.text forKey:@"code"];
    [info setObject:_phoneTextField.text forKey:@"mobile"];
    [info setObject:[NSString stringWithFormat:@"%ld", (long)_countryId] forKey:@"phonePrefix"];
    BOOL hasGoogleAuth = [[RCHHelper valueForKey:kCurrentUserGoogleAuth] boolValue];
    if (hasGoogleAuth) {
        [info setObject:_securityCodeTextField.text forKey:@"googleCode"];
    }
    
    [MBProgressHUD showLoadToView:self.view];
    [weakself.bindRequest bind:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            NSString *errorInfo = [[NSString alloc] initWithData:(NSData *)((WDBaseResponse *)response).error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", errorInfo);
            if (errorInfo) {
                NSDictionary *resultDictionary = [errorInfo objectFromJSONString];
                NSString *message = [resultDictionary objectForKey:@"message"];
                
                if ([message isEqualToString:@"bad code"]) {
                    message = NSLocalizedString(@"短信验证码错误", nil);
                } else if ([message isEqualToString:@"bad verify code"]) {
                    message = NSLocalizedString(@"谷歌验证码错误", nil);
                } else {
                    message = @"绑定失败，请重试";
                }
                [MBProgressHUD showError:message ToView:self.view];
            } else {
                NSInteger code = ((WDBaseResponse *)response).statusCode;
                NSString *url = ((WDBaseResponse *)response).urlString;
                [RCHHelper showRequestErrorCode:code url:url];
            }

        } else {
            [MBProgressHUD showSuccess:NSLocalizedString(@"绑定成功",nil) ToView:self.view];
            [RCHHelper setValue:[info objectForKey:@"mobile"] forKey:kCurrentUserMobile];
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetMemverNotification object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } parameters:info];
}


#pragma mark -
#pragma mark - button clicked
- (void)getSecurityCode:(id)sender
{
    if ([self checkPhone]) {
        [self sendSecurityCode:_checkButton];
    }
}

- (void)bindButtonClicked:(id)sender
{
    if (![self checkAvailable]) {
        return;
    }
    
    [self sendBindRequest];
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
    [self bindButtonClicked:_submitLabel];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    [self checkAvailable];
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
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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
                    _country = [self getCountryCode:country];
                } else {
                    _countryId = 29;
                    _country = @"+86";
                }
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

- (RCHSecurityCodeRequest *)securityCodeRequest
{
    if(_securityCodeRequest == nil)
    {
        _securityCodeRequest = [[RCHSecurityCodeRequest alloc] init];
    }
    return _securityCodeRequest;
}

- (RCHCountryRequest *)countryRequest
{
    if(_countryRequest == nil)
    {
        _countryRequest = [[RCHCountryRequest alloc] init];
    }
    return _countryRequest;
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
