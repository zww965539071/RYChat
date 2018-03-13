//
//  RCDPrivateSettingsTableViewController.m
//  RongYun
//
//  Created by zww on 2017/8/3.
//  Copyright © 2017年 zww. All rights reserved.
//

#import "RCDPrivateSettingsTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDPrivateSettingsUserInfoCell.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "DefaultPortraitView.h"
#import "UIImageView+WebCache.h"
#import "RCDSearchHistoryMessageController.h"
@interface RCDPrivateSettingsTableViewController ()<UIActionSheetDelegate>
@property(strong, nonatomic) RCDUserInfo *userInfo;
@end
@implementation RCDPrivateSettingsTableViewController
static NSString *InfoCellIdentifier = @"RCDPrivateSettingsUserInfoCell";
static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聊天详情";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = HEXCOLOR(0xf0f0f6);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startLoadView];
}
#pragma mark--private func
-(void)startLoadView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self loadUserInfo:self.userId];
}
- (void)loadUserInfo:(NSString *)userId {
    if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        self.userInfo=[[RCDataBaseManager shareInstance]getFriendInfo:userId];
    }
}
-(void)clickIsTopBtn:(UIButton*)btn{
}
-(void)clickNotificationBtn:(UIButton*)btn{
}
#pragma mark--uitableviewdatasource,uitableviewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:
            rows = 1;
            break;
        case 2:
            rows = 3;
            break;
        default:
            break;
    }
    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //RCDBaseSettingTableViewCell
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[RCDBaseSettingTableViewCell alloc]init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0){
        RCDPrivateSettingsUserInfoCell *infoCell;
        NSString*portraitUri;
        if (self.userInfo != nil) {
            portraitUri = self.userInfo.portraitUri;
            if(self.userInfo.displayName.length>0){
                infoCell = [[RCDPrivateSettingsUserInfoCell alloc] initWithIsHaveDisplayName:YES];
                infoCell.NickNameLabel.text = self.userInfo.displayName;
                infoCell.displayNameLabel.text = [NSString stringWithFormat:@"昵称: %@",self.userInfo.name];
            }else{
                infoCell = [[RCDPrivateSettingsUserInfoCell alloc] initWithIsHaveDisplayName:NO];
                infoCell.NickNameLabel.text = self.userInfo.name;
            }
        }else{
            infoCell = [[RCDPrivateSettingsUserInfoCell alloc] initWithIsHaveDisplayName:NO];
            infoCell.NickNameLabel.text = [RCIM sharedRCIM].currentUserInfo.name;
        }
        if ([portraitUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
                                                    initWithFrame:CGRectMake(0, 0, 100, 100)];
            [defaultPortrait setColorAndLabel:self.userId Nickname:@""];
            UIImage *portrait = [defaultPortrait imageFromView];
            infoCell.PortraitImageView.image = portrait;
        } else {
            [infoCell.PortraitImageView
             sd_setImageWithURL:[NSURL URLWithString:portraitUri]
             placeholderImage:[UIImage imageNamed:@"icon_person"]];
        }

        infoCell.PortraitImageView.layer.masksToBounds = YES;
        infoCell.PortraitImageView.layer.cornerRadius = 5.f;
        infoCell.PortraitImageView.contentMode = UIViewContentModeScaleAspectFill;
        infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return infoCell;
    }
    if (indexPath.section == 1){
        RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[RCDBaseSettingTableViewCell alloc]init];
        }
        cell.leftLabel.text = @"查找聊天记录";
        [cell setCellStyle:DefaultStyle];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == 2){
        switch (indexPath.row) {
            case 0: {
                [cell setCellStyle:SwitchStyle];
                cell.leftLabel.text = @"消息免打扰";
                cell.switchButton.hidden = NO;
//                cell.switchButton.on = !enableNotification;
                [cell.switchButton removeTarget:self
                                         action:@selector(clickIsTopBtn:)
                               forControlEvents:UIControlEventValueChanged];
                
                [cell.switchButton addTarget:self
                                      action:@selector(clickNotificationBtn:)
                            forControlEvents:UIControlEventValueChanged];
                
            } break;
                
            case 1: {
                [cell setCellStyle:SwitchStyle];
                cell.leftLabel.text = @"会话置顶";
                cell.switchButton.hidden = NO;
//                cell.switchButton.on = currentConversation.isTop;
                [cell.switchButton addTarget:self
                                      action:@selector(clickIsTopBtn:)
                            forControlEvents:UIControlEventValueChanged];
            } break;
            case 2: {
                [cell setCellStyle:SwitchStyle];
                cell.leftLabel.text = @"清除聊天记录";
                cell.switchButton.hidden = YES;
            } break;
                
            default:
                break;
        }
        return cell;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    if (section == 1 || section == 2) {
        return 20.f;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heigh = 0.0;
    switch (indexPath.section) {
        case 0:
            heigh = 86.f;
            break;
        case 1:
            heigh = 43.f;
            break;
        case 2:
            heigh = 43.f;
            break;
        default:
            break;
    }
    return heigh;
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==1){
        RCDSearchHistoryMessageController *searchViewController = [[RCDSearchHistoryMessageController alloc] init];
        searchViewController.conversationType = ConversationType_PRIVATE;
        searchViewController.targetId = self.userId;
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
    if(indexPath.section==2){
        if (indexPath.row == 2) {
            UIActionSheet *actionSheet =
            [[UIActionSheet alloc] initWithTitle:@"确定清除聊天记录？"
                                        delegate:self
                               cancelButtonTitle:@"取消"
                          destructiveButtonTitle:@"确定"
                               otherButtonTitles:nil];
            [actionSheet showInView:self.view];
            actionSheet.tag = 100;
        }
    }
}
#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex{
}
@end
