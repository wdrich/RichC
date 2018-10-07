//
//  RCHFlowsController.m
//  richcore
//
//  Created by WangDong on 2018/6/6.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHFlowsController.h"
#import "SPPageMenu.h"
#import "RCHHistoryFlowsController.h"
#import "RCHWithdrawsController.h"

#define scrollViewHeight (kMainScreenHeight -  kAppOriginY - pageMenuHeight)

@interface RCHFlowsController () <SPPageMenuDelegate, UIScrollViewDelegate>
{
    NSMutableArray *_categorys;
    BOOL _fromWithdraw;
    NSInteger _selectIndex;
}

@property (nonatomic, weak) SPPageMenu *pageMenu;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *myChildViewControllers;


@end

@implementation RCHFlowsController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fromWithdraw = NO;
        _selectIndex = 0;
    }
    return self;
}

- (instancetype)initWithSelectIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _fromWithdraw = NO;
        _selectIndex = index;
    }
    return self;
}

- (instancetype)initFromWithdraw
{
    self = [super init];
    if (self) {
        _fromWithdraw = YES;
        _selectIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"历史记录",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    _categorys = [self getCategorys];
    [self createPageMenu:_categorys];
    
    [self createControllers:_categorys];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, pageMenuHeight + kAppOriginY, kMainScreenWidth, scrollViewHeight)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    _scrollView = scrollView;

    // 这一行赋值，可实现pageMenu的跟踪器时刻跟随scrollView滑动的效果
    self.pageMenu.bridgeScrollView = self.scrollView;
    
    // pageMenu.selectedItemIndex就是选中的item下标
    if (self.pageMenu.selectedItemIndex < self.myChildViewControllers.count) {
        UIViewController *baseController = self.myChildViewControllers[self.pageMenu.selectedItemIndex];
        [scrollView addSubview:baseController.view];
        baseController.view.frame = CGRectMake(kMainScreenWidth*self.pageMenu.selectedItemIndex, 0, kMainScreenWidth, scrollViewHeight);
        scrollView.contentOffset = CGPointMake(kMainScreenWidth*self.pageMenu.selectedItemIndex, 0);
        scrollView.contentSize = CGSizeMake(_categorys.count*kMainScreenWidth, 0);
    }
    
    [self.view bringSubviewToFront:self.pageMenu];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)leftButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar
{
    if (_fromWithdraw && [[self.navigationController viewControllers] count] > 3) {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    } else {
        [super leftButtonEvent:sender navigationBar:navigationBar];
    }
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
    NSMutableArray *categorys = [NSMutableArray arrayWithArray:@[@"充币记录", @"提币记录"]];
    if ([RCHHelper valueForKey:kCurrentUserRoles] && [(NSArray *)[RCHHelper valueForKey:kCurrentUserRoles] containsObject:@"ROLE_SHARE"]) {
        [categorys addObject:@"释放明细"];
    }
    return categorys;
}

- (void)createPageMenu:(NSArray *)categorys {
    // trackerStyle:跟踪器的样式
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, kAppOriginY, kMainScreenWidth, pageMenuHeight) trackerStyle:SPPageMenuTrackerStyleLine];
    // 传递数组，默认选中第1个
    
    [pageMenu setItems:categorys selectedItemIndex:0];
    [pageMenu setSelectedItemTitleColor:kAppOrangeColor];
    [pageMenu setUnSelectedItemTitleColor:kligthWiteColor];
    pageMenu.tracker.backgroundColor = kAppOrangeColor;
    pageMenu.dividingLine.backgroundColor = [UIColor clearColor];
    pageMenu.itemTitleFont = [UIFont systemFontOfSize:15.0f];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    pageMenu.contentInset = UIEdgeInsetsMake(2.0f, 4.0f, 0.0f, 4.0f);
    pageMenu.dividingLineHeight = 0.0f;
    pageMenu.trackerWidth = 30.0f;
    [pageMenu setBackgroundColor:kNavigationColor_MB];
    
    if (_fromWithdraw) {
        [pageMenu setSelectedItemIndex:1];
    } else {
        [pageMenu setSelectedItemIndex:(categorys.count > _selectIndex) ? _selectIndex : 0];
    }
    
    // 设置代理
    pageMenu.delegate = self;
    [self.view addSubview:pageMenu];
    self.pageMenu = pageMenu;
}

- (void)createControllers:(NSArray *)categorys {
    
    RCHBaseViewController *viewcontroller;
    for (int i = 0; i < categorys.count; i ++) {
        switch (i) {
            case 0:
                viewcontroller = [[RCHHistoryFlowsController alloc] initWithFlowsType:RCHFlowsTypeRecharge];
                break;
            case 1:
                viewcontroller = [[RCHWithdrawsController alloc] init];
                break;
            case 2:
                viewcontroller = [[RCHHistoryFlowsController alloc] initWithFlowsType:RCHFlowsTypeShareUnlock];
                break;
            default:
                viewcontroller = [[RCHHistoryFlowsController alloc] initWithFlowsType:RCHFlowsTypeRecharge];
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
