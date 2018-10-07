    //
//  RCHMarketQuotesViewController.m
//  richcore
//
//  Created by Apple on 2018/6/13.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHMarketQuotesViewController.h"
#import "RCHTradeDetailController.h"
#import "RCHQuoteListCell.h"

#define defaultCellHeight 76.0f

@interface RCHMarketQuotesViewController ()
{
    void (^_onRefresh)(NSDictionary *);
    NSDictionary *_marketGroup;
    NSArray *_markets;
}
@end

@implementation RCHMarketQuotesViewController

- (instancetype)initWithOnRefresh:( void (^ _Nonnull )(NSDictionary *))onRefresh {
    self = [super init];
    if (self) {
        _onRefresh = [onRefresh copy];
        _marketGroup = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _marketGroup ? [_marketGroup objectForKey:@"code"] : nil;
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    self.tableView.mj_footer = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = kFontLineGrayColor;
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)reloadWithMarketGroup:( NSDictionary * _Nonnull )marketGroup
{
    _marketGroup = marketGroup;
    _markets = [self sort:[RCHGlobal sharedGlobal].marketSortType trend:[RCHGlobal sharedGlobal].marketTrendType markets:[_marketGroup objectForKey:@"markets"]];
    if (self.isViewLoaded) {
        self.title = [_marketGroup objectForKey:@"code"];
        [self endHeaderFooterRefreshing];
        [self.tableView reloadData];
    }
}

- (NSArray *)sort:(RCHSortType)sort trend:(RCHSortTrendType)trend markets:(NSArray *)markets
{
    if (RCHIsEmpty(markets)) {
        return @[];
    }
    NSString *key;
    switch ([RCHGlobal sharedGlobal].marketSortType) {
        case RCHSortTypeName:
            key = @"coin.code";
            break;
        case RCHSortTypeVolume:
            key = @"state.quote_volume";
            break;
        case RCHSortTypePrice:
            key = @"state.last_price";
            break;
        case RCHSortTypeChange:
            key = @"state.price_change_percent";
            break;
        default:
            return markets;
            break;
    }
    
    NSSortDescriptor * descript = [NSSortDescriptor sortDescriptorWithKey:key ascending:[RCHGlobal sharedGlobal].marketTrendType == RCHSortTrendTypeIncrease ? YES : NO];
    NSArray * descripts = @[descript];
    return [markets sortedArrayUsingDescriptors:descripts];
}

- (void)loadMore:(BOOL)isMore
{
    _onRefresh(_marketGroup);
}

#pragma mark -
#pragma mark Implements UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[RCHGlobal sharedGlobal] setCurrentMarket:[_markets objectAtIndex:indexPath.row]];
    
    RCHTradeDetailController *viewcontroller = [[RCHTradeDetailController alloc] init];
    viewcontroller.canChangeMarket = YES;
    [self.navigationController pushViewController:viewcontroller animated:YES];

}

#pragma mark -
#pragma mark Implements UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_marketGroup == nil) return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_markets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return defaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stateCellIdentifier";
    RCHQuoteListCell *cell = (RCHQuoteListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[RCHQuoteListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.market = [_markets objectAtIndex:indexPath.row];
    
    return cell;
}

@end
