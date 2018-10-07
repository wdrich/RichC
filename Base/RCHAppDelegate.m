//
//  AppDelegate.m
//  richcore
//
//  Created by WangDong on 2018/5/8.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHAppDelegate.h"
#import "RCHTabbarViewController.h"
#import "RCHMainViewController.h"
#import "RCHMyViewController.h"
#import "RCHQuotesController.h"
#import "RCHTradeController.h"
#import "RCHTradesViewController.h"

@interface RCHAppDelegate ()

@end

@implementation RCHAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //使用体验统计
    [Appsee start:k_APPSEE_KEY];
    if ([RCHHelper valueForKey:kCurrentUserEmail]) {
        [Appsee setUserID:[RCHHelper valueForKey:kCurrentUserEmail]];
    }
    
    [RCHHelper setValue:[NSNumber numberWithInt:0] forKey:kCurrentTradeType];//设置默认交易类型为买入
    
    [CSToastManager setQueueEnabled:YES];//toast 顺序显示
    [self registerDefaults];
    [self dumpData];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [self createTabbarViewController:YES];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStopWebsocketeNotification object:nil];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartWebsocketeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAutoUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetMemverNotification object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (LCTabBarController *)createTabbarViewController:(BOOL)isPrime
{
    RCHMainViewController *firstController = [[RCHMainViewController alloc] initWithHome:YES];
    firstController.gotoURL = k_MAIN_URL;
    firstController.title = @"首页";
    firstController.tabBarItem.image = [UIImage imageNamed:@"bottom_main"];
    firstController.tabBarItem.selectedImage = [UIImage imageNamed:@"bottom_main_press"];
    
    RCHQuotesController *secondController = [[RCHQuotesController alloc] init];
    secondController.title = @"行情";
    secondController.tabBarItem.image = [UIImage imageNamed:@"bottom_quotes"];
    secondController.tabBarItem.selectedImage = [UIImage imageNamed:@"bottom_quotes_press"];
    
    RCHTradesViewController *fourthController = [[RCHTradesViewController alloc] init];
    fourthController.title = @"交易";
    fourthController.tabBarItem.image = [UIImage imageNamed:@"bottom_mining"];
    fourthController.tabBarItem.selectedImage = [UIImage imageNamed:@"bottom_mining_press"];
    
    RCHMyViewController *fifthController = [[RCHMyViewController alloc] init];
    fifthController.title = @"我的";
    fifthController.tabBarItem.image = [UIImage imageNamed:@"bottom_me"];
    fifthController.tabBarItem.selectedImage = [UIImage imageNamed:@"bottom_me_press"];
    
    RCHNavigationController *firstNavigationControllor  = [[RCHNavigationController alloc] initWithRootViewController:firstController];
    RCHNavigationController *secondNavigationControllor  = [[RCHNavigationController alloc] initWithRootViewController:secondController];
    RCHNavigationController *fourthNavigationControllor  = [[RCHNavigationController alloc] initWithRootViewController:fourthController];
    RCHNavigationController *fifthNavigationControllor  = [[RCHNavigationController alloc] initWithRootViewController:fifthController];

    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    
    [[UITabBar appearance] setBackgroundColor:kBottomGrayColor];
    
    RCHTabbarViewController *tabBarController    = [[RCHTabbarViewController alloc] init];
    
//    tabBarController.itemTitleFont          = [UIFont fontWithName:@"PingFangSC-Regular" size:10.0f];
    tabBarController.itemTitleColor         = kTextUnselectColor;
    tabBarController.selectedItemTitleColor = kAppOrangeColor;
    //    tabBarController.badgeTitleFont         = [UIFont boldSystemFontOfSize:12.0f];
    
    if (isPrime) {
        tabBarController.viewControllers        = @[firstNavigationControllor, secondNavigationControllor, fourthNavigationControllor, fifthNavigationControllor];
    } else {
        tabBarController.viewControllers        = @[firstNavigationControllor, secondNavigationControllor, fifthNavigationControllor];
    }
    
    
    [[UITabBar appearance] setShadowImage:RCHIMAGEWITHNAMED(@"shadow_bottombar")];
    [tabBarController setSelectedIndex:defaultConttollerIndex];
    
    
    return tabBarController;
}

- (void)dumpData
{
    NSDecimalNumber *soft_version = [NSDecimalNumber decimalNumberWithString:SOFTWARE_VERSION];
    NSDecimalNumber *current_version = [NSDecimalNumber decimalNumberWithString:[RCHHelper valueForKey:kNextVersion]];
    if ([current_version compare:soft_version] == NSOrderedAscending) {
        NSDecimalNumber *des_version = [NSDecimalNumber decimalNumberWithString:@"0.5999"];
        if ([current_version compare:des_version] == NSOrderedAscending) {
            [RCHHelper setValue:[NSNumber numberWithBool:YES] forKey:kShowBalance];
            [RCHHelper setValue:[NSNumber numberWithBool:YES] forKey:kIsFirstTimeUse];
            [RCHHelper setValue:[NSNumber numberWithInteger:0] forKey:kNextVersion];
            [RCHHelper setValue:SOFTWARE_VERSION forKey:kNextVersion];
        }
    }
    [RCHHelper setValue:SOFTWARE_VERSION forKey:kCurrentVersion];
}

- (BOOL)isPrime
{
    NSArray *roles = [RCHHelper valueForKey:kCurrentUserRoles];
    if ([roles containsObject:@"ROLE_PRIME"] || [roles containsObject:@"ROLE_TESTER"]) {
        return YES;
    }
    return NO;
}

- (void)registerDefaults
{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:kShowBalance];
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:kIsFirstTimeUse];
    [defaultValues setObject:SOFTWARE_VERSION forKey:kCurrentVersion];
    [defaultValues setObject:SOFTWARE_VERSION forKey:kNextVersion];
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:kCanShowCreateOrderNotice];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

@end
