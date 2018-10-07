//
//  RCHMainWebviewController.m
//  MeiBe
//
//  Created by WangDong on 2018/4/22.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMainWebviewController.h"
#import "SVPullToRefresh.h"
#import "MBProgressHUD.h"

#define htmlName  [NSString stringWithFormat:@"%@/html.dat",[MJLHelper getRootPath]]
#define htmlPath  PATH_AT_CACHEDIR(htmlName)

@interface RCHMainWebviewController ()
{
    BOOL _isGoToPreview;
    BOOL _isPush;
    
    NSString *_url;
    MBProgressHUD *_hub;
}
@end

@implementation RCHMainWebviewController

- (id)initWithMainUrl:(NSString *)url
{
    if(self = [super init]) {
        self.urlString = url;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [MJLHelper showOrHideTabbar:self.navigationController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"首页",nil);
    self.view.backgroundColor = kBackgroundColor;
    
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:nil];
    
    _webView.frame = CGRectMake(0.0f, kAppOriginY, self.view.width, self.view.height - kTabBarHeight);
    
    __weak typeof (self) weakSelf = self;
    [_webView.scrollView addPullToRefreshWithActionHandler:^{
        [weakSelf performSelector:@selector(refresh:) withObject:weakSelf afterDelay:.2f];
    }];
    
    CGRect frame = (CGRect){{0.0f, 0.0f}, {kMainScreenWidth, 64.0f}};
    
    [_webView.scrollView.pullToRefreshView setCustomView:[self createPullToRefreshView:frame active:NO] forState:SVPullToRefreshStateAll];
    [_webView.scrollView.pullToRefreshView setCustomView:[self createPullToRefreshView:frame active:YES] forState:SVPullToRefreshStateLoading];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!_isGoToPreview) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
//    if (self.hidesBottomBarWhenPushed) {
//        [MJLHelper showOrHideTabbar:self.navigationController];
//    }

    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    count = 0;
}


#pragma mark -
#pragma mark - CustomFuction

- (UIView *)createPullToRefreshView:(CGRect)frame active:(BOOL)active
{
    UIView *refreshView = [[UIView alloc] initWithFrame:frame];
    refreshView.backgroundColor = [UIColor clearColor];
    
    UILabel *headLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 15.0f}, {refreshView.width, 16.0f}}];
    headLabel.text = NSLocalizedString(@"   正在刷新", nil);
    headLabel.font = [UIFont systemFontOfSize:14.0f];
    headLabel.backgroundColor = [UIColor clearColor];
    headLabel.textAlignment = NSTextAlignmentCenter;
    headLabel.textColor = kFontGrayColor;
    [refreshView addSubview:headLabel];
    
    if (active) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = (CGPoint){refreshView.center.x, headLabel.bottom + 15.0f};
        indicatorView.hidesWhenStopped = YES;
        [indicatorView startAnimating];
        [refreshView addSubview:indicatorView];
    }
    
    return refreshView;
    
}

- (void)refresh:(id)blockSelf
{
    [blockSelf refresh];
    //    _headLabel.hidden = YES;
    
}


- (void)refreshInBackgropund
{
    [self refresh];
}

- (void)scrollToRefresh
{
    [self refresh];
}


#pragma mark -
#pragma mark - over write

- (void)webviewStart
{
    [super webviewStart];
    [_activityView stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@",[request.URL description]);
    NSLog(@"%@",self.urlString);
    if ([[request.URL description] isEqualToString:self.urlString]) {
        [self.navigationItem setLeftBarButtonItem:nil];
        return YES;
    } else if([[request.URL description] containsString:@"tel:"]){
        return YES;
    } else if([[request.URL description] containsString:@"/#"]){
        return NO;
    } else {
        RCHWebViewController *webviewController = [[RCHWebViewController alloc] init];
        webviewController.urlString = [request.URL description];
        webviewController.superController = self;
        [self.navigationController pushViewController:webviewController animated:YES];
        return NO;
    }
    
    
}


- (void)webviewFinished
{
    [super webviewFinished];
    [_webView.scrollView.infiniteScrollingView stopAnimating];
    [_webView.scrollView.pullToRefreshView stopAnimating];
    
    count = 0;
    self.navigationItem.title = NSLocalizedString(@"首页",nil);
    NSLog(@"%@",[_webView.request.URL absoluteString]);
//    NSLog(@"%@", htmlPath);
//    NSString *js = @"document.documentElement.innerHTML";
//    NSString *html = [_webView stringByEvaluatingJavaScriptFromString:js];
//    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
//    BOOL success = [htmlData writeToFile:htmlPath atomically:NO];
//    if (success) {
//        NSLog(@"sucssess!");
//    } else {
//        NSLog(@"error!");
//    }
}

static int count = 0;

- (void)webviewDidFailLoad
{
    [super webviewDidFailLoad];
    [_webView.scrollView.infiniteScrollingView stopAnimating];
    [_webView.scrollView.pullToRefreshView stopAnimating];
    if (count < 3) {
        count ++;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f]];
    }
}

@end
