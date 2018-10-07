//
//  RCHTopBar.m
//  MeiBe
//
//  Created by WangDong on 2018/3/17.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTopBar.h"

#define bottomViewW 6.0

@interface RCHTopBar()
{
    CGRect _fram;
    UIView *_linView;
    NSArray *_normalImages;
    NSArray *_seletedImages;
    NSInteger _selectedIndex;
}

@property(nonatomic,strong)UIView *linView;

@end

@implementation RCHTopBar



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _fram = frame;
        _normalImages = [NSArray array];
        _seletedImages = [NSArray array];
        _lineHeight = 2.0f;
        _lineWidth = 0.0f;
        _itemPadding = 30.0f;
        _isFitTextWidth = NO;
        _lastButtonActive = YES;
    }
    return self;
}

- (void)loadTitleArray:(NSArray *)titleArray selectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex < [titleArray count] ? selectedIndex : 0;
    _titleArray = titleArray;
    [self loadMainView];
}

- (void)loadTitleArray:(NSArray *)titleArray
{
    _selectedIndex = 0;
    _titleArray = titleArray;
    [self loadMainView];
}

- (void)loadNormalImage:(NSArray *)normalImages seletedImage:(NSArray *)seletedImage
{
    _normalImages = normalImages;
    for (int i = 0; i< normalImages.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(_fram.size.width/normalImages.count), 0, _fram.size.width/normalImages.count, _fram.size.height-2);
        button.tag = 10 + i;
        [button setImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
        if (seletedImage != nil) {
            [button setImage:[UIImage imageNamed:seletedImage[i]] forState:UIControlStateSelected];
        }
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)loadMainView
{
    switch (_type) {
        case PiecewiseInterfaceTypeMobileLine:
        {
            [self loadMobileLinView];
        }
            break;
        case PiecewiseInterfaceTypeBackgroundChange:
        {
            [self loadBackgroundChangeView];
        }
            break;
        case PiecewiseInterfaceTypeCustom:
        {
            [self loadCustomView];
        }
            break;
        default:
            break;
    }
}

- (void)loadMobileLinView
{
    if (!_textSeletedColor) {
        _textSeletedColor = _textNormalColor;
    }
    [self removeAllSubviews];
    if ([_titleArray count] == 0) return;
    NSString *title =  [_titleArray objectAtIndex:_selectedIndex];
    CGFloat width = [self getLineWidth:title] + 10;
    _linView = [[UIView alloc]initWithFrame:CGRectMake(0, _fram.size.height-_lineHeight, width, _lineHeight)];
    _linView.backgroundColor = _linColor;
    _linView.center = CGPointMake(_fram.size.width/_titleArray.count * (_selectedIndex + 0.5f), _linView.center.y);
    _linView.layer.cornerRadius = _lineHeight * 0.5;
    _linView.layer.masksToBounds = YES;
    [self addSubview:_linView];
    for (int i = 0; i < _titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(_fram.size.width/_titleArray.count), 0, _fram.size.width/_titleArray.count, _fram.size.height-_lineHeight);
        button.tag = 10 + i;
        button.titleLabel.font = _textFont;
        [button setTitleColor:(i == _selectedIndex ? _textSeletedColor : _textNormalColor) forState:UIControlStateNormal];
        [button setTitle:_titleArray[i] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)loadBackgroundChangeView
{
    if (!_textSeletedColor) {
        _textSeletedColor = _textNormalColor;
    }
    if ([_titleArray count] == 0) return;
    for (int i = 0; i < _titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(_fram.size.width/_titleArray.count), 0, _fram.size.width/_titleArray.count, _fram.size.height);
        button.tag = 10 + i;
        button.titleLabel.font = _textFont;
        [button setBackgroundColor:(i == _selectedIndex ? _backgroundSeletedColor : _backgroundNormalColor) forState:UIControlStateNormal];
        [button setTitleColor:(i == _selectedIndex ? _textSeletedColor : _textNormalColor) forState:UIControlStateNormal];
        [button setTitle:_titleArray[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)loadCustomView
{
    if (!_textSeletedColor) {
        _textSeletedColor = _textNormalColor;
    }
    [self removeAllSubviews];
    if ([_titleArray count] == 0) return;
    NSString *title =  [_titleArray objectAtIndex:_selectedIndex];
    CGFloat linewidth = [self getLineWidth:title];
    CGFloat itemWidth = _fram.size.width/_titleArray.count;
    _linView = [[UIView alloc]initWithFrame:CGRectMake((itemWidth - linewidth) / 2.0, _fram.size.height-_lineHeight, linewidth, _lineHeight)];
    _linView.backgroundColor = _linColor;
    _linView.layer.cornerRadius = _lineHeight * 0.5;
    _linView.layer.masksToBounds = YES;
    [self addSubview:_linView];
    
    for (int i = 0; i < _titleArray.count; i++) {
        NSString *title = [_titleArray[i] objectForKey:@"title"];
        UIImage *image = [_titleArray[i] objectForKey:@"image"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(itemWidth + _itemPadding), 0, itemWidth, _fram.size.height);
        button.backgroundColor = [UIColor clearColor];
        button.tag = 10 + i;
        button.titleLabel.font = _textFont;
        [button setTitleColor:(i == _selectedIndex ? _textSeletedColor : _textNormalColor) forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        [button sizeToFit];
        button.height = _fram.size.height;
        
        [button.titleLabel setBackgroundColor:[UIColor clearColor]];
        if (image) {
            
            NSDictionary *attribute = @{NSFontAttributeName: _textFont};
            
            CGSize size = [title boundingRectWithSize:CGSizeMake(300, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
            button.k_width = size.width + image.size.width + 5.0f;
            [button setImage:image forState:UIControlStateNormal];
            [button.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0.0f);
                make.right.mas_equalTo(-(image.size.width));
            }];
            [button.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(button.titleLabel.mas_right).offset(0.0f);
                make.size.mas_equalTo(image.size);
            }];

            _linView.k_x = (button.width - linewidth) / 2.0;
        }
        
        if (i == 1 ) {
            button.k_x = 100.0f - 15.0f;
        } else if (i == 2) {
            button.k_x = 160.0f - 15.0f;
        }
        
        
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (CGFloat)getLineWidth:(NSString *)title
{
    CGFloat width;
    if (_isFitTextWidth) {
        CGSize size = [title boundingRectWithSize:(CGSize){MAXFLOAT, 16.0f}
                                         options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:_textFont}
                                         context:nil].size;
        width = size.width;
        
    } else {
        if (_lineWidth > 0) {
            width = _lineWidth;
        } else {
            width = _fram.size.width/_titleArray.count;
        }
    }
    
    return width;
}

- (void)buttonPressed:(UIButton *)sender
{
    _selectedIndex = sender.tag - 10;
    if ((sender.tag - 10 == _titleArray.count - 1) && !self.lastButtonActive) {
        if (_delegate &&[_delegate respondsToSelector:@selector(piecewiseView:button:index:)]){
            [self.delegate piecewiseView:self button:sender index:sender.tag - 10];
        }
        return;
    }
    
    RCHWeak(self);
    switch (_type) {
        case PiecewiseInterfaceTypeMobileLine:
        {
            [UIView animateWithDuration:0.3 animations:^{
                NSString *title =  [weakself.titleArray objectAtIndex:sender.tag - 10];
                CGFloat width = [self getLineWidth:title] + 10;
                weakself.linView.frame = CGRectMake(sender.frame.origin.x, weakself.linView.frame.origin.y, width, weakself.lineHeight);
                weakself.linView.center = CGPointMake(sender.center.x, weakself.linView.center.y);
                
            } completion:nil];
            for (int i = 0; i<_titleArray.count; i++) {
                UIButton *button = (UIButton *)[self viewWithTag:i + 10];
                [button setTitleColor:(sender.tag == (i+10) ? _textSeletedColor : _textNormalColor) forState:UIControlStateNormal];
            }
        }
            break;
        case PiecewiseInterfaceTypeBackgroundChange:
        {
            for (int i = 0; i<_titleArray.count; i++) {
                UIButton *button = (UIButton *)[self viewWithTag:i + 10];
                [button setBackgroundColor:(sender.tag == (i+10) ? _backgroundSeletedColor : _backgroundNormalColor) forState:UIControlStateNormal];
                [button setTitleColor:(sender.tag == (i+10) ? _textSeletedColor : _textNormalColor) forState:UIControlStateNormal];
            }
            
        }
            break;
        case PiecewiseInterfaceTypeCustom:
        {
            [UIView animateWithDuration:0.3 animations:^{
                NSString *title =  [[weakself.titleArray objectAtIndex:sender.tag - 10] objectForKey:@"title"];
                CGFloat width = [self getLineWidth:title];
                weakself.linView.frame = CGRectMake(sender.frame.origin.x, weakself.linView.frame.origin.y, width, weakself.lineHeight);
                weakself.linView.center = CGPointMake(sender.center.x, weakself.linView.center.y);
                
            } completion:nil];
            for (int i = 0; i<_titleArray.count; i++) {
                UIButton *button = (UIButton *)[self viewWithTag:i + 10];
                [button setTitleColor:(sender.tag == (i+10) ? _textSeletedColor : _textNormalColor) forState:UIControlStateNormal];
            }
        }
            break;
            
        default:
            break;
    }
    
    if (_delegate &&[_delegate respondsToSelector:@selector(piecewiseView:button:index:)]){
        [self.delegate piecewiseView:self button:sender index:sender.tag - 10];
    }
}

@end
