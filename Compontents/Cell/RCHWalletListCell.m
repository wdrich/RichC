//
//  RCHWalletListCell.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHWalletListCell.h"
#import "MJLOnePixLineView.h"
#import "UIImageView+WebCache.h"

@interface RCHWalletListCell ()
{
    UIImageView *_walletImageview;
    
    UILabel *_codeLabel;
    UILabel *_balanceLabel;
    UILabel *_cnyLabel;
    
    MJLOnePixLineView *_spacelineView;
}

@end

@implementation RCHWalletListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _walletImageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_walletImageview setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_walletImageview];
        
        _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codeLabel.textColor = kFontBlackColor;
        _codeLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:17.0f];
        _codeLabel.textAlignment = NSTextAlignmentLeft;
        _codeLabel.backgroundColor = [UIColor clearColor];
        _codeLabel.layer.masksToBounds = YES;
        [self addSubview:_codeLabel];
        
        _balanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _balanceLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:17.0f];
        _balanceLabel.backgroundColor = [UIColor clearColor];
        _balanceLabel.numberOfLines = 0;
        _balanceLabel.textAlignment = NSTextAlignmentRight;
        _balanceLabel.textColor = kFontBlackColor;
        [self addSubview:_balanceLabel];
        
        _cnyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cnyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
        _cnyLabel.backgroundColor = [UIColor clearColor];
        _cnyLabel.numberOfLines = 0;
        _cnyLabel.textAlignment = NSTextAlignmentRight;
        _cnyLabel.textColor = kFontLightGrayColor;
        [self addSubview:_cnyLabel];
        
        _spacelineView = [[MJLOnePixLineView alloc] initWithFrame:CGRectZero];
        _spacelineView.lineType = MJLOnePixLineViewImage;
        _spacelineView.lineImageName = @"line_e1_U.png";
        [self addSubview:_spacelineView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originX = 15.0f;
    
    CGFloat originY = (self.height - _walletImageview.height) / 2.0f;
    _walletImageview.frame =  (CGRect){{originX, originY}, _walletImageview.frame.size};
    
    originY = (self.height - _codeLabel.height) / 2.0f;
    _codeLabel.frame = (CGRect){{_walletImageview.right + 10.0f, originY}, _codeLabel.frame.size};
    
    originY = (self.height - _balanceLabel.height - _cnyLabel.height) / 2.0f;
    _balanceLabel.frame = (CGRect){{self.width - originX -_balanceLabel.width, originY}, _balanceLabel.size};
    _cnyLabel.frame = (CGRect){{self.width - originX -_cnyLabel.width, _balanceLabel.bottom}, _cnyLabel.size};
    
    _spacelineView.frame = (CGRect){{0.0f, self.height - 1.0f}, {self.width, 1.0f}};
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark -
#pragma mark - CustomFuction

- (void)setWallet:(RCHWallet *)wallet
{
    _wallet = wallet;
    NSString *defaultString = @"0.00";
    NSMutableAttributedString *attributedString = nil;
    
    {
        CGSize size = (CGSize){20.0f, 20.0f};
        [_walletImageview sd_setImageWithURL:[NSURL URLWithString:_wallet.icon] placeholderImage:nil];
        _walletImageview.frame = (CGRect){{0.0f, 0.0f}, size};
        _codeLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
    }
    
    {
        if (_wallet.coin.code) {
            attributedString = [RCHHelper getMutableAttributedStringe:_wallet.coin.code Font:_codeLabel.font color:_codeLabel.textColor alignment:_codeLabel.textAlignment];
        } else {
            attributedString = [RCHHelper getMutableAttributedStringe:defaultString Font:_codeLabel.font color:_codeLabel.textColor alignment:_codeLabel.textAlignment];
        }
        _codeLabel.attributedText = attributedString;
        [_codeLabel sizeToFit];
    }
    
    {
        _balanceLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        NSString *text = [RCHHelper getNSDecimalString:_wallet.balance defaultString:defaultString precision:_wallet.coin.scale];
        attributedString = [RCHHelper getMutableAttributedStringe:text Font:_balanceLabel.font color:_balanceLabel.textColor alignment:_balanceLabel.textAlignment];
        _balanceLabel.attributedText = attributedString;
        [_balanceLabel sizeToFit];
        _balanceLabel.size = CGSizeMake(_balanceLabel.width, 20.0f);
    }
    
    {
        _cnyLabel.frame = (CGRect){{0.0f, 0.0f}, {280.0f, 0}};
        NSString *text = [RCHHelper getNSDecimalString:_wallet.ecny defaultString:defaultString precision:2 fractionDigitsPadded:YES];
        attributedString = [RCHHelper getMutableAttributedStringe:[NSString stringWithFormat:@"¥ %@", text] Font:_cnyLabel.font color:_cnyLabel.textColor alignment:_cnyLabel.textAlignment];
        _cnyLabel.attributedText = attributedString;
        [_cnyLabel sizeToFit];
        _cnyLabel.size = CGSizeMake(_cnyLabel.width, 20.0f);
    }

}


@end
