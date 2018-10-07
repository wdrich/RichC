//
//  RCHRechargeController.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHRechargeController.h"
#import "RCHAlertView.h"

@interface RCHRechargeController ()
{
    UITableView *_tableview;
    UIView *_headerView;
    UIView *_footerView;
    UIImageView *_qrImageView;
    
    RCHWallet *_wallet;
}
@end

@implementation RCHRechargeController

- (id)initWithWallet:(RCHWallet *)wallet
{
    if(self = [super init]) {
        _wallet = wallet;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"充币",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    CGFloat headviewHeight = 470.0f;
    if ([_wallet.coin.code isEqualToString:@"XRP"]) {
        headviewHeight = 580;
        
        NSString *title = @"充值Ripple到富矿同时需要一个充值地址和充值Tag。如果您充值时不包含Tag，资金可能会永远丢失。";
        NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:title];
        NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [titleParagraphStyle setAlignment:NSTextAlignmentCenter];
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, [title length])];
        [attributedString1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f] range:NSMakeRange(0, [title length])];
        [attributedString1 addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange(0, [title length])];
        
        [RCHAlertView showAlertWithTitle:nil description:attributedString1 imageName:@"pic_bell" buttonTitle:@"我已知晓，确认使用" type:RCHAlertViewInfo];
    }
    
    self.tableView.tableHeaderView = [self createHeaderView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, headviewHeight}}];
    
    self.tableView.tableFooterView = [self createFootView:(CGRect){{0.0f, 0.0f}, {kMainScreenWidth, 230.0f}}];

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


- (void)saveButtonClicked:(id)sender
{
    UIImage *image = _qrImageView.image;
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    };
}

- (void)copyButtonClicked:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    UIView *view = (UIView *)tap.view;
    NSString *address = _wallet.address;
    if (view.tag == 1) {
        if ([_wallet.coin.code isEqualToString:@"XRP"]) {
            address = _wallet.coin.address;
        } else {
            address = _wallet.address;
        }
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = address;
    [MBProgressHUD showInfo:NSLocalizedString(@"复制成功", nil) ToView:self.view];
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




#pragma mark -
#pragma mark - CustomFunction

- (UIView *)createHeaderView:(CGRect)rect
{
    CGFloat originY = 30.0f;
    CGFloat originX = 30.0f;
    UIView *headView = [[UIView alloc] initWithFrame:rect];
    headView.backgroundColor = RGBA(255.0, 255.0f, 255.0f, 1.0f);
    
    UIView *titleView = [self createTitleViewWithWallet:_wallet];
    titleView.center = CGPointMake(headView.center.x, titleView.height / 2.0f + originY);
    [headView addSubview:titleView];
    
    NSString *pre = [NSString stringWithFormat:@"https://%@/qr?value=", kRichcoreAPIURLDomain];
    NSString *url = [NSString stringWithFormat:@"%@%@", pre, _wallet.address];
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    CGSize size = (CGSize){160.0f, 160.0f};
    [_qrImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
    _qrImageView.frame = (CGRect){{0.0f, titleView.bottom + 40.0f}, size};
    _qrImageView.center = CGPointMake(headView.center.x, _qrImageView.center.y);
    [headView addSubview:_qrImageView];
    
    
    NSString *address = _wallet.address;
    if ([_wallet.coin.code isEqualToString:@"XRP"]) {
        address = _wallet.coin.address;
    }
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    addressLabel.numberOfLines = 0;
    addressLabel.frame = (CGRect){{0.0f, _qrImageView.bottom + 25.0f - 2.0f}, {280.0f, 0.0f}};
    addressLabel.backgroundColor = [UIColor clearColor];
    if (address) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:address];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [address length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:13.0f] range:NSMakeRange(0, [address length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:RGBA(104.0f, 113.0f, 134.0f, 1.0f) range:NSMakeRange(0, [address length])];
        addressLabel.attributedText = attributedString;
    } else {
        addressLabel.attributedText = nil;
    }
    [addressLabel sizeToFit];
    addressLabel.center = CGPointMake(headView.center.x, addressLabel.center.y);
    [headView addSubview:addressLabel];
    
    
    CGFloat height = 44.0f;
    UIColor *color = [UIColor whiteColor];
    
    UILabel *saveLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, addressLabel.bottom + 25.0f - 2.0f}, {rect.size.width - originX * 2, height}}];
    saveLabel.backgroundColor = color;
    saveLabel.layer.borderColor = [kAppOrangeColor CGColor];
    saveLabel.layer.borderWidth = 1.0f;
    saveLabel.layer.cornerRadius = 4.0f;
    saveLabel.layer.masksToBounds = YES;
    saveLabel.userInteractionEnabled = YES;
    saveLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
    saveLabel.textAlignment = NSTextAlignmentCenter;
    saveLabel.text = @"保存二维码";
    saveLabel.textColor = kAppOrangeColor;
    [headView addSubview:saveLabel];
    
    UITapGestureRecognizer *saveTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveButtonClicked:)];
    saveTapGesture.delegate = self;
    [saveLabel addGestureRecognizer:saveTapGesture];
    
    
    color = kAppOrangeColor;
    
    UILabel *copyLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, saveLabel.bottom + 15.0f}, {rect.size.width - originX * 2, height}}];
    copyLabel.backgroundColor = color;
    copyLabel.tag = 1;
    copyLabel.layer.cornerRadius = 4.0f;
    copyLabel.layer.masksToBounds = YES;
    copyLabel.userInteractionEnabled = YES;
    copyLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
    copyLabel.textAlignment = NSTextAlignmentCenter;
    copyLabel.text = @"复制地址";
    copyLabel.textColor = [UIColor whiteColor];
    [headView addSubview:copyLabel];
    
    UITapGestureRecognizer *copyTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyButtonClicked:)];
    copyTapGesture.delegate = self;
    [copyLabel addGestureRecognizer:copyTapGesture];
    
    
    
    if ([_wallet.coin.code isEqualToString:@"XRP"]) {
        
        CGFloat bottom = copyLabel.bottom + 30.0f - 2.0f;
        
        NSString *address = _wallet.address;
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tagLabel.numberOfLines = 0;
        tagLabel.frame = (CGRect){{0.0f, bottom + 15.0f - 2.0f}, {280.0f, 0.0f}};
        tagLabel.backgroundColor = [UIColor clearColor];
        if (address) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:address];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineHeightMultiple:1];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [address length])];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14.0f] range:NSMakeRange(0, [address length])];
            [attributedString addAttribute:NSForegroundColorAttributeName value:RGBA(104.0f, 113.0f, 134.0f, 1.0f) range:NSMakeRange(0, [address length])];
            tagLabel.attributedText = attributedString;
        } else {
            tagLabel.attributedText = nil;
        }
        [tagLabel sizeToFit];
        tagLabel.center = CGPointMake(headView.center.x, tagLabel.center.y);
        [headView addSubview:tagLabel];
        
        
        color = kAppOrangeColor;
        
        UILabel *copyLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, tagLabel.bottom + 15.0f}, {rect.size.width - originX * 2, height}}];
        copyLabel.backgroundColor = color;
        copyLabel.tag = 2;
        copyLabel.layer.cornerRadius = 4.0f;
        copyLabel.layer.masksToBounds = YES;
        copyLabel.userInteractionEnabled = YES;
        copyLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0f];
        copyLabel.textAlignment = NSTextAlignmentCenter;
        copyLabel.text = @"复制Tag";
        copyLabel.textColor = [UIColor whiteColor];
        [headView addSubview:copyLabel];
        
        UITapGestureRecognizer *copyTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyButtonClicked:)];
        copyTapGesture.delegate = self;
        [copyLabel addGestureRecognizer:copyTapGesture];
    }
    
    
    return headView;
}

- (UIView *)createFootView:(CGRect)rect
{
    CGFloat originX = 30.0f;
    CGFloat originY = 30.0f;
    
    UIView *footView = [[UIView alloc] initWithFrame:rect];
    footView.backgroundColor = [UIColor clearColor];
    
    NSString *value = [NSString stringWithFormat:@"请勿向上述地址充值任何非%@资产，否则资产将不可找回。\n\n您的充值地址不会经常改变，可以重复充值；如有更改，我们会尽量通过网站公告或邮件通知您。\n\n请务必确认电脑及浏览器安全，防止信息被篡改或泄露。", _wallet.coin.code];
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabel.numberOfLines = 0;
    valueLabel.frame = (CGRect){{originX, originY}, {rect.size.width - originX * 2, 0.0f}};
    valueLabel.backgroundColor = [UIColor clearColor];
    if (value) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:value];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [value length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14.0f] range:NSMakeRange(0, [value length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kFontLightGrayColor range:NSMakeRange(0, [value length])];
        valueLabel.attributedText = attributedString;
    } else {
        valueLabel.attributedText = nil;
    }
    [valueLabel sizeToFit];
    [footView addSubview:valueLabel];
    
    valueLabel.center = CGPointMake(footView.center.x, valueLabel.center.y);
    
    return footView;
}

- (UIView *)createTitleViewWithWallet:(RCHWallet *)wallet
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    CGSize size = (CGSize){20.0f, 20.0f};
    [iconImageView sd_setImageWithURL:[NSURL URLWithString:wallet.icon] placeholderImage:nil];
    iconImageView.frame = (CGRect){{0.0f, 0.0}, size};
    [titleView addSubview:iconImageView];
    
    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    codeLabel.backgroundColor = [UIColor clearColor];
    codeLabel.frame = (CGRect){{iconImageView.right + 10.0f, iconImageView.top}, {280.0f, 0}};
    if (wallet.coin.code) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:wallet.coin.code];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [wallet.coin.code length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:17.0f] range:NSMakeRange(0, [wallet.coin.code length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kFontBlackColor range:NSMakeRange(0, [wallet.coin.code length])];
        codeLabel.attributedText = attributedString;
    } else {
        codeLabel.attributedText = nil;
    }
    [codeLabel sizeToFit];
    [titleView addSubview:codeLabel];
    
    UILabel *enLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    enLabel.frame = (CGRect){{codeLabel.right + 5.0f, iconImageView.top}, {280.0f, 0}};
    enLabel.backgroundColor = [UIColor clearColor];
    if (wallet.coin.name_en) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:wallet.coin.name_en];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:1];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [wallet.coin.name_en length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:13.0f] range:NSMakeRange(0, [wallet.coin.name_en length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kFontLightGrayColor range:NSMakeRange(0, [wallet.coin.name_en length])];
        enLabel.attributedText = attributedString;
    } else {
        enLabel.attributedText = nil;
    }
    [enLabel sizeToFit];
    [titleView addSubview:enLabel];
    
    codeLabel.center = CGPointMake(codeLabel.center.x, iconImageView.center.y);
    enLabel.center = CGPointMake(enLabel.center.x, iconImageView.center.y);
    
    titleView.frame = (CGRect){{0.0f, 0.0}, {enLabel.right, size.height}};
    
    return titleView;
}

@end
