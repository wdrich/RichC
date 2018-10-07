//
//  RCHInvitesController.m
//  richcore
//
//  Created by WangDong on 2018/6/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "RCHInvitesController.h"
#import "RCHInviteRecordCell.h"
#import "RCHInviteRequest.h"

#define defaultCellHeight 63.0f
#define titleHeight 40.0f

@interface RCHInvitesController ()

@property (nonatomic, assign) NSInteger  pageSize;
@property (nonatomic, assign) NSInteger  page;
@property (nonatomic, strong) NSMutableArray *invites;
@property (nonatomic, strong) RCHInviteRequest *inviteRequest;

@end

@implementation RCHInvitesController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"奖励记录",nil);
    self.view.backgroundColor = kTabbleViewBackgroudColor;
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.top += titleHeight;
    self.tableView.contentInset = edgeInsets;
    
    UIView *headView = [self createTItleView];
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kAppOriginY);
        make.left.right.mas_equalTo(0.0f);
        make.height.mas_equalTo(titleHeight);
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - CustomFuction

- (void)init_info
{
    self.page = 1;
    self.pageSize = 20;
}

- (void)loadMore:(BOOL)isMore
{
    if (!isMore) {
        [self init_info];
    }
    [self getInvites];
}

- (UIView *)createTItleView
{
    CGFloat originX = 15.0f;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kLightGreenColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"类型/时间";
    titleLabel.textColor = kTextUnselectColor;
    [view addSubview:titleLabel];
    [titleLabel sizeToFit];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(originX);
        make.centerY.mas_equalTo(view.mas_centerY);
        make.size.mas_equalTo(titleLabel.size);
    }];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.userInteractionEnabled = YES;
    countLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.text = @"奖励";
    countLabel.textColor = kTextUnselectColor;
    [view addSubview:countLabel];
    [countLabel sizeToFit];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-originX);
        make.centerY.mas_equalTo(view.mas_centerY);
        make.size.mas_equalTo(countLabel.size);
    }];
    
    return view;
}

- (void)tableviewReload
{
    RCHWeak(self);
    [self.tableView configBlankPage:RCHBlankPageViewTypeNoDataOnlyMessage hasData:[self.invites count] emptyMessage:@"暂无返利记录" reloadButtonBlock:^(UIButton *sender) {
        [weakself.tableView.mj_header beginRefreshing];
        if ([weakself.invites count]) {
            weakself.tableView.scrollEnabled = YES;
            weakself.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        } else {
            weakself.tableView.scrollEnabled = NO;
            weakself.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Request

- (void)getInvites
{
    self.tableView.tableFooterView = nil;
    RCHWeak(self);
    if (weakself.inviteRequest.currentTask) {
        [weakself.inviteRequest.currentTask cancel];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSNumber numberWithInteger:1] forKey:@"page_info"];
    [dictionary setObject:[NSNumber numberWithInteger:self.pageSize] forKey:@"size"];
    [dictionary setObject:[NSNumber numberWithInteger:self.page] forKey:@"page"];
    
    [weakself.inviteRequest invites:^(NSObject *response) {
        [weakself endHeaderFooterRefreshing];
        if ([response isKindOfClass:[RCHInviteList class]]) {
            RCHInviteList *inviteList = (RCHInviteList *)response;
            if (weakself.page == 1) {
                [weakself.invites removeAllObjects];
            }
            weakself.page += 1;
            [weakself.invites addObjectsFromArray:inviteList.data];
            if (inviteList.page < inviteList.total) {
                self.tableView.mj_footer.hidden = NO;
            } else {
                self.tableView.mj_footer.hidden = YES;
            }
            
            [weakself tableviewReload];
        } else if ([response isKindOfClass:[WDBaseResponse class]]){
            NSInteger code = ((WDBaseResponse *)response).statusCode;
            NSString *url = ((WDBaseResponse *)response).urlString;
            [RCHHelper showRequestErrorCode:code url:url];
        } else {
            [MBProgressHUD showError:kDataError ToView:self.view];
        }
    } info:dictionary];
    
}

#pragma mark -
#pragma mark Implements UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0.1f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    CGFloat originX = 15.0f;
//
//    UIView *view = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:section]];
//    view.backgroundColor = kLightGreenColor;
//
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.userInteractionEnabled = YES;
//    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
//    titleLabel.textAlignment = NSTextAlignmentLeft;
//    titleLabel.text = @"类型/时间";
//    titleLabel.textColor = kTextUnselectColor;
//    [view addSubview:titleLabel];
//    [titleLabel sizeToFit];
//
//    UILabel *countLabel = [[UILabel alloc] initWithFrame:(CGRect){{originX, (view.height - 22.0f) / 2.0f}, {220.0f, 22.0f}}];
//    countLabel.backgroundColor = [UIColor clearColor];
//    countLabel.userInteractionEnabled = YES;
//    countLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0f];
//    countLabel.textAlignment = NSTextAlignmentLeft;
//    countLabel.text = @"奖励";
//    countLabel.textColor = kTextUnselectColor;
//    [view addSubview:countLabel];
//    [countLabel sizeToFit];
//
//    titleLabel.frame = (CGRect){{titleLabel.left, (view.height - titleLabel.height) / 2.0f}, titleLabel.frame.size};
//    countLabel.frame = (CGRect){{(view.width - originX - countLabel.width), (view.height - countLabel.height) / 2.0f}, countLabel.frame.size};
//
//    return view;
//}


#pragma mark -
#pragma mark Implements UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.invites  && [self.invites count] > 0) {
        return [self.invites count];
    }
    else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  defaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCHInvite *invite = nil;
    
    if ([_invites count] > indexPath.row) {
        invite = [_invites objectAtIndex:indexPath.row];
    }
    
    if (invite) {
        static NSString *CellIdentifier = @"marketCellIdentifier";
        RCHInviteRecordCell *cell = (RCHInviteRecordCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            cell = [[RCHInviteRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.backgroundColor = indexPath.row % 2 ? [kLightGreenColor colorWithAlphaComponent:0.5] : [UIColor whiteColor];
        
        if (invite) {
            [cell setInvite:invite];
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"CellIdentifier";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        return cell;
    }
    
}

#pragma mark -
#pragma mark - getter

- (NSArray *)invites
{
    if(_invites == nil)
    {
        _invites = [NSMutableArray array];
    }
    return _invites;
}

- (RCHInviteRequest *)inviteRequest
{
    if(_inviteRequest == nil)
    {
        _inviteRequest = [[RCHInviteRequest alloc] init];
    }
    return _inviteRequest;
}

@end
