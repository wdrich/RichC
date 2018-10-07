//
//  RCHGoogleAuthController.m
//  MeiBe
//
//  Created by WangDong on 2018/3/7.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHGoogleAuthController.h"
#import "RCHGoogleRequest.h"

#define kNumbers     @"0123456789 "

@interface RCHGoogleAuthController () <UIGestureRecognizerDelegate>
{
    UILabel *_submitLabel;
    UILabel *_authCodeLabel;
    
    UIView *_headerView;
    UIView *_footerView;
    UITextField *_keyTextField;
    
    RCHGoogleAuth _googleAuthType;
    RCHGoogleRequest *_googleRequest;
}

@property (nonatomic, strong) UILabel *submitLabel;
@property (nonatomic, strong) NSString *googleSecret;
@property (nonatomic, strong) RCHGoogleRequest *googleRequest;

@end

@implementation RCHGoogleAuthController

- (id)initWithGoogleAuthType:(RCHGoogleAuth)type
{
    if(self = [super init]) {
        _googleAuthType = type;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_googleAuthType == RCHGoogleAuthTypeBackup && !_googleSecret) {
        [self getGoogleRequest];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    [self initCustomView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - overWrite

- (BOOL)textViewControllerEnableAutoToolbar:(RCHTextViewController *)textViewController
{
    return NO;
}

#pragma mark -
#pragma mark - CustomFunction

- (void)initCustomView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    
    NSString *imageName = nil;
    NSString *description =nil;
    NSString *key = nil;
    NSString *navigationTitle = nil;
    NSString *submitTitle = nil;
    CGFloat originY = 50.0f;
    CGFloat headerHeight = 0.0f;
    CGFloat footerHeight = 60.0f;
    
//    CGFloat height = [RCHHelper getMainViewHeightExcepTopAndBottomView:self.navigationController];
    CGFloat footerOriginY = self.view.height - footerHeight;
    
    if (_googleAuthType == RCHGoogleAuthTypeBackup) {
        headerHeight = 340.0f;
        navigationTitle= NSLocalizedString(@"备份密钥",nil);
        imageName = @"ico_google_write";
        description = NSLocalizedString(@"请把下方的密匙抄写下来，并保存在安全的地方。如果您的手机丢失，可以通过该密钥恢复谷歌验证。", nil);
        key = _googleSecret;
        submitTitle= NSLocalizedString(@"下一步",nil);
        originY = 50.0f - 2.0f;
        
    } else if (_googleAuthType == RCHGoogleAuthTypeInput) {
        headerHeight = 190.0f;
        navigationTitle= NSLocalizedString(@"输入密钥",nil);
        imageName = nil;
        description = NSLocalizedString(@"请输入刚才备份的16位密钥", nil);
        key = nil;
        submitTitle= NSLocalizedString(@"下一步",nil);
        originY = 40.0f - 2.0f;
        footerOriginY = headerHeight + 30.0f + kAppOriginY;
    } else if (_googleAuthType == RCHGoogleAuthTypeGuidelines) {
        headerHeight = 118.0f;
        navigationTitle= NSLocalizedString(@"设置验证码",nil);
        imageName = nil;
        description = NSLocalizedString(@"您需要在谷歌验证器App中添加一个富矿账户，并手动输入16位密钥", nil);
        key = nil;
        originY = 40.0f - 2.0f;
        submitTitle= NSLocalizedString(@"下一步",nil);
    } else if (_googleAuthType == RCHGoogleAuthTypeSubmit) {
        headerHeight = 190.0f;
        navigationTitle= NSLocalizedString(@"谷歌二次验证",nil);
        imageName = nil;
        description = NSLocalizedString(@"请输入谷歌两步验证器中的6位数字", nil);
        key = nil;
        submitTitle= NSLocalizedString(@"提交",nil);
        originY = 40.0f - 2.0f;
        footerOriginY = headerHeight + 30.0f + kAppOriginY;
    } else if (_googleAuthType == RCHGoogleAuthTypeDownload) {
        headerHeight = 260.0f;
        navigationTitle= NSLocalizedString(@"下载并安装",nil);
        imageName = @"google";
        description = NSLocalizedString(@"首先，在手机上安装谷歌两步验证器（Google Authenticator）", nil);
        key = nil;
        submitTitle= NSLocalizedString(@"下一步",nil);
        originY = 50.0f;
    }
    
    self.navigationItem.title = navigationTitle;
    
    _headerView = [self createHeaderView:(CGRect){{0.0f, kAppOriginY}, {kMainScreenWidth, headerHeight}} imageName:imageName description:description key:key originY:originY];
    [self.view addSubview:_headerView];
    
    _footerView = [self createFootView:(CGRect){{0.0f, footerOriginY }, {kMainScreenWidth, 60.0f}} submitTitle:submitTitle];
    [self.view addSubview:_footerView];
    
    if (_googleAuthType == RCHGoogleAuthTypeGuidelines) {
        UIImage *image = RCHIMAGEWITHNAMED(@"pic_account");
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = (CGRect){{(self.view.width - image.size.width) / 2.0f, headerHeight + kAppOriginY}, image.size};
        imageView.contentMode = UIViewContentModeCenter;
        [self.view addSubview:imageView];
    } else if (_googleAuthType == RCHGoogleAuthTypeDownload) {
        CGFloat height = 40.0f;
        CGFloat originX = 20.0f;
        CGFloat width = 90.0f;
        
        CGFloat lineWidth;
        if (isRetina) {
            lineWidth = 0.5f;
        } else {
            lineWidth = 1.0f;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){{0.0f, _headerView.bottom + 10.0f}, {kMainScreenWidth, 60.0f}}];
        [self.view addSubview:view];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.userInteractionEnabled = YES;
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = @"Google Authenticator for iOS";
        titleLabel.textColor = kFontBlackColor;
        [view addSubview:titleLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = 4.0f;
        button.layer.borderWidth = lineWidth;
        button.layer.borderColor = [kYellowColor CGColor];
        button.layer.masksToBounds = YES;
        button.frame = CGRectMake((view.width - originX - width), (view.height - height) / 2.0f, width, height);
        //    [button setBackgroundImage:[image stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"下载",nil) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [button setTitleColor:kYellowColor forState:UIControlStateNormal];
        [button setTitleColor:kFontGrayColor forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
}


- (UIView *)createHeaderView:(CGRect)rect imageName:(NSString *)imageName description:(NSString *)description key:(NSString *)key originY:(CGFloat)originY
{
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    headView.backgroundColor = RGBA(255.0, 255.0f, 255.0f, 1.0f);
    CGFloat labelWidth = 315.0f;
    CGFloat originX = (self.view.width - labelWidth) / 2.0f;
    UIImageView *imageView = nil;
    UILabel *descriptionLabel = nil;
    UIView *inputView = nil;
    
    if (imageName && ![imageName isEmptyOrWhitespace]) {
        UIImage *image = RCHIMAGEWITHNAMED(imageName);
        imageView = [[UIImageView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, image.size}];
        imageView.contentMode = UIViewContentModeCenter;
        [imageView setImage:image];
        imageView.center = CGPointMake(headView.center.x, 0.0f);
        [headView addSubview:imageView];
    }
 
    if (description && ![imageName isEmptyOrWhitespace]) {
        descriptionLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, 0.0f}, {labelWidth, 0.0f}}];
        descriptionLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0f];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.textColor = kFontBlackColor;
        //    descriptionLabel.text = description;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1.1];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [description length])];
        [attributedString addAttribute:NSFontAttributeName value:descriptionLabel.font range:NSMakeRange(0, [description length])];
        descriptionLabel.attributedText = attributedString;
        
        [headView addSubview:descriptionLabel];
        [descriptionLabel sizeToFit];
    }
    
    
    if (_googleAuthType == RCHGoogleAuthTypeBackup || _googleAuthType == RCHGoogleAuthTypeInput || _googleAuthType == RCHGoogleAuthTypeSubmit) {
        
        NSTextAlignment textAlignment = NSTextAlignmentCenter;
        UIKeyboardType keyboardType = UIKeyboardTypeASCIICapable;
        BOOL enable = YES;
        BOOL hide = NO;
        CGFloat width = self.view.width - 50.0f * 2;
        CGFloat height = 60.0f;
        
        if (_googleAuthType == RCHGoogleAuthTypeBackup) {
            enable = NO;
        } else if (_googleAuthType == RCHGoogleAuthTypeSubmit) {
            headView.backgroundColor = [UIColor clearColor];
            keyboardType = UIKeyboardTypeNumberPad;
            hide = YES;
            
            _authCodeLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, 0.0f}, {labelWidth, 0.0f}}];
            _authCodeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24.0f];
            _authCodeLabel.backgroundColor = [UIColor clearColor];
            _authCodeLabel.numberOfLines = 1;
            _authCodeLabel.textAlignment = NSTextAlignmentCenter;
            _authCodeLabel.textColor = kAPPBlueColor;
            _authCodeLabel.text = @"";
//            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
//            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//            [paragraphStyle setLineHeightMultiple:1.1];
//            [paragraphStyle setAlignment:NSTextAlignmentCenter];
//            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [description length])];
//            [attributedString addAttribute:NSFontAttributeName value:_authCodeLabel.font range:NSMakeRange(0, [description length])];
//            _authCodeLabel.attributedText = attributedString;
            
//            [headView addSubview:_authCodeLabel];
//            [_authCodeLabel sizeToFit];
        }
        
        inputView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {width, height}}];
        inputView.backgroundColor = kLightGreenColor;
//        inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        inputView.userInteractionEnabled = YES;
        
        CGRect frame = (CGRect){{15.0f, 5.0f}, {inputView.width - 15.0f * 2, inputView.height - 5.0f * 2}};
        
        _keyTextField = [[UITextField alloc] initWithFrame:frame];
        _keyTextField.backgroundColor = [UIColor clearColor];//RGBA(29.9f, 36.0f, 45.0f, 1.0f);
        _keyTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _keyTextField.adjustsFontSizeToFitWidth = YES;
        _keyTextField.borderStyle = UITextBorderStyleNone;
        _keyTextField.keyboardType = keyboardType;
        _keyTextField.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20.0f];
        _keyTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        _keyTextField.textAlignment = textAlignment;
        _keyTextField.placeholder = NSLocalizedString(@"",nil);
        _keyTextField.text = key;
        _keyTextField.textColor = kAPPBlueColor;
        _keyTextField.enabled = enable;
        _keyTextField.hidden = hide;
        _keyTextField.delegate = self;
        _keyTextField.returnKeyType = UIReturnKeyNext;
        
        [inputView addSubview:_keyTextField];
        [_keyTextField becomeFirstResponder];
        
        if (hide) {
            _authCodeLabel.frame = frame;
            [inputView addSubview:_authCodeLabel];
        } else {
            
        }

        [headView addSubview:inputView];
    } else if (_googleAuthType == RCHGoogleAuthTypeGuidelines) {
        headView.backgroundColor = [UIColor clearColor];
    } else if (_googleAuthType == RCHGoogleAuthTypeDownload) {
        
    }

    

    
    CGFloat space1 = 0.0f;
    CGFloat space2 = 0.0f;
//    CGFloat originY = (rect.size.height - imageView.height - descriptionLabel.height - inputView.height - space1 - space2) / 2.0f;
    
    if (imageView) {
        imageView.frame = (CGRect){{imageView.left, originY}, imageView.frame.size};
        originY = originY + imageView.height;
        space1 = 20.0f - 2.0f;
    }

    if (descriptionLabel) {
        descriptionLabel.frame = (CGRect){{descriptionLabel.left, originY + space1}, descriptionLabel.frame.size};
        descriptionLabel.center = CGPointMake(headView.center.x, descriptionLabel.center.y);
        originY = originY + descriptionLabel.height + space2;
        space2 = 30.0f - 2.0f;
    }
    
    inputView.frame = (CGRect){{50.0f, originY + space2}, inputView.frame.size};

//    if (_googleAuthType == RCHGoogleAuthTypeSubmit) {
//        inputView.frame = (CGRect){{originX, originY + space2}, inputView.frame.size};
//    } else {
//        inputView.center = CGPointMake(headView.center.x, inputView.center.y);
//    }

    return headView;
}


- (UIView *)createFootView:(CGRect)rect submitTitle:(NSString *)submitTitle
{
    CGFloat height = 44.0f;
    UIColor *color;
    if (_googleAuthType == RCHGoogleAuthTypeDownload || _googleAuthType == RCHGoogleAuthTypeGuidelines) {
        color = kAppOrangeColor;
    } else {
        color = kPlaceholderColor;
    }
    UIView *footView = [[UIView alloc] initWithFrame:rect];
    footView.backgroundColor = [UIColor clearColor];
    
    _submitLabel = [[UILabel alloc] initWithFrame:(CGRect){{30.0f, rect.size.height - height - 20.0f}, {rect.size.width - 30.0f * 2, height}}];
    _submitLabel.backgroundColor = color;
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


- (BOOL)isRight:(NSString *)string
{
    if ([string isEqualToString:self.backupKey]) {
        return YES;
    }
    return NO;
}

- (BOOL)isNUmber:(NSString *)string
{
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:kNumbers] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL isNumber = [string isEqualToString:filtered];
    return isNumber;
}

- (NSMutableAttributedString *)getAttributedString:(NSString *)text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:1.1];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    [attributedString addAttribute:NSFontAttributeName value:_authCodeLabel.font range:NSMakeRange(0, [text length])];
    
    return attributedString;
}


- (void)hideKeyboard {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


- (void)getGoogleRequest
{
    if (self.googleRequest.currentTask) {
        [self.googleRequest.currentTask cancel];
    }
//    [MBProgressHUD showLoadToView:self.view];
    RCHWeak(self);
    
    [_googleRequest getVerify:^(NSObject *response) {
//        [MBProgressHUD hideHUDForView:self.view];
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = (NSDictionary *)response;
            id currentInfo = [dictionary objectForKey:@"secret"];
            if (currentInfo && ![currentInfo isKindOfClass:[NSNull class]]) {
                weakself.googleSecret = [NSString stringWithFormat:@"%@", currentInfo];
            } else {
                weakself.googleSecret = nil;
            }
            [weakself initCustomView];
            weakself.submitLabel.backgroundColor = kAppOrangeColor;
            
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    }];
    
}

- (void)verifyCodeRequest:(NSString *)code
{
    if (self.googleRequest.currentTask) {
        [self.googleRequest.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    RCHWeak(self);
    [_googleRequest putVerify:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            [MBProgressHUD showError:kVerifyCodeError ToView:weakself.view];
            return;
        }
        [MBProgressHUD showInfo:NSLocalizedString(@"谷歌验证成功", nil) ToView:weakself.view];
        [RCHHelper setValue:[NSNumber numberWithBool:YES] forKey:kCurrentUserGoogleAuth];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetMemverNotification object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself.navigationController popToRootViewControllerAnimated:YES];
        });
        
    } verifyCode:code];
}

#pragma mark -
#pragma mark - ButtonClicked

-(void)viewTapped:(UITapGestureRecognizer*)tapGesture
{
    if (_googleAuthType == RCHGoogleAuthTypeSubmit) {
        return;
    }
    [self hideKeyboard];
}

- (void)download:(id)sender
{
    NSString *url = @"https://itunes.apple.com/cn/app/google-authenticator/id388497605?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)submitClicked:(id)sender
{
    RCHGoogleAuth type;
    NSString *backupKey = nil;
    if (_googleAuthType == RCHGoogleAuthTypeDownload) {
        type = RCHGoogleAuthTypeBackup;
    } else if (_googleAuthType == RCHGoogleAuthTypeBackup) {
        type = RCHGoogleAuthTypeInput;
        if (_googleSecret) {
            backupKey = _googleSecret;
        } else {
            [MBProgressHUD showError:NSLocalizedString(@"正在生成密钥 请稍后", nil) ToView:self.view];
            return;
        }
        
    } else if (_googleAuthType == RCHGoogleAuthTypeInput) {
        type = RCHGoogleAuthTypeGuidelines;
        if (![self isRight:_keyTextField.text]) {
            [MBProgressHUD showError:NSLocalizedString(@"密钥输入有误 请仔细核对", nil) ToView:self.view];
            return;
        }
        
    } else if (_googleAuthType == RCHGoogleAuthTypeGuidelines) {
        type = RCHGoogleAuthTypeSubmit;
    } else if (_googleAuthType == RCHGoogleAuthTypeSubmit) {
        if ([_keyTextField.text length] < 6) {
            return;
        }
        [self verifyCodeRequest:_keyTextField.text];
        return;
    } else {
        type = RCHGoogleAuthTypeDefault;
    }

    RCHGoogleAuthController *viewcontroller = [[RCHGoogleAuthController alloc] initWithGoogleAuthType:type];
    viewcontroller.backupKey = backupKey;
    [self.navigationController pushViewController:viewcontroller animated:YES];
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super textField:textField shouldChangeCharactersInRange:range replacementString:[string uppercaseString]];
    NSLog(@"text:%@,insert:==%@==", textField.text, string);
    if (_googleAuthType == RCHGoogleAuthTypeInput) {
        if ((range.location + string.length) > [self.backupKey length]) {
            [MBProgressHUD showError:NSLocalizedString(@"密钥长度不能超过16位", nil) ToView:self.view];
            return NO;
        } else if ((range.location + string.length) == [self.backupKey length]) {
            if (![self isRight:[NSString stringWithFormat:@"%@%@", textField.text, string]]) {
//                [textField resignFirstResponder];
                _submitLabel.backgroundColor = kPlaceholderColor;
                [MBProgressHUD showError:NSLocalizedString(@"密钥输入有误 请仔细核对", nil) ToView:self.view];
            } else {
                _submitLabel.backgroundColor = kAppOrangeColor;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hideKeyboard];
                });
                
            }
            return YES;
        } else {
            _submitLabel.backgroundColor = kPlaceholderColor;
            return YES;
        }
    } else if (_googleAuthType == RCHGoogleAuthTypeSubmit) {
        
        if ((range.location + string.length) > 6) {
            return NO;
        } else if ((range.location + string.length) == 6) {
            _submitLabel.backgroundColor = kAppOrangeColor;
            [self verifyCodeRequest:[NSString stringWithFormat:@"%@%@", _keyTextField.text, string]];
        } else {
            _submitLabel.backgroundColor = kPlaceholderColor;
        }
        
        NSString *text;
        if ([string isEqualToString:@""]) {
            if ([textField.text length] == 4) {
                text = [_authCodeLabel.text substringWithRange:NSMakeRange(0, [_authCodeLabel.text length] - 2)];
            } else {
                text = [_authCodeLabel.text substringWithRange:NSMakeRange(0, [_authCodeLabel.text length] - 1)];
            }
        } else {
            if ([textField.text length] == 3) {
                text = [NSString stringWithFormat:@"%@ %@", _authCodeLabel.text, string];
            } else {
                text = [NSString stringWithFormat:@"%@%@", _authCodeLabel.text, string];
            }
        }
        
        NSMutableAttributedString *attributedText = [self getAttributedString:text];
        _authCodeLabel.attributedText = attributedText;
    }
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    return YES;
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
