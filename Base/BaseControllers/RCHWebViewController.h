//
//  RCHWebViewController.h
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHBaseViewController.h"
#import <WebKit/WebKit.h>
#import "RCHNormalRefreshHeader.h"
#import "RCHWebViewJSBridge.h"

@class RCHWebViewController;
@protocol RCHWebViewControllerDelegate <NSObject>

@optional
// 左上边的返回按钮点击
- (void)backBtnClick:(UIButton *)backBtn webView:(WKWebView *)webView ;

//左上边的关闭按钮的点击
- (void)closeBtnClick:(UIButton *)closeBtn webView:(WKWebView *)webView;

// 监听 self.webView.scrollView 的 contentSize 属性改变，从而对底部添加的自定义 View 进行位置调整
- (void)webView:(WKWebView *)webView scrollView:(UIScrollView *)scrollView contentSize:(CGSize)contentSize;

@end


@protocol RCHWebViewControllerDataSource <NSObject>

@optional
// 默认需要, 是否需要进度条
- (BOOL)webViewController:(RCHWebViewController *)webViewController webViewIsNeedProgressIndicator:(WKWebView *)webView;

// 默认需要自动改变标题
- (BOOL)webViewController:(RCHWebViewController *)webViewController webViewIsNeedAutoTitle:(WKWebView *)webView;

@end

@interface RCHWebViewController : RCHBaseViewController<WKNavigationDelegate, WKUIDelegate, RCHWebViewControllerDelegate, RCHWebViewControllerDataSource>

/** webView */
@property (nonatomic, strong) IBOutlet WKWebView *webView;

/** <#digest#> */
@property (nonatomic, copy) NSString *gotoURL;

/** <#digest#> */
@property (nonatomic, copy) NSString *contentHTML;

/** <#digest#> */
@property (weak, nonatomic) UIProgressView *progressView;

/** <#digest#> */
@property (nonatomic, strong) RCHWebViewJSBridge *bridge;


// 页面加载完调用, 必须调用super
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;


// 页面加载失败时调用, 必须调用super
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error NS_REQUIRES_SUPER;

@end
