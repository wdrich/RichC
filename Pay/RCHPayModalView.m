//
//  RCHPayModalView.m
//  richcore
//
//  Created by Apple on 2018/6/11.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHPayModalView.h"
#import "RCHPayViewController.h"

@interface RCHPayModalView ()
{
    void (^_onSubmit)(NSString *, void (^)(NSString *));
    void (^_onComplete)(void);
    BOOL _submitting;
    UINavigationController *_navigationController;
}
@end

@implementation RCHPayModalView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _submitting = NO;
    }
    return self;
}

- (void)displayReq:(RCHPayReq *)req
           payInfo:(RCHPayInfo *)payInfo
          onSubmit:(void (^)(NSString *, void (^)(NSString *)))onSubmit
        onComplete:(void (^)(void))onComplete {
    
    _onSubmit = [onSubmit copy];
    _onComplete = [onComplete copy];
    self.backgroundColor = RGBA(0, 0, 0, .3f);
    
    if (_navigationController) {
        [_navigationController.view removeFromSuperview];
        _navigationController = nil;
    }
    
    RCHPayViewController *payViewController = [[RCHPayViewController alloc] initWithReq:req
                                                                                payInfo:payInfo
                                                                               onSubmit:^(NSString *verifyCode, void (^submitted)(NSString *)) {
                                                                                   if (self->_submitting) return;
                                                                                   self->_submitting = YES;
                                                                                   self->_onSubmit(
                                                                                                   verifyCode,
                                                                                                   ^(NSString *error) {
                                                                                                       self->_submitting = NO;
                                                                                                       submitted(error);
                                                                                                   }
                                                                                                   );
                                                                               }
                                                                                onClose:^(){
                                                                                    if (self->_submitting) return;
                                                                                    [self complete];
                                                                                }];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:payViewController];
    _navigationController.fd_viewControllerBasedNavigationBarAppearanceEnabled = NO;
    _navigationController.view.clipsToBounds = YES;
    _navigationController.view.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 440);
    _navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_navigationController.view];
    
    [UIView animateWithDuration:.15
                     animations:^() {
                         UIView *theView = self->_navigationController.view;
                         theView.frame = CGRectMake(theView.frame.origin.x,
                                                    self.frame.size.height - theView.frame.size.height,
                                                    theView.frame.size.width,
                                                    theView.frame.size.height);
                     }];
}

- (void)complete {
    [UIView animateWithDuration:.15
                     animations:^() {
                         UIView *theView = self->_navigationController.view;
                         theView.frame = CGRectMake(theView.frame.origin.x,
                                                    self.frame.size.height,
                                                    theView.frame.size.width,
                                                    theView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (!finished) return;
                         self->_onComplete();
                     }];
}

@end
