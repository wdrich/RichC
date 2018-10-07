//
//  RCHTXDetailViewController.m
//  richcore
//
//  Created by Apple on 2018/6/8.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTXDetailViewController.h"

@implementation RCHRecharge

+ (RCHRecharge *)rechargeWithFlow:(RCHFlow *)flow wallet:(RCHWallet *)wallet {
    RCHRecharge *recharge = [[RCHRecharge alloc] init];
    recharge.flow = flow;
    recharge.wallet = wallet;
    return recharge;
}

@end

#define NAMEWIDTH 50.f

@interface TXDetailView: UIView

@end

@implementation TXDetailView

- (id)initWithFrame:(CGRect)frame
               coin:(RCHCoin *)coin
             amount:(NSString *)amount
             status:(NSString *)status
            address:(NSString *)address
                tag:(NSString *)tag
               txid:(NSString *)txid
               time:(NSString *)time
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *titleView = [self createTitleView:coin];
        titleView.backgroundColor = [UIColor clearColor];
        [self addSubview:titleView];
        
        [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).offset(-10.0f);
            make.top.mas_equalTo(30.0f);
            make.size.mas_equalTo(titleView.size);
        }];
        [self layoutIfNeeded];
        
        NSDictionary *attrs = nil;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentRight];
        [paragraphStyle setLineSpacing:3.f];
        
        attrs = @{
                  NSParagraphStyleAttributeName: paragraphStyle,
                  NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:17.f],
                  NSForegroundColorAttributeName: RGBA(87, 100, 212, 1)
                  };
        
        [self addSubview:[self cellWithFrame:CGRectMake(15, 114, frame.size.width - 30, 24)
                                        name:@"数量"
                                       value:[[NSMutableAttributedString alloc] initWithString:amount attributes:attrs]]];
        
        [self addSubview:[self cellWithFrame:CGRectMake(15, 148, frame.size.width - 30, 24)
                                        name:@"状态"
                                       value:[[NSMutableAttributedString alloc] initWithString:status attributes:attrs]]];
        
        CGFloat top = 231;
        CGFloat padding = 0;
        CGFloat height = 0;
        
        attrs = @{
                  NSParagraphStyleAttributeName: paragraphStyle,
                  NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:15.f],
                  NSForegroundColorAttributeName: RGBA(153, 153, 153, 1)
                  };
        
        height = [address boundingRectWithSize:CGSizeMake(frame.size.width - 30 - NAMEWIDTH, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attrs
                                       context:nil].size.height;
        if (height < 24) {
            height = 24;
        } else {
            padding = padding + (height - 24);
        }
        [self addSubview:[self cellWithFrame:CGRectMake(15, top, frame.size.width - 30, height)
                                        name:@"地址"
                                       value:[[NSMutableAttributedString alloc] initWithString:address attributes:attrs]]];
        
        top = top + height;
        
        if (tag) {
            top = top + 10;
            height = [tag boundingRectWithSize:CGSizeMake(frame.size.width - 30 - NAMEWIDTH, MAXFLOAT)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attrs
                                       context:nil].size.height;
            if (height < 24) {
                height = 24;
            }
            padding = padding + 10 + height;
            [self addSubview:[self cellWithFrame:CGRectMake(15, top, frame.size.width - 30, height)
                                            name:@"Tag"
                                           value:[[NSMutableAttributedString alloc] initWithString:tag attributes:attrs]]];
            top = top + height;
        }
        
        if (txid) {
            top = top + 10;
            height = [txid boundingRectWithSize:CGSizeMake(frame.size.width - 30 - NAMEWIDTH, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attrs
                                        context:nil].size.height;
            if (height < 24) {
                height = 24;
            }
            padding = padding + 10 + height;
            [self addSubview:[self cellWithFrame:CGRectMake(15, top, frame.size.width - 30, height)
                                            name:@"Txid"
                                           value:[[NSMutableAttributedString alloc] initWithString:txid attributes:attrs]]];
            top = top + height;
        }
        
        top = top + 20;
        [self addSubview:[self cellWithFrame:CGRectMake(15, top, frame.size.width - 30, 24)
                                        name:@"时间"
                                       value:[[NSMutableAttributedString alloc] initWithString:time attributes:attrs]]];
        
        CGRect theFrame = self.frame;
        theFrame.size.height += padding;
        self.frame = theFrame;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetLineWidth(context, .5f);
    [RGBA(225.f, 225.f, 225.f, 1.f) setStroke];
    CGContextMoveToPoint(context, 15, 200);
    CGContextAddLineToPoint(context, rect.size.width - 15, 200);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (UIView *)cellWithFrame:(CGRect)frame name:(NSString *)name value:(NSAttributedString *)value
{
    UIView *cell = [[UIView alloc] initWithFrame:frame];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, NAMEWIDTH, 24)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
    nameLabel.textColor = RGBA(51, 51, 51, 1);
    nameLabel.text = name;
    [cell addSubview:nameLabel];
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(NAMEWIDTH, 0, frame.size.width - NAMEWIDTH, frame.size.height)];
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    valueLabel.numberOfLines = 0;
    valueLabel.attributedText = value;
    [cell addSubview:valueLabel];
    
    return cell;
}

- (UIView *)createTitleView:(RCHCoin *)coin
{
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = [UIColor clearColor];
    
    CGSize size = (CGSize){32.0f, 32.0f};
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    iconImageView.backgroundColor = [UIColor clearColor];
    [iconImageView sd_setImageWithURL:[NSURL URLWithString:coin.icon]];
    [titleView addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0.0f);
        make.size.mas_equalTo(size);
    }];
    
    UILabel *codeLabel = [[UILabel alloc] init];
    codeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    codeLabel.backgroundColor = [UIColor clearColor];
    codeLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:17.f];
    codeLabel.textColor = RGBA(51, 51, 51, 1);
    codeLabel.text = coin.code;
    [titleView addSubview:codeLabel];
    [codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iconImageView.mas_top).offset(0.0f);
        make.left.mas_equalTo(iconImageView.mas_right).offset(10.0f);
        make.height.mas_equalTo(18.0f);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.f];
    nameLabel.textColor = RGBA(153, 153, 153, 1);
    nameLabel.text = coin.name_en;
    [titleView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(codeLabel.mas_bottom).offset(0.0f);
        make.left.mas_equalTo(codeLabel.mas_left).offset(0.0f);
        make.height.mas_equalTo(14.0f);
    }];
    
    [titleView layoutIfNeeded];
    
    titleView.size = CGSizeMake(MAX(nameLabel.right,codeLabel.right), iconImageView.bottom);
    return titleView;
}

@end

@interface RCHTXDetailViewController ()
{
    RCHRecharge *_recharge;
    RCHWithdraw *_withdraw;
}
@end

@implementation RCHTXDetailViewController

- (id)initWithRecharge:(RCHRecharge *)recharge;
{
    self = [super init];
    if (self) {
        _recharge = recharge;
    }
    return self;
}

- (id)initWithWithdraw:(RCHWithdraw *)withdraw;
{
    self = [super init];
    if (self) {
        _withdraw = withdraw;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    self.title = _recharge ? @"充币详情" : @"提币详情";
    
    TXDetailView *detailView = nil;
    if (_recharge) {
        detailView = [[TXDetailView alloc] initWithFrame:CGRectMake(0, kAppOriginY, self.view.width, 335)
                                                    coin:_recharge.flow.coin
                                                  amount:[RCHHelper getNSDecimalString:_recharge.flow.quantity
                                                                         defaultString:@""
                                                                             precision:defaultPrecision]
                                                  status:@"已完成"
                                                 address:(_recharge.flow.coin.address ? _recharge.flow.coin.address : _recharge.wallet.address)
                                                     tag:(_recharge.flow.coin.address ? _recharge.wallet.address : nil)
                                                    txid:_recharge.flow.hash_string
                                                    time:[RCHHelper transTimeStringFormat:_recharge.flow.created_at]];
        
    } else {
        detailView = [[TXDetailView alloc] initWithFrame:CGRectMake(0, kAppOriginY, self.view.width, 335)
                                                    coin:_withdraw.coin
                                                  amount:[RCHHelper getNSDecimalString:_withdraw.arrival
                                                                         defaultString:@""
                                                                             precision:defaultPrecision]
                                                  status:_withdraw.status
                                                 address:_withdraw.address
                                                     tag:_withdraw.tag
                                                    txid:_withdraw.hash_string
                                                    time:[RCHHelper transTimeStringFormat:_withdraw.created_at]];
    }
    [self.view addSubview:detailView];
    
    if (_recharge ? _recharge.flow.hash_string == nil : _withdraw.hash_string == nil) return;
    
    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    copyButton.frame = CGRectMake(15, self.view.height - 15.0f - 44.0f - TabbarMiniSafeBottomMargin, self.view.width / 2 - 20, 44);
    copyButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [copyButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyButton setBackgroundColor:RGBA(252, 160, 1, 1) forState:UIControlStateHighlighted];
    copyButton.layer.cornerRadius = 4;
    copyButton.layer.borderColor = RGBA(252, 160, 1, 1).CGColor;
    copyButton.layer.borderWidth = isRetina ? .5f : 1.f;
    copyButton.layer.masksToBounds = YES;
    [copyButton setTitleColor:RGBA(252, 160, 1, 1) forState:UIControlStateNormal];
    [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    copyButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    [copyButton setTitle:@"复制Txid" forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(copyTxid:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:copyButton];
    
    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkButton.frame = CGRectMake(self.view.width / 2 + 5, self.view.height - 15.0f - 44.0f - TabbarMiniSafeBottomMargin, self.view.width / 2 - 20, 44);
    checkButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [checkButton setBackgroundColor:RGBA(252, 160, 1, 1) forState:UIControlStateNormal];
    [checkButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    checkButton.layer.cornerRadius = 4;
    checkButton.layer.borderColor = RGBA(252, 160, 1, 1).CGColor;
    checkButton.layer.borderWidth = isRetina ? .5f : 1.f;
    checkButton.layer.masksToBounds = YES;
    [checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkButton setTitleColor:RGBA(252, 160, 1, 1) forState:UIControlStateHighlighted];
    checkButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.f];
    [checkButton setTitle:@"检查Txid" forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(checkTxid:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)copyTxid:(UIButton *)button {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _recharge ? _recharge.flow.hash_string : _withdraw.hash_string;
    
    UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.width - 120) / 2, self.view.height - 130 - 46, 120, 46)];
    alertLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    alertLabel.backgroundColor = kTextUnselectColor;
    alertLabel.layer.cornerRadius = 2;
    alertLabel.layer.masksToBounds = YES;
    alertLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.f];
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.text = @"已复制";
    [self.view addSubview:alertLabel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertLabel removeFromSuperview];
    });
}

- (void)checkTxid:(UIButton *)button {
    NSString *url = nil;
    if (_recharge) {
        url = [_recharge.flow.coin explore:_recharge.flow.hash_string];
    } else {
        url = [_withdraw.coin explore:_withdraw.hash_string];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
