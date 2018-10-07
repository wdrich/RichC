//
//  RCHQuotesController.m
//  richcore
//
//  Created by WangDong on 2018/5/20.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHQuotesController.h"
#import "SPPageMenu.h"
#import "RCHMarket.h"
#import "RCHQuoteSortView.h"
#import "RCHMarketQuotesViewController.h"

#define defaultCellHeight 80.0f
#define MaxRequestCount 3

@interface RCHQuotesController () <SPPageMenuDelegate, UIGestureRecognizerDelegate>
{
    NSArray *_marketGroups;
    NSUInteger _requestCount;
    SPPageMenu *_pageMenu;
    UIScrollView *_scrollView;
    NSDictionary *_currentGroup;
}

@end

@implementation RCHQuotesController

- (id)init {
    self = [super init];
    if (self) {
        _currentGroup = nil;
        _marketGroups = @[];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getMarketsSuccess:)
                                                     name:kGetMarketsSuccessNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getMarketsFailed:)
                                                     name:kGetMarketsFailedNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"行情",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    if ([[RCHGlobal sharedGlobal] marketsArray] == nil) {
        [self refresh];
    } else {
        [self reloadMarkets];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - CustomFuction

- (void)loadMenuAndScrollView {
    [self.view removeSubviews];
    
    _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, kAppOriginY, self.view.frame.size.width, pageMenuHeight)
                                 trackerStyle:SPPageMenuTrackerStyleLine];
    _pageMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_pageMenu setSelectedItemTitleColor:kAppOrangeColor];
    [_pageMenu setUnSelectedItemTitleColor:kligthWiteColor];
    _pageMenu.tracker.backgroundColor = kAppOrangeColor;
    _pageMenu.dividingLine.backgroundColor = [UIColor clearColor];
    _pageMenu.itemTitleFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:15.0f];
    _pageMenu.permutationWay = SPPageMenuPermutationWayScrollAdaptContent;
    _pageMenu.contentInset = UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f);
    _pageMenu.trackerWidth = 30.0f;
    _pageMenu.itemPadding = 10.0f;
    _pageMenu.dividingLineHeight = 0.0f;
    [_pageMenu setBackgroundColor:kNavigationColor_MB];
    _pageMenu.delegate = self;
    [self.view addSubview:_pageMenu];
    
    RCHQuoteSortView *sortView = [[RCHQuoteSortView alloc] init];
    [sortView setBackgroundColor:kLightGreenColor];
    [self.view addSubview:sortView];
    [sortView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kAppOriginY + pageMenuHeight);
        make.left.right.mas_equalTo(0.0f);
        make.height.mas_equalTo(40.0f);
    }];
//    [self.view layoutIfNeeded];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kAppOriginY + pageMenuHeight + 40.0f, self.view.frame.size.width, self.view.frame.size.height - kAppOriginY - pageMenuHeight - kTabBarHeight - 40.0f)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    _pageMenu.bridgeScrollView = _scrollView;
}

- (void)sendMarketsRequest
{
    _requestCount = _requestCount + 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetMarketsNotification object:nil];
    });
}

- (void)refresh
{
    if (_currentGroup == nil) {
        [self.view removeSubviews];
        [MBProgressHUD showLoadToView:self.view];
    }
    _requestCount = 0;
    [self sendMarketsRequest];
}

#pragma mark -
#pragma mark - Notifications

- (void)getMarketsSuccess:(NSNotification *)notification
{
    if (_currentGroup == nil) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
    }
    [self reloadMarkets];
}

- (void)getMarketsFailed:(NSNotification *)notification
{
    if (_requestCount < MaxRequestCount) {
        [self sendMarketsRequest];
    } else {
        if (_currentGroup == nil) {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [self showEmptyView];
        } else {
            [self resume];
        }
        
    }
}

- (void)showEmptyView {
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kAppOriginY, kScreenWidth, kScreenHeight - kAppOriginY - kTabBarHeight)];
    emptyLabel.backgroundColor = [UIColor clearColor];
    emptyLabel.textColor = kFontLightGrayColor;
    emptyLabel.font = [UIFont systemFontOfSize:14.0f];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.text = @"没有行情信息，点击刷新";
    emptyLabel.userInteractionEnabled = YES;
    [self.view addSubview:emptyLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptyClicked:)];
    [emptyLabel addGestureRecognizer:tap];
}

- (void)emptyClicked:(UIGestureRecognizer *)recognizer {
    [self refresh];
}

- (void)resume {
    if (!_currentGroup) return;
    
    [self setEnable:YES];
    
    NSUInteger index = [_marketGroups indexOfObject:_currentGroup];
    if (!(index < [self.childViewControllers count])) return;
    [(RCHMarketQuotesViewController *)[self.childViewControllers objectAtIndex:index] reloadWithMarketGroup:_currentGroup];
    
    _currentGroup = nil;
}

- (void)setEnable:(BOOL)enable {
    if (_pageMenu) {
        for (NSUInteger i = 0; i < [_marketGroups count]; i++) {
            [_pageMenu setEnabled:enable forItemAtIndex:i];
        }
    }
    if (_scrollView) {
        [_scrollView setScrollEnabled:enable];
    }
}

- (void)reloadMarkets {
    if ([[RCHGlobal sharedGlobal] marketsArray] && [[[RCHGlobal sharedGlobal] marketsArray] count] > 0)
    {
        if (_currentGroup == nil) {
            [self loadMenuAndScrollView];
        }
        [_scrollView setScrollEnabled:YES];
        
        NSMutableArray *groups = [NSMutableArray array];
        for (RCHMarket *market in [[RCHGlobal sharedGlobal] marketsArray]) {
            NSDictionary *theGroup = nil;
            for (NSDictionary *group in groups) {
                if ([[group objectForKey:@"code"] isEqualToString:market.sector.code]) {
                    theGroup = group;
                    break;
                }
            }
            
            if (theGroup == nil) {
                [groups addObject:[NSDictionary dictionaryWithObjectsAndKeys:market.sector.code, @"code", @[market], @"markets", nil]];
            } else {
                [groups replaceObjectAtIndex:[groups indexOfObject:theGroup]
                                  withObject:[NSDictionary dictionaryWithObjectsAndKeys:market.sector.code, @"code", [[theGroup objectForKey:@"markets"] arrayByAddingObject:market], @"markets", nil]];;
            }
        }
        
        _marketGroups = (NSArray *)groups;
        
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * [_marketGroups count], _scrollView.frame.size.height)];
        
        NSUInteger currentIndex = [self findDefaultIndex];
        for (NSUInteger i = 0; i < [_marketGroups count]; i++) {
            RCHMarketQuotesViewController *controller = nil;
            if (i < [self.childViewControllers count]) {
                controller = (RCHMarketQuotesViewController *)[self.childViewControllers objectAtIndex:i];
            } else {
                controller = [[RCHMarketQuotesViewController alloc] initWithOnRefresh:^(NSDictionary *theGroup) {
                    self->_currentGroup = theGroup;
                    [self refresh];
                    
                    [self setEnable:NO];
                }];
                [self addChildViewController:controller];
            }
            
            if (controller.isViewLoaded) {
                controller.view.frame = CGRectMake(_scrollView.frame.size.width * i, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            }
            [controller reloadWithMarketGroup:[_marketGroups objectAtIndex:i]];
            
            if (_currentGroup != nil && [[[_marketGroups objectAtIndex:i] objectForKey:@"code"] isEqualToString:[_currentGroup objectForKey:@"code"]]) {
                currentIndex = i;
            }
        }
        
        for (NSUInteger i = [_marketGroups count]; i < [self.childViewControllers count]; i++) {
            UIViewController *controller = [self.childViewControllers objectAtIndex:i];
            if (controller.isViewLoaded) {
                [controller.view removeFromSuperview];
            }
            [controller removeFromParentViewController];
        }
        
        [_pageMenu removeAllItems];
        
        NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[_marketGroups count]];
        for (NSDictionary *group in _marketGroups) {
            [titles addObject:[NSString stringWithFormat:@"  %@  ", [group objectForKey:@"code"]]];
        }
        [_pageMenu setItems:(NSArray *)titles selectedItemIndex:currentIndex];
        
//        UIViewController *currentController = [[self childViewControllers] objectAtIndex:currentIndex];
//
//        if (!currentController.isViewLoaded) {
//            currentController.view.frame = CGRectMake(_scrollView.frame.size.width * currentIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
//            [_scrollView addSubview:currentController.view];
//        }
//
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * currentIndex, 0) animated:NO];
        _currentGroup = nil;
    } else {
        [self resume];
    }
}

- (NSUInteger)findDefaultIndex {
    for (NSUInteger i = 0; i < [_marketGroups count]; i++) {
        if ([[[_marketGroups objectAtIndex:i] objectForKey:@"code"] isEqualToString:[[RCHGlobal sharedGlobal] defaultCurrencyCode]]) {
            return i;
        }
    }
    return 0;
}

#pragma mark - SPPageMenu的代理方法

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    UIViewController *controller = [self.childViewControllers objectAtIndex:toIndex];
    if (!controller.isViewLoaded) {
        controller.view.frame = CGRectMake(_scrollView.frame.size.width * toIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        [_scrollView addSubview:controller.view];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0)
                         animated:YES];
}

@end
