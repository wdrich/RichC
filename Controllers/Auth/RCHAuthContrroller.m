//
//  RCHAuthContrroller.m
//  MeiBe
//
//  Created by WangDong on 2018/3/27.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAuthContrroller.h"
#import "SPPageMenu.h"
#import "RCHSecondAuthController.h"

#define scrollViewHeight (kMainScreenHeight - kTabBarHeight - kNavigationBarHeight - pageMenuHeight)

@interface RCHAuthContrroller () <SPPageMenuDelegate, UIScrollViewDelegate>
{
    NSMutableArray *_categorys;
    void (^ _Nonnull _completion)(RCHSecondAuth, NSString *);
}

@property (nonatomic, weak) SPPageMenu *pageMenu;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *myChildViewControllers;

@end

@implementation RCHAuthContrroller

- (instancetype)initWithCompletion:( void (^ _Nonnull )(RCHSecondAuth, NSString *))completion
{
    self = [super init];
    if (self) {
        _completion = [completion copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"二次验证",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;

    _categorys = [self getCategorys];
    
    [self createControllers:_categorys];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, pageMenuHeight, kMainScreenWidth, scrollViewHeight)];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
    [self createPageMenu:_categorys];
    
    self.pageMenu.bridgeScrollView = self.scrollView;
    
    if (self.pageMenu.selectedItemIndex < self.myChildViewControllers.count) {
        UIViewController *baseController = self.myChildViewControllers[self.pageMenu.selectedItemIndex];
        [scrollView addSubview:baseController.view];
        baseController.view.frame = CGRectMake(kMainScreenWidth*self.pageMenu.selectedItemIndex, 0, kMainScreenWidth, scrollViewHeight);
        scrollView.contentOffset = CGPointMake(kMainScreenWidth*self.pageMenu.selectedItemIndex, 0);
        scrollView.contentSize = CGSizeMake(_categorys.count*kMainScreenWidth, 0);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - getter

- (NSMutableArray *)myChildViewControllers {
    
    if (!_myChildViewControllers) {
        _myChildViewControllers = [NSMutableArray array];
        
    }
    return _myChildViewControllers;
}

#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 这一步是实现跟踪器时刻跟随scrollView滑动的效果,如果对self.pageMenu.scrollView赋了值，这一步可省
    // [self.pageMenu moveTrackerFollowScrollView:scrollView];
}



#pragma mark -
#pragma mark - CustomFuction

- (NSMutableArray *)getCategorys {
    NSMutableArray *categorys = [NSMutableArray arrayWithArray:@[@"短信验证", @"谷歌验证"]];
    return categorys;
}

- (void)createPageMenu:(NSArray *)categorys {
    
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, kAppOriginY, kMainScreenWidth, pageMenuHeight) trackerStyle:SPPageMenuTrackerStyleLine];
    
    [pageMenu setItems:categorys selectedItemIndex:0];
    [pageMenu setSelectedItemTitleColor:kAppOrangeColor];
    [pageMenu setUnSelectedItemTitleColor:kligthWiteColor];
    pageMenu.tracker.backgroundColor = kAppOrangeColor;
    pageMenu.dividingLine.backgroundColor = [UIColor clearColor];
    pageMenu.itemTitleFont = [UIFont systemFontOfSize:15.0f];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    pageMenu.contentInset = UIEdgeInsetsMake(2.0f,46.0f,0,46.0f);
    pageMenu.dividingLineHeight = 0.0f;
    [pageMenu setBackgroundColor:kNavigationColor_MB];
    // 设置代理
    pageMenu.delegate = self;
    [self.view addSubview:pageMenu];
    _pageMenu = pageMenu;
}

- (void)createControllers:(NSArray *)categorys {

    RCHSecondAuthController *viewcontroller;
    for (int i = 0; i < categorys.count; i ++) {
        switch (i) {
            case 0:
                viewcontroller = [[RCHSecondAuthController alloc] initWithSecondAuthType:RCHSecondAuthTypeMobie
                                                                              completion:_completion];
                break;
            case 1:
                viewcontroller = [[RCHSecondAuthController alloc] initWithSecondAuthType:RCHSecondAuthTypeGoogle
                                                                              completion:_completion];
                break;
            default:
                viewcontroller = [[RCHSecondAuthController alloc] initWithSecondAuthType:RCHSecondAuthTypeMobie
                                                                              completion:_completion];
                break;
        }
        viewcontroller.offsetY = pageMenuHeight;
        [self addChildViewController:viewcontroller];
        [self.myChildViewControllers addObject:viewcontroller];
        
    }
    
}

#pragma mark - SPPageMenu的代理方法

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedAtIndex:(NSInteger)index {
    NSLog(@"%zd",index);
}

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    NSLog(@"%zd------->%zd",fromIndex,toIndex);
    // 如果fromIndex与toIndex之差大于等于2,说明跨界面移动了,此时不动画.
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (labs(toIndex - fromIndex) >= 2) {
        [self.scrollView setContentOffset:CGPointMake(kMainScreenWidth * toIndex, 0) animated:NO];
    } else {
        [self.scrollView setContentOffset:CGPointMake(kMainScreenWidth * toIndex, 0) animated:YES];
    }
    if (self.myChildViewControllers.count <= toIndex) {return;}
    
    UIViewController *targetViewController = self.myChildViewControllers[toIndex];
    // 如果已经加载过，就不再加载
    if ([targetViewController isViewLoaded]) return;
    
    targetViewController.view.frame = CGRectMake(kMainScreenWidth * toIndex, 0, kMainScreenWidth, scrollViewHeight);
    [_scrollView addSubview:targetViewController.view];
    
}


@end
