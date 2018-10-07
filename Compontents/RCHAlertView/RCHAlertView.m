//
//  RCHAlertView.m
//  MeiBe
//
//  Created by WangDong on 2018/3/12.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAlertView.h"


@interface RCHAlertView()
{
    UILabel *_titleLabel;
    UILabel *_descriptionLabel;
    UIButton *_submitButton;
    UIImageView *_iconImageView;
}
@property (nonatomic, copy) NSMutableAttributedString *desc;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSMutableAttributedString *title;
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) CGFloat detailViewHeight;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) RCHAlertTableview *detailView;
@property (nonatomic, assign) RCHAlertViewType alertViewType;

@end


@implementation RCHAlertView


+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description imageName:(NSString *)imageName
{
    [RCHAlertView showAlertWithTitle:title description:description imageName:imageName type:RCHAlertViewDefault];
}

+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description imageName:(NSString *)imageName type:(RCHAlertViewType)type
{
    [RCHAlertView showAlertWithTitle:title description:description imageName:imageName buttonTitle:@"好的" type:type];
}

+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description imageName:(NSString *)imageName buttonTitle:(NSString *)buttonTitle type:(RCHAlertViewType)type
{
    RCHAlertView *alertVuew = [[RCHAlertView alloc] initTitle:title description:description imageName:imageName  buttonTitle:buttonTitle  type:type];
    [[UIApplication sharedApplication].delegate.window addSubview:alertVuew];
}
+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description items:(NSMutableArray *)items type:(RCHAlertViewType)type
{
    
    [RCHAlertView showAlertWithTitle:title description:description items:items detailHeight:100.0f type:RCHAlertViewList];
}

+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description items:(NSMutableArray *)items detailHeight:(CGFloat)height type:(RCHAlertViewType)type
{
    [RCHAlertView showAlertWithTitle:title description:description items:items detailHeight:height buttonTitle:@"好的" type:RCHAlertViewList];
}

+ (void)showAlertWithTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description items:(NSMutableArray *)items detailHeight:(CGFloat)height buttonTitle:(NSString *)buttonTitle type:(RCHAlertViewType)type
{
    
    RCHAlertView *alertVuew = [[RCHAlertView alloc] initTitle:title description:description items:items detailHeight:height buttonTitle:buttonTitle type:RCHAlertViewList];
    [[UIApplication sharedApplication].delegate.window addSubview:alertVuew];
}

- (instancetype)initTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description imageName:(NSString *)imageName buttonTitle:(NSString *)buttonTitle type:(RCHAlertViewType)type
{
    self = [super init];
    if (self) {
        self.desc = description;
        self.imageName = imageName;
        self.title = title;
        self.buttonTitle = buttonTitle;
        self.alertViewType = type;
        [self _setupUI];
    }
    return self;
}

- (instancetype)initTitle:(NSMutableAttributedString *)title description:(NSMutableAttributedString *)description items:(NSMutableArray *)items detailHeight:(CGFloat)height  buttonTitle:(NSString *)buttonTitle type:(RCHAlertViewType)type
{
    self = [super init];
    if (self) {
        
        RCHAlertTableview *detailView = [[RCHAlertTableview alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        self.detailViewHeight = height;
        self.items = items;
        self.desc = description;
        self.title = title;
        self.detailView = detailView;
        self.buttonTitle = buttonTitle;
        self.alertViewType = type;
        [self _setupAlertViewListUI];
    }
    return self;
}

- (void)_setupAlertViewListUI
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3/1.0];
    
    //bgView实际高度
    
    CGFloat realWidth =  300.0f;
    CGFloat realHeight = 0.0f;
    //backgroundView
    _bgView = [[UIView alloc]init];
    _bgView.center = self.center;
    _bgView.backgroundColor = [UIColor clearColor];
    _bgView.bounds = CGRectMake(0, 0, realWidth, realHeight);
    [self addSubview:_bgView];
    
    //添加更新提示
    UIView *updateView = [[UIView alloc]initWithFrame:_bgView.bounds];
    updateView.backgroundColor = [UIColor whiteColor];
    updateView.layer.masksToBounds = YES;
    updateView.layer.cornerRadius = 4.0f;
    [_bgView addSubview:updateView];
    
    UIView *topView = [[UIView alloc]initWithFrame:(CGRect){{0.0f, 0.0f}, {updateView.width, 84.0f}}];
    topView.center = self.center;
    topView.backgroundColor = kTabbleViewBackgroudColor;
    [updateView addSubview:topView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 20.0f}, {topView.frame.size.width - 56.0f, 0.0f}}];
    _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.numberOfLines = 1;
    _titleLabel.textColor = kFontBlackColor;
    
    _titleLabel.attributedText = self.title;
    
    [topView addSubview:_titleLabel];
    [_titleLabel sizeToFit];
    
    _descriptionLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, _titleLabel.bottom + 0.0f}, {topView.frame.size.width - 30.0f * 2, 0.0f}}];
    _descriptionLabel.font = [UIFont systemFontOfSize:16.0f];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.textColor = kFontBlackColor;
    
    _descriptionLabel.attributedText = self.desc;
    [topView addSubview:_descriptionLabel];
    [_descriptionLabel sizeToFit];
    
    _detailView.frame = (CGRect){{0.0f, _descriptionLabel.bottom}, {updateView.width, self.detailViewHeight}};
    _detailView.cellHeight = self.detailViewHeight / [self.items count];
    _detailView.items = self.items;
    _detailView.backgroundColor = [UIColor redColor];
    [updateView addSubview:_detailView];
    [_detailView reloadData];
    
    //更新按钮
    _submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _submitButton.backgroundColor = kAppOrangeColor;
    _submitButton.frame = (CGRect){{0.0f, self.detailView.bottom + 27.0f}, {250.0f, 44.0f}};
    _submitButton.clipsToBounds = YES;
    _submitButton.layer.cornerRadius = 4.0f;
    [_submitButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton setTitle:self.buttonTitle forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submitButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    [updateView addSubview:_submitButton];
    
    
    CGFloat originY = 40.0f;
    topView.frame = (CGRect){{0.0f, 0.0f}, topView.frame.size};
    _iconImageView.frame = (CGRect){{_iconImageView.left, originY}, _iconImageView.frame.size};
    
    _titleLabel.frame = (CGRect){{_titleLabel.left, 20.0f}, _titleLabel.frame.size};
    _titleLabel.center = CGPointMake(topView.center.x, _titleLabel.center.y);
    
    _descriptionLabel.frame = (CGRect){{_descriptionLabel.left, _titleLabel.bottom}, _descriptionLabel.frame.size};
    _descriptionLabel.center = CGPointMake(topView.center.x, _descriptionLabel.center.y);
    
    _detailView.frame = (CGRect){{_detailView.left, topView.bottom + 0.0f}, _detailView.frame.size};
    _submitButton.frame = (CGRect){{_submitButton.left, _detailView.bottom + 14.0f}, _submitButton.frame.size};
    _submitButton.center = CGPointMake(updateView.center.x, _submitButton.center.y);
    
    
    
    realHeight =  _submitButton.bottom + 25.0f;
    _bgView.bounds = CGRectMake(0, 0, realWidth, realHeight);
    updateView.frame = _bgView.bounds;
    
    [self showWithAlert:_bgView];
}

- (void)_setupUI
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3/1.0];
    
    //bgView实际高度
    
    CGFloat realWidth =  300.0f;
    CGFloat realHeight = 0.0f;
    //backgroundView
    _bgView = [[UIView alloc]init];
    _bgView.center = self.center;
    _bgView.backgroundColor = [UIColor clearColor];
    _bgView.bounds = CGRectMake(0, 0, realWidth, realHeight);
    [self addSubview:_bgView];
    
    //添加更新提示
    UIView *updateView = [[UIView alloc]initWithFrame:_bgView.bounds];
    updateView.backgroundColor = [UIColor whiteColor];
    updateView.layer.masksToBounds = YES;
    updateView.layer.cornerRadius = 4.0f;
    [_bgView addSubview:updateView];
    
    //20+166+10+28+10+descHeight+20+40+20 = 314+descHeight 内部元素高度计算bgView高度
    UIImage *icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.imageName]];
    _iconImageView = [[UIImageView alloc]initWithFrame:(CGRect){{0.0f, 0.0f}, icon.size}];
    _iconImageView.image = icon;
    _iconImageView.center = CGPointMake(updateView.center.x, _iconImageView.center.y);
    [updateView addSubview:_iconImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, _iconImageView.bottom + 15.0f}, {updateView.frame.size.width - 56.0f, 0.0f}}];
    _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.numberOfLines = 1;
    _titleLabel.textColor = kFontBlackColor;
    
    _titleLabel.attributedText = self.title;
    
    [updateView addSubview:_titleLabel];
    [_titleLabel sizeToFit];
    
    _descriptionLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, _titleLabel.bottom + 0.0f}, {updateView.frame.size.width - 30.0f * 2, 0.0f}}];
    _descriptionLabel.font = [UIFont systemFontOfSize:15.0f];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.textColor = kFontBlackColor;
    
    _descriptionLabel.attributedText = self.desc;
    [updateView addSubview:_descriptionLabel];
    [_descriptionLabel sizeToFit];
    
    _detailView.frame = (CGRect){{0.0f, _descriptionLabel.bottom}, _descriptionLabel.frame.size};
    [updateView addSubview:_detailView];
    
    //更新按钮
    _submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _submitButton.backgroundColor = kAppOrangeColor;
    _submitButton.frame = (CGRect){{0.0f, _detailView.bottom + 27.0f}, {250.0f, 44.0f}};
    _submitButton.clipsToBounds = YES;
    _submitButton.layer.cornerRadius = 4.0f;
    [_submitButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton setTitle:self.buttonTitle forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submitButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    [updateView addSubview:_submitButton];
    
    if (self.alertViewType == RCHAlertViewInfo) {

        CGFloat originY = 40.0f;
        
        _iconImageView.frame = (CGRect){{_iconImageView.left, originY}, _iconImageView.frame.size};
        
        _titleLabel.frame = (CGRect){{_titleLabel.left, _iconImageView.bottom + 20.0f - 2.0}, _titleLabel.frame.size};
        _titleLabel.center = CGPointMake(updateView.center.x, _titleLabel.center.y);
        
        _descriptionLabel.frame = (CGRect){{_descriptionLabel.left, _titleLabel.bottom + 0.0f}, _descriptionLabel.frame.size};
        _descriptionLabel.center = CGPointMake(updateView.center.x, _descriptionLabel.center.y);
        
        _submitButton.frame = (CGRect){{_submitButton.left, _descriptionLabel.bottom + 25.0f - 3.0f}, _submitButton.frame.size};
        _submitButton.center = CGPointMake(updateView.center.x, _submitButton.center.y);
        
        realHeight =  _submitButton.bottom + 25.0f;;
        
        _bgView.bounds = CGRectMake(0, 0, realWidth, realHeight);
        updateView.frame = _bgView.bounds;
        
    } else if (self.alertViewType == RCHAlertViewNotice){
        
        CGFloat originY = 25.0f;
        if (!_iconImageView.image) {
            originY = 25.0f;
            _iconImageView.frame = CGRectZero;
            _titleLabel.frame = (CGRect){{_titleLabel.left, originY}, _titleLabel.frame.size};
        } else {
            _iconImageView.frame = (CGRect){{_iconImageView.left, originY}, _iconImageView.frame.size};
            _titleLabel.frame = (CGRect){{_titleLabel.left, _iconImageView.bottom + 20.0f}, _titleLabel.frame.size};
        }

        _titleLabel.center = CGPointMake(updateView.center.x, _titleLabel.center.y);
        
        _descriptionLabel.frame = (CGRect){{_descriptionLabel.left, _titleLabel.bottom + 15.0f}, _descriptionLabel.frame.size};
        _descriptionLabel.center = CGPointMake(updateView.center.x, _descriptionLabel.center.y);
        
        _submitButton.frame = (CGRect){{_submitButton.left, _descriptionLabel.bottom + 20.0f}, _submitButton.frame.size};
        _submitButton.center = CGPointMake(updateView.center.x, _submitButton.center.y);
        
        realHeight =  _submitButton.bottom + 25.0f;;
        
        _bgView.bounds = CGRectMake(0, 0, realWidth, realHeight);
        updateView.frame = _bgView.bounds;

        
    } else {
        
        CGFloat originY = 40.0f;
        _iconImageView.frame = (CGRect){{_iconImageView.left, originY}, _iconImageView.frame.size};
        
        _titleLabel.frame = (CGRect){{_titleLabel.left, _iconImageView.bottom + 15.0f - 2.0}, _titleLabel.frame.size};
        _titleLabel.center = CGPointMake(updateView.center.x, _titleLabel.center.y);
        
        _descriptionLabel.frame = (CGRect){{_descriptionLabel.left, _titleLabel.bottom + 0.0f}, _descriptionLabel.frame.size};
        _descriptionLabel.center = CGPointMake(updateView.center.x, _descriptionLabel.center.y);
        
        _submitButton.frame = (CGRect){{_submitButton.left, _descriptionLabel.bottom + 27.0f - 3.0f}, _submitButton.frame.size};
        _submitButton.center = CGPointMake(updateView.center.x, _submitButton.center.y);
        realHeight =  240.0f;
        _bgView.bounds = CGRectMake(0, 0, realWidth, realHeight);
        updateView.frame = _bgView.bounds;
    }
    [self showWithAlert:_bgView];
}



- (void)cancelAction
{
    [self dismissAlert];
}


- (void)showWithAlert:(UIView*)alert{
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.0f;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [alert.layer addAnimation:animation forKey:nil];
}

- (void)dismissAlert{
    
    RCHWeak(_bgView);
    [UIView animateWithDuration:0.2f animations:^{
        weak_bgView.transform = (CGAffineTransformMakeScale(0.1, 0.1));
        weak_bgView.backgroundColor = [UIColor clearColor];
        weak_bgView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    } ];
    
}



@end
