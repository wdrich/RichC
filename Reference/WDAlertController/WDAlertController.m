//
//  WDAlertController.m
//  richcore
//
//  Created by WangDong on 2018/5/29.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "WDAlertController.h"
#import <UIWindow+CurrentViewController.h>

//toast默认展示时间
static NSTimeInterval const WDAlertShowDurationDefault = 1.0f;


#pragma mark - I.AlertActionModel

@interface WDAlertActionModel : NSObject
@property (nonatomic, copy) NSString * title;
@property (nonatomic, assign) UIAlertActionStyle style;
@end
@implementation WDAlertActionModel
- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"";
        self.style = UIAlertActionStyleDefault;
    }
    return self;
}
@end



#pragma mark - II.WDAlertController
/**
 AlertActions配置
 
 @param actionBlock WDAlertActionBlock
 */
typedef void (^WDAlertActionsConfig)(WDAlertActionBlock actionBlock);


@interface WDAlertController ()
//WDAlertActionModel数组
@property (nonatomic, strong) NSMutableArray <WDAlertActionModel *>* wd_alertActionArray;
//是否操作动画
@property (nonatomic, assign) BOOL wd_setAlertAnimated;
//action配置
- (WDAlertActionsConfig)alertActionsConfig;
@end

@implementation WDAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.alertDidDismiss) {
        self.alertDidDismiss();
    }
}
- (void)dealloc
{
    NSLogFunc;
}

#pragma mark - Private
//action-title数组
- (NSMutableArray<WDAlertActionModel *> *)wd_alertActionArray
{
    if (_wd_alertActionArray == nil) {
        _wd_alertActionArray = [NSMutableArray array];
    }
    return _wd_alertActionArray;
}
//action配置
- (WDAlertActionsConfig)alertActionsConfig
{
    return ^(WDAlertActionBlock actionBlock) {
        if (self.wd_alertActionArray.count > 0)
        {
            //创建action
            __weak typeof(self)weakSelf = self;
            
            [self.wd_alertActionArray enumerateObjectsUsingBlock:^(WDAlertActionModel *actionModel, NSUInteger idx, BOOL * _Nonnull stop) {
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionModel.title style:actionModel.style handler:^(UIAlertAction * _Nonnull action) {
                    __strong typeof(weakSelf)strongSelf = weakSelf;
                    if (actionBlock) {
                        actionBlock(idx, action, strongSelf);
                    }
                }];
                //可利用这个改变字体颜色，但是不推荐！！！
                //                [alertAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
                //action作为self元素，其block实现如果引用本类指针，会造成循环引用
                [weakSelf addAction:alertAction];
            }];
        }
        else
        {
            NSTimeInterval duration = self.toastStyleDuration > 0 ? self.toastStyleDuration : WDAlertShowDurationDefault;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:!(self.wd_setAlertAnimated) completion:NULL];
            });
        }
    };
}

#pragma mark - Public

- (instancetype)initAlertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    if (!(title.length > 0) && (message.length > 0) && (preferredStyle == UIAlertControllerStyleAlert)) {
        title = @"";
    }
    
    self = [[self class] alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if (!self) return nil;
    
    self.wd_setAlertAnimated = NO;
    self.toastStyleDuration = WDAlertShowDurationDefault;
    
    return self;
}


- (void)alertAnimateDisabled
{
    self.wd_setAlertAnimated = YES;
}


#pragma mark - addButton

- (WDAlertActionTitle)addActionDefaultTitle
{
    //该block返回值不是本类属性，只是局部变量，不会造成循环引用
    return ^(NSString *title) {
        WDAlertActionModel *actionModel = [[WDAlertActionModel alloc] init];
        actionModel.title = title;
        actionModel.style = UIAlertActionStyleDefault;
        [self.wd_alertActionArray addObject:actionModel];
        return self;
    };
}

- (WDAlertActionTitle)addActionCancelTitle
{
    return ^(NSString *title) {
        WDAlertActionModel *actionModel = [[WDAlertActionModel alloc] init];
        actionModel.title = title;
        actionModel.style = UIAlertActionStyleCancel;
        [self.wd_alertActionArray addObject:actionModel];
        return self;
    };
}

- (WDAlertActionTitle)addActionDestructiveTitle
{
    return ^(NSString *title) {
        WDAlertActionModel *actionModel = [[WDAlertActionModel alloc] init];
        actionModel.title = title;
        actionModel.style = UIAlertActionStyleDestructive;
        [self.wd_alertActionArray addObject:actionModel];
        return self;
    };
}

@end



#pragma mark - III.UIViewController扩展
@implementation UIViewController (WDAlertController)

- (void)wd_showAlertWithPreferredStyle:(UIAlertControllerStyle)preferredStyle title:(NSString *)title message:(NSString *)message appearanceProcess:(WDAlertAppearanceProcess)appearanceProcess actionsBlock:(WDAlertActionBlock)actionBlock
{
    if (appearanceProcess)
    {
        WDAlertController *alertMaker = [[WDAlertController alloc] initAlertControllerWithTitle:title message:message preferredStyle:preferredStyle];
        //防止nil
        if (!alertMaker) {
            return ;
        }
        //加工链
        !appearanceProcess ?: appearanceProcess(alertMaker);
        //配置响应
        alertMaker.alertActionsConfig(actionBlock);
        
        [self presentViewController:alertMaker animated:!(alertMaker.wd_setAlertAnimated) completion:^{
            !alertMaker.alertDidShown ?: alertMaker.alertDidShown();
        }];
    }
}

- (void)wd_showAlertWithTitle:(NSString *)title message:(NSString *)message appearanceProcess:(WDAlertAppearanceProcess)appearanceProcess actionsBlock:(WDAlertActionBlock)actionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self wd_showAlertWithPreferredStyle:UIAlertControllerStyleAlert title:title message:message appearanceProcess:appearanceProcess actionsBlock:actionBlock];
    });
}

- (void)wd_showActionSheetWithTitle:(NSString *)title message:(NSString *)message appearanceProcess:(WDAlertAppearanceProcess)appearanceProcess actionsBlock:(WDAlertActionBlock)actionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self wd_showAlertWithPreferredStyle:UIAlertControllerStyleActionSheet title:title message:message appearanceProcess:appearanceProcess actionsBlock:actionBlock];
    });
}


@end

@implementation UIAlertController (WD)

/**
 WDAlertController: show-alert(iOS8)
 
 @param title             title
 @param message           message
 @param appearanceProcess alert配置过程
 @param actionBlock       alert点击响应回调
 */
+ (void)wd_showAlertWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
            appearanceProcess:(WDAlertAppearanceProcess)appearanceProcess
                 actionsBlock:(nullable WDAlertActionBlock)actionBlock NS_AVAILABLE_IOS(8_0)
{
    [[UIWindow zf_currentViewController] wd_showAlertWithTitle:title message:message appearanceProcess:appearanceProcess actionsBlock:actionBlock];
}

/**
 WDAlertController: show-actionSheet(iOS8)
 
 @param title             title
 @param message           message
 @param appearanceProcess actionSheet配置过程
 @param actionBlock       actionSheet点击响应回调
 */
+ (void)wd_showActionSheetWithTitle:(nullable NSString *)title
                            message:(nullable NSString *)message
                  appearanceProcess:(WDAlertAppearanceProcess)appearanceProcess
                       actionsBlock:(nullable WDAlertActionBlock)actionBlock NS_AVAILABLE_IOS(8_0)
{
    [[UIWindow zf_currentViewController] wd_showActionSheetWithTitle:title message:message appearanceProcess:appearanceProcess actionsBlock:actionBlock];
}
@end
