//
//  RCHSegmentView.m
//  MeiBe
//
//  Created by WangDong on 2018/3/18.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHSegmentView.h"

@interface RCHSegmentView()

@property (nonatomic , strong) NSMutableArray *btnArray;

@end

@implementation RCHSegmentView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 3.0;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = YES;
        [self initDefaults];
        
    }
    return self;
}

- (void)initDefaults{
    self.btnArray = [NSMutableArray new];
    self.btnTitleNormalColor = [UIColor blackColor];
    self.btnTitleSelectColor = [UIColor blackColor];
    self.btnBackgroundNormalColor = [UIColor whiteColor];
    self.btnBackgroundSelectColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    self.titleFont = [UIFont systemFontOfSize:14];
}

-(void)layoutSubviews{
    [self initView];
}

-(void)initView{
    
    RCHWeak(self);
    CGFloat btnW = self.bounds.size.width/_btnTitleArray.count;
    [_btnTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [self getBtn];
        btn.tag = idx;
        [btn setTitle:weakself.btnTitleArray[idx] forState:UIControlStateNormal];
        btn.frame = CGRectMake(btnW*idx + 0.5, 0, btnW, self.bounds.size.height);
//        if (idx == 0) {
//            btn.selected = YES;
//        }
        [self.btnArray addObject:btn];
        
        if (idx<weakself.btnTitleArray.count - 1) {
            UIView *line = [self getLineView];
            line.frame = CGRectMake(btnW*(idx + 1), 0, 0.5, self.bounds.size.height);
            [self bringSubviewToFront:line];
        }
        
    }];
}

-(void)setBtnTitleArray:(NSArray *)btnTitleArray{
    _btnTitleArray = btnTitleArray;
}

-(void)btnClick:(UIButton *)btn{
    
//    if (btn.selected) {
//        return;
//    }
    
    [self.btnArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *otherBtn = (UIButton *)obj;
        if (otherBtn.selected) {
            otherBtn.selected = !otherBtn.selected;
        }
    }];
    
    btn.selected = !btn.selected;
    
    [self performSelector:@selector(setSelectedColor:) withObject:btn afterDelay:0.5];
    
    if (self.rchSegmentBtnSelectIndexBlock) {
        self.rchSegmentBtnSelectIndexBlock(btn.tag);
    }
    
    if ([self.delegate respondsToSelector:@selector(lxSegmentView:selectIndex:)]) {
        [self.delegate lxSegmentView:self selectIndex:btn.tag];
    }
    
}

- (void)setSelectedColor:(UIButton *)btn{
    btn.selected = !btn.isSelected;
}

#pragma mark ---init---
-(UIButton *)getBtn{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    [btn setTitleColor:self.btnTitleNormalColor forState:UIControlStateNormal];
    [btn setTitleColor:self.btnTitleSelectColor forState:UIControlStateSelected];
    [btn setBackgroundImage:[self lx_imageWithColor:self.btnBackgroundNormalColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[self lx_imageWithColor:self.btnBackgroundSelectColor] forState:UIControlStateSelected];
    btn.titleLabel.font = self.titleFont;
    [self addSubview:btn];
    return btn;
}

-(UIView *)getLineView{
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    return line;
}


- (UIImage *)lx_imageWithColor:(UIColor *)color
{
    NSParameterAssert(color != nil);
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
