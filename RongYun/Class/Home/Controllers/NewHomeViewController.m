//
//  NewHomeViewController.m
//  RongYun
//
//  Created by zww on 2017/7/18.
//  Copyright © 2017年 zww. All rights reserved.
//

#import "NewHomeViewController.h"
#import "HomeConversationController.h"
#import "RCDUserInfo.h"
#import "RCDChatListCell.h"
#import "UIImageView+WebCache.h"
#import "RCDHttpTool.h"
#import "RCDAddressBookViewController.h"
#import "RCDiyChatListCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
@interface NewHomeViewController ()
@end
@implementation NewHomeViewController
- (id)init {
    self = [super init];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
                                            @(ConversationType_PRIVATE),
                                            @(ConversationType_DISCUSSION),
                                            @(ConversationType_APPSERVICE),
                                            @(ConversationType_PUBLICSERVICE),
                                            @(ConversationType_GROUP),
                                            @(ConversationType_SYSTEM)
                                            ]];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIView*view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            NSLog(@"found the tableview");
             [(UITableView*)view registerNib:[UINib nibWithNibName:@"RCDiyChatListCell" bundle:nil]  forCellReuseIdentifier:@"RCDiyChatListCell"];
            UITableView*tableView=(UITableView*)view;
            tableView.backgroundColor=[UIColor clearColor];
            tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
            UIImageView*imageView=[[UIImageView alloc]initWithFrame:tableView.bounds];
            imageView.contentMode=UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds=YES;
            imageView.image=ImageNamed(@"home_bg");
            tableView.backgroundView=imageView;
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateBadgeValueForTabBarItem];
}
#pragma mark--注册通知
-(void)initNotifications{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateForSharedMessageInsertSuccess)
     name:@"RCDSharedMessageInsertSuccess"
     object:nil];
}
#pragma mark--点击进入会话页面
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath{
    if(conversationModelType==RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION){
        if(model.conversationType==ConversationType_SYSTEM){
            NewHomeViewController*home=[[NewHomeViewController alloc]init];
            if(self.displayConversationTypeArray.count==1){
            }else{
                NSArray *array = [NSArray
                                  arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
                [home setDisplayConversationTypes:array];
                home.isEnteredToCollectionViewController = NO;
                [self.navigationController pushViewController:home animated:YES];
            }
            return;
        }
        HomeConversationController*conversationVc=[[HomeConversationController alloc]init];
        conversationVc.conversationType=model.conversationType;
        conversationVc.targetId=model.targetId;
        conversationVc.title=model.conversationTitle;
        conversationVc.conversation = model;
        conversationVc.unReadMessage = model.unreadMessageCount;
        conversationVc.enableNewComingMessageIcon = YES; //开启消息提醒
        conversationVc.enableUnreadMessageIcon = YES;
        conversationVc.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:conversationVc animated:YES];
    }
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       [self refreshConversationTableViewIfNeeded];
                   });
}
#pragma mark--点击头像
-(void)didTapCellPortrait:(RCConversationModel *)model{
    if(model.conversationModelType==RC_CONVERSATION_MODEL_TYPE_NORMAL){
        HomeConversationController*conversationVc=[[HomeConversationController alloc]init];
        conversationVc.conversationType=model.conversationType;
        conversationVc.targetId=model.targetId;
        conversationVc.title=model.conversationTitle;
        conversationVc.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:conversationVc animated:YES];
    }
}
#pragma mark--收到消息监听
-(void)didReceiveMessageNotification:(NSNotification *)notification{
    __weak typeof(&*self) blockSelf_ = self;
    //处理好友请求
    RCMessage *message = notification.object;
    NSLog(@"message%@",message);
    NSLog(@"content%@",message.content);
    if ([message.content isMemberOfClass:[RCContactNotificationMessage class]]){//消息内容类型是添加好友类型
        if(message.conversationType==ConversationType_SYSTEM){//会话类型
            RCContactNotificationMessage *_contactNotificationMsg =
            (RCContactNotificationMessage *)message.content;
            if (_contactNotificationMsg.sourceUserId == nil ||
                _contactNotificationMsg.sourceUserId.length == 0) {
                return;
            }
            [RCDHTTPTOOL getUserInfoByUserID:_contactNotificationMsg.sourceUserId completion:^(RCUserInfo *user) {
                RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
                rcduserinfo_.name = user.name;
                rcduserinfo_.userId = user.userId;
                rcduserinfo_.portraitUri = user.portraitUri;
                RCConversationModel *customModel = [RCConversationModel new];
                customModel.conversationModelType =
                RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
                customModel.extend = rcduserinfo_;
                customModel.conversationType = message.conversationType;
                customModel.targetId = message.targetId;
                customModel.sentTime = message.sentTime;
                customModel.receivedTime = message.receivedTime;
                customModel.senderUserId = message.senderUserId;
                customModel.lastestMessage = _contactNotificationMsg;//会话最后一条信息
                //
                NSDictionary *userinfoDic = @{
                                              @"username" : user.name,
                                              @"portraitUri" : user.portraitUri
                                              };
                [[NSUserDefaults standardUserDefaults]
                 setObject:userinfoDic
                 forKey:_contactNotificationMsg.sourceUserId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //调用父类刷新未读消息数
                    [blockSelf_
                     refreshConversationTableViewWithConversationModel:
                     customModel];
                    //当消息为RCContactNotificationMessage时，没有调用super，如果是最后一条消息，可能需要刷新一下整个列表。
                    //原因请查看super didReceiveMessageNotification的注释。
                    NSNumber *left =
                    [notification.userInfo objectForKey:@"left"];
                    if (0 == left.integerValue) {
                        [super refreshConversationTableViewIfNeeded];
                    }
                });
            }];
        }
    }else{
        //调用父类刷新未读消息数
        [super didReceiveMessageNotification:notification];
    }
    [self updateBadgeValueForTabBarItem];
}
- (void)updateForSharedMessageInsertSuccess{//插入分享消息
}
#pragma mark--更新badgeValue
- (void)updateBadgeValueForTabBarItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = [[RCIMClient sharedRCIMClient]
                     getUnreadCount:self.displayConversationTypeArray];
        self.navigationController.tabBarItem.badgeValue=count>0?[NSString stringWithFormat:@"%d",count]:nil;
    });
}
#pragma mark--子会话列表
/*******************插入自定义Cell********************/
-(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource{
    for (int i = 0; i < dataSource.count; i++){
        RCConversationModel *model = dataSource[i];
        model.conversationModelType=RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
    }
    return dataSource;
}
//高度
- (CGFloat)rcConversationListTableView:(UITableView *)tableView
               heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"RCDiyChatListCell" configuration:^(id cell) {
    }];
}
//自定义cell
- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
                                  cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    RCContactNotificationMessage *contactNotificationMsg = nil;
    RCDiyChatListCell*cell=[tableView dequeueReusableCellWithIdentifier:@"RCDiyChatListCell" forIndexPath:indexPath];
    cell.diyModel=model;
    if(model.conversationType==ConversationType_SYSTEM&&
       [model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]]){
        contactNotificationMsg=(RCContactNotificationMessage*)model.lastestMessage;
        NSLog(@"%@",contactNotificationMsg.sourceUserId);
    }
    return cell;
}
@end
