//
//  RCHTextViewController.h
//  richcore
//
//  Created by Dong Wang on 2018/1/25.
//  Copyright © 2018年 Dong Wang. All rights reserved.
//

#import "RCHBaseViewController.h"

@class RCHTextViewController;
@protocol RCHTextViewControllerDataSource <NSObject>

@optional
- (UIReturnKeyType)textViewControllerLastReturnKeyType:(RCHTextViewController *)textViewController;

- (BOOL)textViewControllerEnableAutoToolbar:(RCHTextViewController *)textViewController;

//  控制是否可以点击点击的按钮
- (NSArray <UIButton *> *)textViewControllerRelationButtons:(RCHTextViewController *)textViewController;

@end


@protocol RCHTextViewControllerDelegate <UITextViewDelegate, UITextFieldDelegate>

@optional
#pragma mark - 最后一个输入框点击键盘上的完成按钮时调用
- (void)textViewController:(RCHTextViewController *)textViewController inputViewDone:(id)inputView;
@end

@interface RCHTextViewController : RCHBaseViewController<RCHTextViewControllerDataSource, RCHTextViewControllerDelegate>

- (BOOL)textFieldShouldClear:(UITextField *)textField NS_REQUIRES_SUPER;
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string NS_REQUIRES_SUPER;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_REQUIRES_SUPER;
- (BOOL)textFieldShouldReturn:(UITextField *)textField NS_REQUIRES_SUPER;


@end




#pragma mark - design UITextField
IB_DESIGNABLE
@interface UITextField (RCHTextViewController)

@property (assign, nonatomic) IBInspectable BOOL isEmptyAutoEnable;

@end


@interface RCHTextViewControllerTextField : UITextField

@end

