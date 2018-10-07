//
//  RCHInviteController.m
//  richcore
//
//  Created by WangDong on 2018/6/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHInviteController.h"
#import <Photos/Photos.h>
#import "RCHInviteRequest.h"
#import "RCHInvitesController.h"
#import "RCHInvite.h"

#define kCellHeight 63.0f

@interface RCHInviteController ()
{
    UIView *_headerView;
    UIView *_footerView;
    UIImageView *_qrImageView;
}

@property (nonatomic, strong) RCHInviteRequest *inviteRequest;
@property (nonatomic, strong) RCHInviteInfo *info;
@property (nonatomic, assign) NSInteger  pagesize;
@property (nonatomic, assign) BOOL  hasMore;
@property (nonatomic, strong) NSMutableArray *invites;

@end

@implementation RCHInviteController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"奖励中心",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;

    self.pagesize = 6;
//    [self getInvites];
    
    [self.tableView.mj_header beginRefreshing];
    
//    self.tableView.tableHeaderView = [self createHeaderView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth,770.0f}}];
//    
//    self.tableView.tableFooterView = [self createFootView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, 248.0f}}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Implements UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

#pragma mark -
#pragma mark - ButtonClicked

- (void)gotoNotice:(id)sender
{
    RCHWebViewController *webviewController = [[RCHWebViewController alloc] init];
    webviewController.gotoURL = @"https://support.richcore.com/hc/zh-cn/categories/360000557312-%E5%85%AC%E5%91%8A%E4%B8%AD%E5%BF%83";
    webviewController.title = NSLocalizedString(@"公告中心",nil);
    [self.navigationController pushViewController:webviewController animated:YES];
}

- (void)saveButtonClicked:(id)sender
{
    UILongPressGestureRecognizer *tap = (UILongPressGestureRecognizer *)sender;
    if (tap.state != UIGestureRecognizerStateBegan) {
        return;
    }

    UIImage *image = _qrImageView.image;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    // 2.根据状态进行相应的操作
    switch (status) {
        case PHAuthorizationStatusNotDetermined: { // 用户还没有做出选择
            // 2.1请求获取权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusDenied) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD showInfo:NSLocalizedString(@"拒绝授权， 无法保存二维码", nil) ToView:self.view];
                    });
                    
                }else if (status == PHAuthorizationStatusAuthorized) {
                    if (image) {
                        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
                    };
                }else if (status == PHAuthorizationStatusRestricted) {
                    // 受限制,家长控制,不允许访问
                }
            }];
            break;
        }
        case PHAuthorizationStatusRestricted:
            // 受限制,家长控制,不允许访问
            break;
        case PHAuthorizationStatusDenied:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD showInfo:NSLocalizedString(@"没有开启授权， 无法保存二维码", nil) ToView:self.view];
            });
        }
            break;
        case PHAuthorizationStatusAuthorized:
            if (image) {
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
            };
            break;
        default:
            break;
    }
}

- (void)copyButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *info = self.info.code ?: nil;
    if (button.tag) {
        info = self.info.code ? [NSString stringWithFormat:@"https://www.richcore.com?ref=%@", self.info.code] : nil;
    }
    
    if (info) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = info;
        [MBProgressHUD showInfo:NSLocalizedString(@"复制成功", nil) ToView:self.view];
    }
    
}

- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存图片出错%@", error.localizedDescription);
        NSString *info = [NSString stringWithFormat:NSLocalizedString(@"保存二维码出错%@", error.localizedDescription)];
        [MBProgressHUD showError:info ToView:self.view];
    } else {
        NSLog(@"保存图片成功");
        [MBProgressHUD showInfo:NSLocalizedString(@"保存二维码成功", nil) ToView:self.view];
    }
    
}


- (void)moreButtonClicked:(id)sender
{
    RCHInvitesController *viewcontroller = [[RCHInvitesController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:viewcontroller animated:YES];
}



#pragma mark -
#pragma mark - CustomFunction

- (UIView *)createHeaderView:(CGRect)rect
{
    CGFloat width = 345.0f;
    CGFloat space = 15.0f;
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    headView.backgroundColor = RGBA(255.0, 255.0f, 255.0f, 1.0f);

    UIView *brokerageView = [self createInfoView:self.info size:(CGSize){width, 110.0f}];
    [headView addSubview:brokerageView];
    
    [brokerageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(15.0f);
        make.left.offset(15.0f);
        make.right.offset(-15.0f);
        make.height.mas_equalTo(110.0f);
    }];
    
    
    NSString *pre = [NSString stringWithFormat:@"https://%@/qr?value=", kRichcoreAPIURLDomain];
    NSString *url = [NSString stringWithFormat:@"%@https://www.richcore.com/m/activity/mining/share?code=%@&email=%@", pre, self.info.code, [RCHHelper valueForKey:kCurrentHideEmail]];

    UIView *QRView = [self createQRView:NSLocalizedString(@"您的推荐二维码：",nil) value:self.info.code ? url : @""];
    [headView addSubview:QRView];

    [QRView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(brokerageView.mas_bottom).offset(space);
        make.right.left.mas_equalTo(brokerageView);
        make.height.mas_equalTo(270.0f);
    }];
    
    UIView *IDCopyView = [self createCopyView:NSLocalizedString(@"您的推荐ID：",nil) value:self.info.code ?: @"" right:115.0f];
    [headView addSubview:IDCopyView];
    [IDCopyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(brokerageView);
        make.top.mas_equalTo(QRView.mas_bottom).offset(space);
        make.height.mas_equalTo(70.0f);
    }];
    
    NSString *address = [NSString stringWithFormat:@"www.richcore.com?ref=%@", self.info.code];

    UIView *addressCopyView = [self createCopyView:NSLocalizedString(@"您的推荐链接：",nil) value:self.info.code ? address : @"" right:0.0f];
    [headView addSubview:addressCopyView];
    [addressCopyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(brokerageView);
        make.top.mas_equalTo(IDCopyView.mas_bottom).offset(space);
        make.height.mas_equalTo(70.0f);
    }];
    
    if (self.invites.count) {
        RCHWeak(self);
        UIView *invitesView = [self createInvitesInfoView:NSLocalizedString(@"奖励记录：",nil) value:self.invites];
        [headView addSubview:invitesView];
        [invitesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(brokerageView);
            make.top.mas_equalTo(addressCopyView.mas_bottom).offset(20.0f);
            make.height.mas_equalTo(weakself.invites.count * kCellHeight + 40.0f + 30.0f);
        }];

        if (self.hasMore) {
            UIView *moreView = [self createMoreView];
            [headView addSubview:moreView];
            [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.mas_equalTo(brokerageView);
                make.top.mas_equalTo(invitesView.mas_bottom).offset(20.0f);
                make.height.mas_equalTo(44.0f);
            }];
        }
    } else {
        UIView *invitesView = [self createInviteEmptyView:NSLocalizedString(@"奖励记录：",nil)];
        [headView addSubview:invitesView];
        [invitesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(brokerageView);
            make.top.mas_equalTo(addressCopyView.mas_bottom).offset(20.0f);
            make.height.mas_equalTo(120.0f + 30.0f);
        }];
    }
    
    return headView;
}

- (UIView *)createFootView:(CGRect)rect
{
    CGFloat width = 345.0f;
    CGFloat originY = 0.0f;
    CGFloat originX = (rect.size.width - width) / 2.0f;
    
    UIView *footView = [[UIView alloc] initWithFrame:rect];
    footView.backgroundColor = RGBA(255.0, 255.0f, 255.0f, 1.0f);
    
    UIView *backView = [[UIView alloc] initWithFrame:(CGRect){{originX, originY}, {width, rect.size.height - 40.0f}}];
    backView.backgroundColor = [kLightGreenColor colorWithAlphaComponent:0.5f];
    [footView addSubview:backView];
    
    NSString *value1 = @"* 返佣细则：\n请在富矿Richcore的公告中心查看关于返佣的消息。\n";
    NSString *link = @"前往富矿Richcore公告中心>>";
    NSString *value2 = @"\n\n* 特别注意：\n由于市场环境的改变，欺诈风险的存在等原因，富矿\nRichcore保留随时对返佣规则作出调整的最终解释权。";
    NSString *value = [NSString stringWithFormat:@"%@%@%@", value1, link, value2];
    
    NSRange range = (NSRange){[value1 length], [link length]};
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    
    NSMutableAttributedString *notice = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:1.3f];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [notice addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [value length])];
    [notice addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:13.0f] range:NSMakeRange(0, [value length])];
    [notice addAttribute:NSForegroundColorAttributeName value:kAPPBlueColor range:NSMakeRange(0, [value length])];
    [notice addAttribute:NSForegroundColorAttributeName value:kAppOrangeColor range:NSMakeRange([value1 length] + [link length], [value2 length])];
    [notice yy_setUnderlineStyle:NSUnderlineStyleSingle range:range];
//
    RCHWeak(self);
    [notice yy_setTextHighlightRange:range
                               color:kAPPBlueColor
                     backgroundColor:[UIColor clearColor]
                           tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                               [weakself gotoNotice:nil];
                           }];
    
    [text appendAttributedString:notice];
    
    YYLabel *valueLabel = [YYLabel new];
    valueLabel.attributedText = text;
    valueLabel.numberOfLines = 0;
    valueLabel.backgroundColor = [UIColor clearColor];
    
    [backView addSubview:valueLabel];

    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20.0f);
        make.left.offset(15.0f);
        make.right.offset(-15.0f);
    }];

    return footView;
}

- (UIView *)createInfoView:(RCHInviteInfo *)info size:(CGSize)size
{
    CGFloat width = size.width / 2.0f;
    CGFloat height = 48.0f;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = kAPPBlueColor;
    backView.layer.cornerRadius = 4.0f;
    backView.layer.masksToBounds = YES;
    
    UIView *friendView = [self createInfoItem:NSLocalizedString(@"已推荐朋友",nil) value:[NSString stringWithFormat:@"%ld", (long)info.totalUser] image:RCHIMAGEWITHNAMED(@"fill115")];
    friendView.backgroundColor = [UIColor clearColor];
    [backView addSubview:friendView];
    [friendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20.0f);
        make.centerY.offset(0.0f);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    UIView *coinView = [self createInfoItem:NSLocalizedString(@"已获取 RICHT",nil) value:info.cashes ?: @"0.00" image:RCHIMAGEWITHNAMED(@"coins")];
    coinView.backgroundColor = [UIColor clearColor];
    [backView addSubview:coinView];
    
    [coinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(width - 10.0f);
        make.centerY.offset(0.0f);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    
    return backView;
}

- (UIView *)createInfoItem:(NSString *)title value:(NSString *)value image:(UIImage *)image
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    
    UIImageView *friImageView = [[UIImageView alloc] initWithImage:image];
    friImageView.frame = (CGRect){{0.0f, 0.0}, image.size};
    [backView addSubview:friImageView];
    
    [friImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0.0f);
        make.left.offset(0.0f);
        make.size.mas_equalTo(image.size);
    }];
    
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:13.0f] range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [titleLabel.text length])];
        titleLabel.attributedText = attributedString;
        [titleLabel sizeToFit];
        [backView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0.0f);
            make.left.mas_equalTo(friImageView.mas_right).offset(7.0f);
            make.height.mas_equalTo(18.0f);
        }];
    }
    
    
    {
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        valueLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.text = value;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:valueLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [valueLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:22.0f] range:NSMakeRange(0, [valueLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [valueLabel.text length])];
        valueLabel.attributedText = attributedString;
        [valueLabel sizeToFit];
        [backView addSubview:valueLabel];
        
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(friImageView.mas_bottom).offset(10.0f);
            make.left.mas_equalTo(friImageView.mas_left).offset(0.0f);
            make.height.mas_equalTo(24.0f);
        }];
        
    }
    
    return backView;
}


- (UIView *)createQRView:(NSString *)title value:(NSString *)value
{
    CGFloat width = 200.0f;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:14.0f] range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [titleLabel.text length])];
        titleLabel.attributedText = attributedString;
        [titleLabel sizeToFit];
        [backView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0.0f);
            make.left.offset(0.0f);
            make.height.mas_equalTo(20.0f);
        }];
    }
    
    UIView *qrView = [[UIView alloc] initWithFrame:CGRectZero];
    qrView.backgroundColor = [kLightGreenColor colorWithAlphaComponent:0.5f];
    [backView addSubview:qrView];
    [qrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30.0f);
        make.right.left.mas_equalTo(0.0f);
        make.bottom.mas_equalTo(0.0f);
    }];
    
    UIView *qrBackView = [[UIView alloc] initWithFrame:CGRectZero];
    qrBackView.backgroundColor = [UIColor whiteColor];
    [qrView addSubview:qrBackView];
    [qrBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(qrView.center);
        make.size.mas_equalTo((CGSize){width, width});
    }];
    
    
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _qrImageView.userInteractionEnabled = YES;
    [_qrImageView sd_setImageWithURL:[NSURL URLWithString:value] placeholderImage:nil];
    [qrBackView addSubview:_qrImageView];
    
    [_qrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.edges.insets(UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f));
    }];
    
//    UITapGestureRecognizer *saveTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveButtonClicked:)];
//    saveTapGesture.delegate = self;
//    [_qrImageView addGestureRecognizer:saveTapGesture];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveButtonClicked:)];
    longPressRecognizer.delegate = self;
    [longPressRecognizer setMinimumPressDuration:1.0f];
    [_qrImageView addGestureRecognizer:longPressRecognizer];
    
    return backView;
}

- (UIView *)createCopyView:(NSString *)title value:(NSString *)value right:(CGFloat)right
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:14.0f] range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [titleLabel.text length])];
        titleLabel.attributedText = attributedString;
        [titleLabel sizeToFit];
        [backView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0.0f);
            make.left.offset(0.0f);
            make.height.mas_equalTo(20.0f);
        }];
    }
    
    {
        UIView *copyView = [[UIView alloc] initWithFrame:CGRectZero];
        copyView.backgroundColor = [UIColor clearColor];
        [backView addSubview:copyView];
        [copyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsMake(30.0f, 0.0f, 0.0f, 0.0f));
        }];
        
        UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        copyButton.frame = CGRectZero;
        copyButton.layer.cornerRadius = 2.0f;
        copyButton.layer.masksToBounds = YES;
        [copyButton setTitle:NSLocalizedString(@"复制",nil) forState:UIControlStateNormal];
        [copyButton setBackgroundColor:kAppOrangeColor forState:UIControlStateNormal];
        copyButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
        [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [copyButton addTarget:self action:@selector(copyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        [copyView addSubview:copyButton];
        if ([value containsString:@"www.richcore.com"]) {
            copyButton.tag = 1;
        } else {
            copyButton.tag = 0;
        }
        
        
        [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0.0f);
            make.right.mas_equalTo(-right);
            make.width.mas_equalTo(60.0f);
        }];
        
        UIView *valueView = [[UIView alloc] initWithFrame:CGRectZero];
        valueView.backgroundColor = [kLightGreenColor colorWithAlphaComponent:0.5f];
        [copyView addSubview:valueView];
        [valueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_equalTo(0.0f);
            make.right.mas_equalTo(copyButton.mas_left).offset(-10.0f);
        }];

        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.text = value;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:valueLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [valueLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14.0f] range:NSMakeRange(0, [valueLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kAPPBlueColor range:NSMakeRange(0, [valueLabel.text length])];
        valueLabel.attributedText = attributedString;
        [valueLabel sizeToFit];
        [valueView addSubview:valueLabel];

        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f));
        }];
//
    }
    return backView;
}

- (UIView *)createInvitesInfoView:(NSString *)title value:(NSArray *)invites
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleLabel.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [titleLabel.text length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:14.0f] range:NSMakeRange(0, [titleLabel.text length])];
    [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [titleLabel.text length])];
    titleLabel.attributedText = attributedString;
    [titleLabel sizeToFit];
    [backView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0.0f);
        make.left.offset(0.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    UIView *invitesView = [self createInvitesView:invites];
    invitesView.backgroundColor = [kLightGreenColor colorWithAlphaComponent:0.5f];
    [backView addSubview:invitesView];
    [invitesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30.0f);
        make.left.right.bottom.mas_equalTo(0.0f);
    }];

    return backView;
}

- (UIView *)createInvitesView:(NSArray *)invites
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    backView.layer.borderColor = [[kLightGreenColor colorWithAlphaComponent:0.5f] CGColor];
    backView.layer.borderWidth = 1.0f;
    backView.layer.masksToBounds = YES;
    
    {
        UIView *invitesView = [self createInviteTItleView];
        invitesView.backgroundColor = [kLightGreenColor colorWithAlphaComponent:0.5f];
        [backView addSubview:invitesView];
        [invitesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0.0f);
            make.height.mas_equalTo(40.0f);
        }];
        
        
        NSInteger index = 0;
        for (RCHInvite *invite in invites) {
            UIView *inviteView = [self createInviteView:invite];
            if (index % 2) {
                inviteView.backgroundColor = [kLightGreenColor colorWithAlphaComponent:0.5f];
            } else {
                inviteView.backgroundColor = [UIColor whiteColor];
            }
            
            [backView addSubview:inviteView];
            [inviteView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0.0f);
                make.top.mas_equalTo(invitesView.mas_bottom).offset(index * kCellHeight);
                make.height.mas_equalTo(kCellHeight);
            }];
            index += 1;
        }
        
    }
    
    
    return backView;
    
}

- (UIView *)createInviteTItleView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.userInteractionEnabled = YES;
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = @"类型/时间";
        titleLabel.textColor = kTextUnselectColor;
        [backView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_equalTo(10.0f);
            make.bottom.mas_equalTo(-10.0f);
        }];
        
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.userInteractionEnabled = YES;
        valueLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        valueLabel.textAlignment = NSTextAlignmentRight;
        valueLabel.text = @"奖励";
        valueLabel.textColor = kTextUnselectColor;
        [backView addSubview:valueLabel];
        
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10.0f);
            make.right.bottom.mas_equalTo(-10.0f);
        }];
    }
    
    return backView;
}


- (UIView *)createInviteView:(RCHInvite *)invite
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    
    {
        NSString *defaultString = @"--";
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectZero];
        leftView.backgroundColor = [UIColor clearColor];
        [backView addSubview:leftView];
        
        [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10.0f);
            make.centerY.mas_equalTo(backView.mas_centerY);
            make.width.mas_equalTo(200.0f);
            make.height.mas_equalTo(33.0f);
        }];
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        typeLabel.textColor = kFontGrayColor;
        typeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13.0f];
        typeLabel.textAlignment = NSTextAlignmentLeft;
        typeLabel.backgroundColor = [UIColor clearColor];
        typeLabel.layer.masksToBounds = YES;
        [leftView addSubview:typeLabel];
        
        typeLabel.text = invite.type ?: defaultString;
        NSMutableAttributedString *attributedString = [RCHHelper getMutableAttributedStringe:typeLabel.text Font:typeLabel.font color:typeLabel.textColor alignment:NSTextAlignmentLeft];
        typeLabel.attributedText = attributedString;

        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0.0f);
            make.height.mas_equalTo(14.0f);
        }];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.textColor = kFontLightGrayColor;
        timeLabel.numberOfLines = 0;
        [timeLabel setFont: [UIFont fontWithName:@"PingFangSC-Medium" size:13.0f]];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [leftView addSubview:timeLabel];
        
        timeLabel.text = invite.created_at ? [RCHHelper getStempString:invite.created_at] : defaultString;
        attributedString = [RCHHelper getMutableAttributedStringe:timeLabel.text Font:timeLabel.font color:timeLabel.textColor alignment:NSTextAlignmentLeft];
        timeLabel.attributedText = attributedString;
        
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(typeLabel.mas_bottom).offset(5);
            make.left.right.mas_equalTo(0.0f);
            make.height.mas_equalTo(14.0f);
        }];

        
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        countLabel.textColor = kFontGrayColor;
        countLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.layer.masksToBounds = YES;
        [backView addSubview:countLabel];
        
        countLabel.text = [NSString stringWithFormat:@"%@ %@", invite.amount ?: defaultString, invite.wallet.coin.code ?: defaultString];
        attributedString = [RCHHelper getMutableAttributedStringe:countLabel.text Font:countLabel.font color:countLabel.textColor alignment:countLabel.textAlignment];
        countLabel.attributedText = attributedString;
        
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10.0f);
            make.centerY.mas_equalTo(backView.mas_centerY);
            make.width.mas_equalTo(200.0f);
            make.height.mas_equalTo(16.0f);
        }];
    }
    
    return backView;
}

- (UIView *)createBlankView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    backView.layer.borderColor = [[kLightGreenColor colorWithAlphaComponent:0.5f] CGColor];
    backView.layer.borderWidth = 1.0f;
    backView.layer.masksToBounds = YES;
    
    {
        UIView *invitesView = [self createInviteTItleView];
        invitesView.backgroundColor = [kLightGreenColor colorWithAlphaComponent:0.5f];
        [backView addSubview:invitesView];
        [invitesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0.0f);
            make.left.right.offset(0.0f);
            make.height.mas_equalTo(40.0f);
        }];
        
        
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.userInteractionEnabled = YES;
        valueLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.text = NSLocalizedString(@"还没有记录，邀请好友去交易吧", nil);
        valueLabel.textColor = kTextUnselectColor;
        [backView addSubview:valueLabel];
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(invitesView.mas_bottom);
            make.bottom.right.left.mas_equalTo(0.0f);
        }];
        
    }
    
    return backView;
    
}

- (UIView *)createInviteEmptyView:(NSString *)title
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Medium" size:14.0f] range:NSMakeRange(0, [titleLabel.text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kNavigationColor_MB range:NSMakeRange(0, [titleLabel.text length])];
        titleLabel.attributedText = attributedString;
        [backView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0.0f);
            make.left.offset(0.0f);
            make.height.mas_equalTo(20.0f);
        }];
        
        UIView *invitesView = [self createBlankView];
        [backView addSubview:invitesView];
        [invitesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(30.0f);
            make.left.right.bottom.mas_equalTo(0.0f);
        }];
        
    }
    
    
    return backView;
    
}

- (UIView *)createMoreView
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectZero;
    moreButton.layer.cornerRadius = 4.0f;
    moreButton.layer.borderColor = [kYellowColor CGColor];
    moreButton.layer.borderWidth = 1.0f;
    moreButton.layer.masksToBounds = YES;
    [moreButton setTitle:NSLocalizedString(@"查看更多",nil) forState:UIControlStateNormal];
    [moreButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    moreButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    [moreButton setTitleColor:kYellowColor forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:moreButton];
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(backView);
        make.width.mas_equalTo(120.0f);
        make.height.mas_equalTo(44.0f);
    }];
    
    return backView;
}


- (void)tableviewReload
{
    if (_info) {
        CGFloat height = 580.0f;
        CGFloat bottom = 20.0f;
        if (self.invites.count == 0) {
            height += 120.0f + 30.0f + 20.0f;
        } else {
            height += 30.0f + 40.0f + kCellHeight * self.invites.count + 20.0f;
            if (self.hasMore) {
                height += 44.0f + 20.0f;
            }
        }
        height += bottom;
        self.tableView.tableHeaderView = [self createHeaderView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, height}}];
        self.tableView.tableFooterView = [self createFootView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, 248.0f}}];
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.tableFooterView = nil;
    }

    [self.tableView reloadData];
}

- (void)loadMore:(BOOL)isMore
{
    [self getInvites];
}

#pragma mark -
#pragma mark - Request

- (void)getInvites
{
    RCHWeak(self);
    if (weakself.inviteRequest.currentTask) {
        [weakself.inviteRequest.currentTask cancel];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSNumber numberWithInteger:1] forKey:@"page_info"];
    [dictionary setObject:[NSNumber numberWithInteger:self.pagesize] forKey:@"size"];
    [dictionary setObject:[NSNumber numberWithInteger:1] forKey:@"page"];
    
    [weakself.inviteRequest invites:^(NSObject *response) {
        if ([response isKindOfClass:[RCHInviteList class]]) {  //服务器出错时候 返回的数量大雨pagesize则只显示pagesize的数量
            RCHInviteList *inviteList = (RCHInviteList *)response;
            if ([NSMutableArray arrayWithArray:inviteList.data].count > weakself.pagesize) {
                weakself.invites = [NSMutableArray arrayWithArray:[[NSMutableArray arrayWithArray:inviteList.data] subarrayWithRange:(NSRange){0, weakself.pagesize}]];
                weakself.hasMore = YES;
            } else {
                weakself.invites = [NSMutableArray arrayWithArray:inviteList.data];
                if (inviteList.page < inviteList.total) {
                    weakself.hasMore = YES;
                } else {
                    weakself.hasMore = NO;
                }
            }
            [weakself getInviteInfo];
            
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            [weakself endHeaderFooterRefreshing];
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [weakself endHeaderFooterRefreshing];
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    } info:dictionary];
    
}

- (void)getInviteInfo
{
    RCHWeak(self);
    if (weakself.inviteRequest.currentTask) {
        [weakself.inviteRequest.currentTask cancel];
    }
    
    [weakself.inviteRequest inviteInfo:^(NSObject *response) {
        [weakself endHeaderFooterRefreshing];
        if ([response isKindOfClass:[RCHInviteInfo class]]) {
            weakself.info = (RCHInviteInfo *)response;
            [weakself tableviewReload];
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
#pragma mark - getter

- (RCHInviteRequest *)inviteRequest
{
    if(_inviteRequest == nil)
    {
        _inviteRequest = [[RCHInviteRequest alloc] init];
    }
    return _inviteRequest;
}

@end
