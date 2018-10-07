//
//  RCHModifyPasswordController.m
//  richcore
//
//  Created by WangDong on 2018/5/21.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHModifyPasswordController.h"
#import "RCHModifyPasswordRequest.h"

#define kCellHeight 44.0f

@interface RCHModifyPasswordController ()
{
    UITextField *_oldTextField;
    UITextField *_newTextField;
    UITextField *_confirmTextField;
    UIView *_headerView;
    UIView *_footerView;
    UILabel *_commitLabel;
}

@property (nonatomic, strong) RCHModifyPasswordRequest *modityPassword;

@end

@implementation RCHModifyPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"修改密码";
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
    backView1.layer.cornerRadius = 4.0f;
    backView1.layer.borderWidth = lineWidth;
    backView1.layer.borderColor = [kFontLineGrayColor CGColor];
    backView1.layer.masksToBounds = YES;
    [headView addSubview:backView1];
    
    UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView1.height}}];
    titleLabel1.userInteractionEnabled = YES;
    titleLabel1.backgroundColor = [UIColor whiteColor];
    titleLabel1.adjustsFontSizeToFitWidth = YES;
    titleLabel1.font = [UIFont systemFontOfSize:14.0f];
    titleLabel1.text = @"旧密码";
    titleLabel1.textAlignment = NSTextAlignmentLeft;
    titleLabel1.textColor = kTextColor_MB;
    [backView1 addSubview:titleLabel1];

    
    _oldTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView1.width - width, backView1.height}}];
    _oldTextField.backgroundColor = [UIColor whiteColor];
    _oldTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _oldTextField.adjustsFontSizeToFitWidth = YES;
    _oldTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _oldTextField.borderStyle = UITextBorderStyleNone;
    _oldTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _oldTextField.keyboardType = UIKeyboardTypeDefault;
    _oldTextField.secureTextEntry = YES;
    _oldTextField.placeholder = @"请输入旧密码";
    _oldTextField.font = [UIFont systemFontOfSize:14.0f];
    _oldTextField.textAlignment = NSTextAlignmentLeft;
    _oldTextField.textColor = kTextColor_MB;
    _oldTextField.tag = 1000;
    [_oldTextField setDelegate:self];
    _oldTextField.returnKeyType = UIReturnKeyNext;
    [backView1 addSubview:_oldTextField];
    
    UIView *backView2 = [[UIView alloc] initWithFrame:(CGRect){{backView1.left, backView1.bottom + space}, backView1.frame.size}];
    backView2.backgroundColor = [UIColor whiteColor];
    backView2.layer.cornerRadius =2.0f;
    backView2.layer.borderWidth = lineWidth;
    backView2.layer.borderColor = [kFontLineGrayColor CGColor];
    backView2.layer.masksToBounds = YES;
    [headView addSubview:backView2];
    
    UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView2.height}}];
    titleLabel2.backgroundColor = [UIColor whiteColor];
    titleLabel2.adjustsFontSizeToFitWidth = YES;
    titleLabel2.font = [UIFont systemFontOfSize:14.0f];
    titleLabel2.text = NSLocalizedString(@"新密码",nil);
    titleLabel2.textAlignment = NSTextAlignmentLeft;
    titleLabel2.textColor = kTextColor_MB;
    [backView2 addSubview:titleLabel2];
    
    _newTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView2.width - width, backView2.height}}];
    _newTextField.backgroundColor = [UIColor clearColor];
    _newTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _newTextField.adjustsFontSizeToFitWidth = YES;
    _newTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _newTextField.borderStyle = UITextBorderStyleNone;
    _newTextField.keyboardType = UIKeyboardTypeDefault;
    _newTextField.secureTextEntry = YES;
    _newTextField.placeholder = NSLocalizedString(@"至少8位，英文与数字组合",nil);
    _newTextField.font = [UIFont systemFontOfSize:14.0f];
    _newTextField.textAlignment = NSTextAlignmentLeft;
    _newTextField.textColor = kTextColor_MB;
    _newTextField.tag = 1002;
    _newTextField.returnKeyType = UIReturnKeyNext;
    [_newTextField setDelegate:self];
    [backView2 addSubview:_newTextField];
    
    UIView *backView3 = [[UIView alloc] initWithFrame:(CGRect){{backView1.left, backView2.bottom + space}, backView1.frame.size}];
    backView3.backgroundColor = [UIColor whiteColor];
    backView3.layer.cornerRadius =2.0f;
    backView3.layer.borderWidth = lineWidth;
    backView3.layer.borderColor = [kFontLineGrayColor CGColor];
    backView3.layer.masksToBounds = YES;
    [headView addSubview:backView3];
    
    UILabel *titleLabe3 = [[UILabel alloc] initWithFrame:(CGRect){{15.0f, 0.0f}, {width + 20.0f, backView3.height}}];
    titleLabe3.backgroundColor = [UIColor whiteColor];
    titleLabe3.adjustsFontSizeToFitWidth = YES;
    titleLabe3.font = [UIFont systemFontOfSize:14.0f];
    titleLabe3.text = NSLocalizedString(@"确认密码",nil);
    titleLabe3.textAlignment = NSTextAlignmentLeft;
    titleLabe3.textColor = kTextColor_MB;
    [backView3 addSubview:titleLabe3];
    
    _confirmTextField = [[UITextField alloc] initWithFrame:(CGRect){{width, 0.0f}, {backView3.width - width, backView3.height}}];
    _confirmTextField.backgroundColor = [UIColor clearColor];
    _confirmTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _confirmTextField.adjustsFontSizeToFitWidth = YES;
    _confirmTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _confirmTextField.borderStyle = UITextBorderStyleNone;
    _confirmTextField.keyboardType = UIKeyboardTypeDefault;
    _confirmTextField.secureTextEntry = YES;
    _confirmTextField.placeholder = NSLocalizedString(@"至少8位，英文与数字组合",nil);
    _confirmTextField.font = [UIFont systemFontOfSize:14.0f];
    _confirmTextField.textAlignment = NSTextAlignmentLeft;
    _confirmTextField.textColor = kTextColor_MB;
    _confirmTextField.tag = 1002;
    _confirmTextField.returnKeyType = UIReturnKeyNext;
    [_confirmTextField setDelegate:self];
    [backView3 addSubview:_confirmTextField];
    
    headView.frame = (CGRect){headView.frame.origin, {headView.width, backView3.bottom}};
    
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
    _commitLabel.text = NSLocalizedString(@"确认修改",nil);
    _commitLabel.textColor = [UIColor whiteColor];
    [footView addSubview:_commitLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modifyButtonClicked:)];
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

- (void)changePassword
{
    NSMutableDictionary *password = [NSMutableDictionary dictionary];
    [password setObject:_newTextField.text forKey:@"new_password"];
    [password setObject:_oldTextField.text forKey:@"old_password"];
    
    RCHWeak(self);
    
    if (self.modityPassword.currentTask) {
        [self.modityPassword.currentTask cancel];
    }
    [MBProgressHUD showLoadToView:self.view];
    [self.modityPassword changePassword:^(NSError *error, WDBaseResponse *response) {
        [MBProgressHUD hideHUDForView:self.view];
        if (error) {
            [MBProgressHUD showError:NSLocalizedString(@"原密码错误", nil) ToView:self.view];
            return;
        }
        [MBProgressHUD showInfo:NSLocalizedString(@"密码修改成功，请重新登录", nil) ToView:weakself.view];
        [weakself performSelector:@selector(logout) withObject:nil afterDelay:1.0f];
    } password:password];
}

- (void)logout
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutDidSuccessNotification object:nil];
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)modifyButtonClicked:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (RCHIsEmpty(_oldTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"旧密码不能为空",nil) ToView:self.view];
        return;
    }
    
    if (RCHIsEmpty(_newTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"新密码不能为空",nil) ToView:self.view];
        return;
    }
    
    if (RCHIsEmpty(_confirmTextField.text)) {
        [MBProgressHUD showError:NSLocalizedString(@"请确认新密码",nil) ToView:self.view];
        return;
    }
    
    if (![RCHHelper checkPassword:_newTextField.text]) {
        [MBProgressHUD showError:NSLocalizedString(@"密码至少8位，英文与数字组合",nil) ToView:self.view];
        return;
    }
    
    if (![_newTextField.text isEqualToString:_confirmTextField.text]) {
        [MBProgressHUD showError:NSLocalizedString(@"两次密码不一致",nil) ToView:self.view];
        return;
    }
    
    [self changePassword];
    
}
     
#pragma mark -
#pragma mark - getter
     
 - (RCHModifyPasswordRequest *)modityPassword
{
    if(_modityPassword == nil)
    {
        _modityPassword = [[RCHModifyPasswordRequest alloc] init];
    }
    return _modityPassword;
}
     
@end
