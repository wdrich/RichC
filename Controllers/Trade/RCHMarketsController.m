//
//  RCHMarketsController.m
//  richcore
//
//  Created by WangDong on 2018/5/22.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMarketsController.h"
#import "RCHMarketsCell.h"

#define defaultCellHeight 70.0f

@interface RCHMarketsController () {
    NSArray *_marketGroups;
}

@end

@implementation RCHMarketsController

- (id)init {
    self = [super init];
    if (self) {
        _marketGroups = @[];
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
    
    [self loadMarkets];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark - ButtonClicked
- (void)gobackButtonClicked
{
    RCHWeak(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DismissModalViewControllerAnimated(weakself, YES);
    });
}

#pragma mark -
#pragma mark Implements UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[RCHGlobal sharedGlobal] setCurrentMarket:[[[_marketGroups objectAtIndex:indexPath.section] objectForKey:@"markets"] objectAtIndex:indexPath.row]];
    
    [self gobackButtonClicked];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat originX = 15.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:section]];
    view.backgroundColor = kLightGreenColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = [[_marketGroups objectAtIndex:section] objectForKey:@"code"];
    titleLabel.textColor = kNavigationColor_MB;
    [view addSubview:titleLabel];
    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForFooterInSection:section]];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark -
#pragma mark Implements UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_marketGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_marketGroups objectAtIndex:section] objectForKey:@"markets"] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return defaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"marketCellIdentifier";
    RCHMarketsCell *cell = (RCHMarketsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[RCHMarketsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell setMarket:[[[_marketGroups objectAtIndex:indexPath.section] objectForKey:@"markets"] objectAtIndex:indexPath.row]];
    
    return cell;
    
}

#pragma mark -
#pragma mark -  NavigationDataSource

- (UIImage *)RCHNavigationBarLeftButtonImage:(UIButton *)leftButton navigationBar:(RCHNavigationBar *)navigationBar
{
    [self customButtonInfo:leftButton title:NSLocalizedString(@"取消",nil)];
    return nil;
}

#pragma mark -
#pragma mark -  NavigationDelegate

-(void)leftButtonEvent:(UIButton *)sender navigationBar:(RCHNavigationBar *)navigationBar {
    [self gobackButtonClicked];
}


#pragma mark -
#pragma mark - getter

- (void)loadMarkets {
    if (![[RCHGlobal sharedGlobal] marketsArray] || [[[RCHGlobal sharedGlobal] marketsArray] count] == 0) return;
    
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
}


@end
