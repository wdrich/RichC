//
//  RCHTabbViewController.m
//  richcore
//
//  Created by WangDong on 2018/5/15.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHTabbarViewController.h"
#import "RCHLoginViewController.h"
#import "RCHStateSocketRequest.h"
#import "RCHKlineSocketRequest.h"
#import "RCHLogoutRequest.h"
#import "RCHMarketsRequest.h"
#import "RCHMemberRequest.h"
#import "RCHRatesRequest.h"
#import "RCHSoftwareUpdateRequest.h"
#import "RCHState.h"

@interface RCHTabbarViewController () <RCHStateSocketRequestDelegate, RCHKlineSocketRequestDelegate>
{
    RCHStateSocketRequest *_stateSocketRequest;
    dispatch_source_t _timer;
    RCHKlineSocketRequest *_klineSocketRequest;
}
@property (nonatomic, strong) RCHMarketsRequest *marketsRequest;
@property (nonatomic, strong) RCHSoftwareUpdateRequest *updateRequest;
@property (nonatomic, strong) RCHMemberRequest *memberRequest;
@property (nonatomic, strong) RCHLogoutRequest *logoutRequest;
@property (nonatomic, strong) RCHRatesRequest *ratesRequest;
@property (nonatomic, strong) RCHVersion *version;
@property (nonatomic, assign) BOOL isManualUpdate;


@end

@implementation RCHTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessToLoginController:) name:kGotoLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessfull:) name:kLoginDidSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccessfull:) name:kLogoutDidSuccessNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginMarkets:) name:kGetMarketsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishMarkets:) name:kStopMarketsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginStates:) name:kStartWebsocketeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finisStates:) name:kStopWebsocketeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectStates:) name:kReconnectWebsocketeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginKline:) name:kStartKlineWebsocketeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishKline:) name:kStopKlineWebsocketeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeResolution:) name:kChangeResolutionChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMemberInfo) name:kGetMemverNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentMarketChanged:)
                                                 name:kCurrentMarketChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCheckUpdate:) name:kAutoUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manualCheckUpdate:) name:kManualUpdateNotification object:nil];
    
    [self getMemberInfo];
    [self initTimer];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[WDRequestManager sharedManager].operationQueue cancelAllOperations];
    dispatch_source_cancel(_timer);
}

#pragma mark -
#pragma mark - CustomFuction

- (void)showUpdateAlert
{
    NSDecimalNumber *current_version = [NSDecimalNumber decimalNumberWithString:[RCHHelper valueForKey:kCurrentVersion]];
    NSDecimalNumber *new_version = [NSDecimalNumber decimalNumberWithString:self.version.version];
    NSDecimalNumber *next_version = [NSDecimalNumber decimalNumberWithString:[RCHHelper valueForKey:kNextVersion]];
    
    if (self.version.isMustUpdate && ([current_version compare:new_version] == NSOrderedAscending)) {
        [self forcedAlert];
        return;
    }

    if ((([current_version compare:new_version] == NSOrderedAscending) && ([next_version compare:new_version] == NSOrderedAscending)) || self.isManualUpdate) {
        [RCHHelper setValue:self.version.version forKey:kNextVersion];
        self.isManualUpdate = NO;
          [self normalAlert];
    }
}

- (void)normalAlert
{
    [UIAlertController wd_showAlertWithTitle:NSLocalizedString(@"有新的版本了",nil)
                                     message:self.version.updateInfo
                           appearanceProcess:^(WDAlertController * _Nonnull alertMaker) {
                               alertMaker.
                               addActionCancelTitle(NSLocalizedString(@"以后再说",nil)).
                               addActionDestructiveTitle(NSLocalizedString(@"立即更新",nil));
                           }
                                actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nonnull action, WDAlertController * _Nonnull alertSelf) {
                                    if (buttonIndex == 1) {
                                        NSString *url = [self getUpdateUrl:self.version.downloadUrl];
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                                    }
                                }];
}

- (void)forcedAlert
{
    [UIAlertController wd_showAlertWithTitle:NSLocalizedString(@"有新的版本了",nil)
                                     message:self.version.updateInfo
                           appearanceProcess:^(WDAlertController * _Nonnull alertMaker) {
                               alertMaker.
                               addActionCancelTitle(NSLocalizedString(@"退出",nil)).
                               addActionDestructiveTitle(NSLocalizedString(@"立即更新",nil));
                           }
                                actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nonnull action, WDAlertController * _Nonnull alertSelf) {
                                    if (buttonIndex == 0) {
                                        exit(1);
                                    }
                                    else if (buttonIndex == 1) {
                                        NSString *url = [self getUpdateUrl:self.version.downloadUrl];
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                                    }
                                    NSLog(@"%@--%@", action.title, action);
                                }];
}

- (NSString *)getUpdateUrl:(NSString *)updateUrl
{
    NSString *url;
    if ([updateUrl containsString:@".plist"]) {
        url = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",updateUrl];
    } else {
        url = updateUrl;
    }
    return url;
}

- (void)initTimer {
    RCHWeak(self);
    dispatch_queue_t queue = dispatch_get_main_queue();
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)); //比当前时间晚2s开始执行
    uint64_t interval = (uint64_t)(5.0 * NSEC_PER_SEC); //间隔时间5s
    dispatch_source_set_timer(_timer, start, interval, 0);
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself getRatesRequest];
        });
    });
    dispatch_resume(_timer);
}

#pragma mark -
#pragma mark - Request

- (void)stateSocketRequest
{
    [self cancelStateSocketRequest];
    
    if ([[RCHGlobal sharedGlobal] currentMarket] == nil) return;
    
    _stateSocketRequest = [[RCHStateSocketRequest alloc] initWithSymbol:[[[RCHGlobal sharedGlobal] currentMarket] symbol]];
    _stateSocketRequest.delegate = self;
}

- (void)klineSocketRequest:(NSString *)resolution
{
    [self cancelKlineSocketRequest];
    
    if ([[RCHGlobal sharedGlobal] currentMarket] == nil) return;
    
    NSString *symbol = [[[RCHGlobal sharedGlobal] currentMarket] symbol];
    _klineSocketRequest = [[RCHKlineSocketRequest alloc] initWithSymbol:symbol.lowercaseString filter:resolution ?: @"15m"];
    _klineSocketRequest.delegate = self;
}

- (void)checkUpdate
{
    RCHWeak(self);
    [self stopCheckUpdate];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSString *identifier = SOFTWARE_IDENTIFIER;
    NSString *platform = @"1";
    [info setObject:identifier forKey:@"identifier"];
    [info setObject:platform forKey:@"platform"];
    
    [self.updateRequest checkUpdate:^(NSObject *response) {
        if ([response isKindOfClass:[RCHVersion class]]) {
            weakself.version = (RCHVersion *)response;
            [weakself showUpdateAlert];
        } else {
            self.isManualUpdate = NO;
        }
        
    } info:info];
}

- (void)getMarketsRequest
{
    [self stopMarkets];
    [self.marketsRequest markets:^(NSObject *response) {
        if ([response isKindOfClass:[NSArray class]]) {
            [[RCHGlobal sharedGlobal] setMarketsArray:(NSArray *)response];
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetMarketsSuccessNotification object:nil];
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
//            NSInteger code = ((WDBaseResponse *)response).statusCode;
//            NSString *url = ((WDBaseResponse *)response).urlString;
//            [RCHHelper showRequestErrorCode:code url:url];
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetMarketsFailedNotification object:nil];
        } else {
//            [MBProgressHUD showError:kDataError ToView:self.view];
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetMarketsFailedNotification object:nil];
        }
    }];
}

- (void)getMemberInfo
{
    RCHWeak(self);
    if (weakself.memberRequest.currentTask) {
        [weakself.memberRequest.currentTask cancel];
    }
    
    [weakself.memberRequest member:^(NSObject *response) {
        if ([response isKindOfClass:[RCHMember class]]) {
            RCHMember *member = (RCHMember *)response;
            [RCHHelper saveUserInfo:member];
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            if (code == 403) {
                if ([[RCHHelper valueForKey:kCurrentUserId] integerValue] > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutDidSuccessNotification object:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kGotoLoginNotification object:nil];
                    });
                    return;
                }
            }
        }
    }];
}


- (void)sendLogoutRequest
{
    [self stopLogout];
    [self.logoutRequest logout:^(NSError *error, WDBaseResponse *response) {
        
    }];
}

- (void)getRatesRequest
{
    [self stopGetRate];
    [self.ratesRequest rates:^(NSObject *response) {
        if ([response isKindOfClass:[NSArray class]]) {
            NSData *json_data = [NSJSONSerialization dataWithJSONObject:(NSArray *)response options:NSJSONWritingPrettyPrinted error:nil];
            BOOL success = [json_data writeToFile:kRageFilePath atomically:YES];
            if (success) {
                NSLog(@"success");
            }
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            [RCHHelper setValue:@(false)forKey:kCurrentRateFailed];
        }
    }];
}

- (void)cancelStateSocketRequest
{
    if(_stateSocketRequest) {
        _stateSocketRequest.delegate = nil;
        [_stateSocketRequest close];
    }
}

- (void)cancelKlineSocketRequest
{
    if(_klineSocketRequest) {
        _klineSocketRequest.delegate = nil;
        [_klineSocketRequest close];
    }
}

- (void)stopMarkets
{
    if (self.marketsRequest.currentTask) {
        [self.marketsRequest.currentTask cancel];
    }
}

- (void)stopCheckUpdate
{
    if (self.updateRequest.currentTask) {
        [self.updateRequest.currentTask cancel];
    }
}

- (void)stopGetMember
{
    if (self.memberRequest.currentTask) {
        [self.memberRequest.currentTask cancel];
    }
}

- (void)stopLogout
{
    if (self.logoutRequest.currentTask) {
        [self.logoutRequest.currentTask cancel];
    }
}


- (void)stopGetRate
{
    if (self.ratesRequest.currentTask) {
        [self.ratesRequest.currentTask cancel];
    }
}


#pragma mark -
#pragma mark - Notifications

- (void)accessToLoginController:(NSNotification *)notification
{
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RCHLoginViewController *loginController = [[RCHLoginViewController alloc]init];
        RCHNavigationController *loginNavController = [[RCHNavigationController alloc] initWithRootViewController:loginController];
        loginNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        PresentModalViewControllerAnimated(weakself, loginNavController, YES);
    });
}

- (void)loginSuccessfull:(NSNotification *)notification
{
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DismissModalViewControllerAnimated(weakself, YES);
    });
//    [self setSelectedIndex:defultConttollerIndex];
    
    [self reconnectSocket];
}

- (void)logoutSuccessfull:(NSNotification *)notification
{
    [self sendLogoutRequest];
    
    [RCHHelper emptyUserInfo];
//    [self setSelectedIndex:defultConttollerIndex];
    
    [self reconnectSocket];
}

- (void)beginStates:(NSNotification *)notification
{
    [self stateSocketRequest];
}

- (void)finisStates:(NSNotification *)notification
{
    [self cancelStateSocketRequest];
}

- (void)reconnectStates:(NSNotification *)notification
{
    [self reconnectSocket];
}

- (void)beginKline:(NSNotification *)notification
{
    [self klineSocketRequest:[[RCHGlobal sharedGlobal] resolution]];
}

- (void)finishKline:(NSNotification *)notification
{
    [self cancelKlineSocketRequest];
}

- (void)beginMarkets:(NSNotification *)notification
{
    [self getMarketsRequest];
}

- (void)changeResolution:(NSNotification *)notification
{
    [self reconnectKlineSocket];
}

- (void)finishMarkets:(NSNotification *)notification
{
    [self stopMarkets];
}

- (void)currentMarketChanged:(NSNotification *)notification
{
    [self reconnectSocket];
    [self reconnectKlineSocket];
}

- (void)reconnectSocket
{
    [self cancelStateSocketRequest];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stateSocketRequest];
    });
}

- (void)reconnectKlineSocket
{
    [self cancelKlineSocketRequest];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self klineSocketRequest:[[RCHGlobal sharedGlobal] resolution]];
    });
}

- (void)manualCheckUpdate:(NSNotification *)notification
{
    self.isManualUpdate = YES;
    [self checkUpdate];
}

- (void)autoCheckUpdate:(NSNotification *)notification
{
    [self checkUpdate];
}


#pragma mark -
#pragma mark - RCHStateSocketRequestDelegate

- (void)keepAliveSocket:(SRWebSocket *)webSocket didReceiveNotifications:(id)result event:(NSString *)event
{
    if ([event isEqualToString:@"TICKER"] && [result isKindOfClass:[RCHState class]]) {
        RCHState *s = (RCHState *)result;
        RCHMarket *market = [[RCHGlobal sharedGlobal] findBySymbol:s.symbol];
        if (market) {
            market.state = s;
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kReceiveMessageNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:result, @"data", event, @"event", nil]];
    }
}

- (void)keepAliveSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self cancelStateSocketRequest];
}

#pragma mark -
#pragma mark - RCHKlineSocketRequestDelegate

- (void)klineSocket:(SRWebSocket *)webSocket didReceiveNotifications:(id)result
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceiveKlineMessageNotification
                                                        object:nil
                                                      userInfo:result];
}

- (void)klineSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self cancelKlineSocketRequest];
}


#pragma mark -
#pragma mark - getter

- (RCHMarketsRequest *)marketsRequest
{
    if(_marketsRequest == nil)
    {
        _marketsRequest = [[RCHMarketsRequest alloc] init];
    }
    return _marketsRequest;
}

- (RCHSoftwareUpdateRequest *)updateRequest
{
    if(_updateRequest == nil)
    {
        _updateRequest = [[RCHSoftwareUpdateRequest alloc] init];
    }
    return _updateRequest;
}

- (RCHMemberRequest *)memberRequest
{
    if(_memberRequest == nil)
    {
        _memberRequest = [[RCHMemberRequest alloc] init];
    }
    return _memberRequest;
}

- (RCHLogoutRequest *)logoutRequest
{
    if(_logoutRequest == nil)
    {
        _logoutRequest = [[RCHLogoutRequest alloc] init];
    }
    return _logoutRequest;
}

- (RCHLogoutRequest *)ratesRequest
{
    if(_ratesRequest == nil)
    {
        _ratesRequest = [[RCHRatesRequest alloc] init];
    }
    return _ratesRequest;
}

@end
