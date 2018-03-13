//
//  HomeConversationController.m
//  RongYun
//
//  Created by zww on 2017/7/26.
//  Copyright © 2017年 zww. All rights reserved.
//
#import "HomeConversationController.h"
#import "RCDUserInfoManager.h"
#import "RCDPersonDetailViewController.h"
#import "RCDUIBarButtonItem.h"
#import "RCDataBaseManager.h"
#import "RCDPrivateSettingsTableViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDHttpTool.h"
#import "RCDGroupSettingsTableViewController.h"
#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationEndCell.h"
#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationViewController.h"
#import "UzysAssetsPickerController.h"
#import "RCDChatCell.h"
#import "RCDTextMessageCell.h"
#import "RCDImageCell.h"
@interface HomeConversationController ()<RCRealTimeLocationObserver,RealTimeLocationStatusViewDelegate,RCPluginBoardViewDelegate,UzysAssetsPickerControllerDelegate>
@property(nonatomic,weak)id realTimeLocation;
@property(nonatomic, strong)RealTimeLocationStatusView *realTimeLocationStatusView;
@end
NSMutableDictionary *userInputStatus;

@implementation HomeConversationController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    for (id model in self.conversationDataRepository) {
        NSLog(@"----------");
        if([model isKindOfClass:[RCMessageModel class]]){
            RCMessageModel*message=model;
            NSLog(@"messagecontent:%@",message.content);
            if([message.content isKindOfClass:[RCImageMessage class]]){
                [self registerClass:[RCDImageCell class] forMessageClass:[message.content class]];
            }else if([message.content isKindOfClass:[RCTextMessage class]]){
                [self registerClass:[RCDTestMessageCell class]
                    forMessageClass:[message.content class]];
            }else if ([message.content isKindOfClass:[RCCallSummaryMessage class]]){
            }else if ([message.content isKindOfClass:[RCVoiceMessage class]]){
            }else if ([message.content isKindOfClass:[RCLocationMessage class]]){
            }
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.enableSaveNewPhotoToLocalSystem = YES;
    [self initViews];
    [self initNotifications];
    [self refreshUserInfoOrGroupInfo];
}
#pragma mark--initViews
-(void)initViews{
    [self setTitle];
    [self setRightNavigationItem];
    [self setLeftNavigationItem];
    [self setPlusBoard];
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:self.conversationMessageCollectionView.bounds];
    imageView.contentMode=UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds=YES;
    imageView.image=ImageNamed(@"home_conversation");
    self.conversationMessageCollectionView.backgroundView=imageView;
}
//title
-(void)setTitle{
    if(self.conversationType==ConversationType_GROUP){
        int count = [[[RCDataBaseManager shareInstance] getGroupByGroupId:self.targetId].number intValue];
        self.title = [NSString stringWithFormat:@"%@(%d)",self.title,count];
    }
}
//rightNavigationItem
-(void)setRightNavigationItem{
    if(self.conversationType!=ConversationType_CHATROOM){
        if(self.conversationType==ConversationType_DISCUSSION){
            
        }else if (self.conversationType==ConversationType_GROUP){
            [self setRightNavigationItem:[UIImage imageNamed:@"Group_Setting"]
                               withFrame:CGRectMake(10, 3.5, 21, 19.5)];
        }else{
            [self setRightNavigationItem:[UIImage imageNamed:@"Private_Setting"]
                               withFrame:CGRectMake(15, 3.5, 16, 18.5)];
        }
    }else{
        self.navigationItem.rightBarButtonItem=nil;
    }
}
- (void)setRightNavigationItem:(UIImage *)image withFrame:(CGRect)frame {
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc]
                                    initContainImage:image
                                    imageViewFrame:frame
                                    buttonTitle:nil
                                    titleColor:nil
                                    titleFrame:CGRectZero
                                    buttonFrame:CGRectMake(0, 0, 25, 25)
                                    target:self
                                    action:@selector(rightBarButtonItemClicked)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}
-(void)rightBarButtonItemClicked{
    if(self.conversationType==ConversationType_PRIVATE){
        RCDUserInfo*friendInfo=[[RCDataBaseManager shareInstance]getFriendInfo:self.targetId];
        NSLog(@"%@:%@",friendInfo.name,friendInfo.userId);
        if(![friendInfo.status isEqualToString:@"20"]){//不是好友关系
            
        }else{
            RCDPrivateSettingsTableViewController*setting=[[RCDPrivateSettingsTableViewController alloc]init];
            setting.userId=self.targetId;
            [self.navigationController pushViewController:setting animated:YES];
        }
    }else if (self.conversationType==ConversationType_DISCUSSION){
    }else if (self.conversationType == ConversationType_GROUP){
        RCDGroupSettingsTableViewController*settingVC=[[RCDGroupSettingsTableViewController alloc]init];
        [self.navigationController pushViewController:settingVC animated:YES];
    }else if (self.conversationType == ConversationType_CUSTOMERSERVICE ||
              self.conversationType == ConversationType_SYSTEM){
    }else if (ConversationType_APPSERVICE == self.conversationType ||
              ConversationType_PUBLICSERVICE == self.conversationType){
    }
}
//leftNavigationItem
- (void)setLeftNavigationItem{
    [super notifyUpdateUnreadMessageCount];
    __weak typeof(&*self) __weakself = self;
    int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                @(ConversationType_PRIVATE),
                                                                @(ConversationType_DISCUSSION),
                                                                @(ConversationType_APPSERVICE),
                                                                @(ConversationType_PUBLICSERVICE),
                                                                @(ConversationType_GROUP)
                                                                ]];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *backString = nil;
        if (count > 0 && count < 1000) {
            backString = [NSString stringWithFormat:@"返回(%d)", count];
        } else if (count >= 1000) {
            backString = @"返回(...)";
        } else {
            backString = @"返回";
        }
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 6, 87, 23);
        UIImageView *backImg = [[UIImageView alloc]
                                initWithImage:[UIImage imageNamed:@"back"]];
        backImg.frame = CGRectMake(-6, 3, 10, 17);
        [backBtn addSubview:backImg];
        UILabel *backText =
        [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];
        backText.text = backString;
        [backText setBackgroundColor:[UIColor clearColor]];
        [backText setTextColor:[UIColor whiteColor]];
        [backText setFont:[UIFont systemFontOfSize:16]];
        [backBtn addSubview:backText];
        [backBtn addTarget:__weakself
                    action:@selector(leftBarButtonItemPressed:)
          forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton =
        [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [__weakself.navigationItem setLeftBarButtonItem:leftButton];
    });
}
-(void)leftBarButtonItemPressed:(id)sender{
    [self popupChatViewController];
}
- (void)popupChatViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
//plusBoard
-(void)setPlusBoard{
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:5];
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:5];
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:2];
    self.chatSessionInputBarControl.pluginBoardView.pluginBoardDelegate=self;
}
#pragma mark--initNotifications
-(void)initNotifications{
    if(self.conversationType==ConversationType_GROUP){
        //群组改名之后，更新当前页面的Title
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTitleForGroup:)
                                                     name:@"UpdeteGroupInfo"
                                                   object:nil];
    }
    //清除历史消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHistoryMSG:)
                                                 name:@"ClearHistoryMsg"
                                               object:nil];
    //插入分享消息
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateForSharedMessageInsertSuccess:)
     name:@"RCDSharedMessageInsertSuccess"
     object:nil];
}
- (void)updateTitleForGroup:(NSNotification *)notification{
}
- (void)clearHistoryMSG:(NSNotification *)notification{
}
- (void)updateForSharedMessageInsertSuccess:(NSNotification *)notification{
}
#pragma mark--refreshUserInfoOrGroupInfo
-(void)refreshUserInfoOrGroupInfo{//刷新个人或群组的信息
    //刷新单聊
    if(self.conversationType==ConversationType_PRIVATE){
        if(![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]){//刷新单聊对方信息
            __weak typeof (self) weakSelf = self;
            [[RCDUserInfoManager shareInstance]getUserInfo:self.targetId completion:^(RCUserInfo *user) {
                [[RCDHttpTool shareInstance]updateUserInfo:user.userId success:^(RCDUserInfo *user) {
                    RCUserInfo *updatedUserInfo =
                    [[RCUserInfo alloc] init];
                    updatedUserInfo.userId = user.userId;
                    if (user.displayName.length > 0) {
                        updatedUserInfo.name = user.displayName;
                    } else {
                        updatedUserInfo.name = user.name;
                    }
                    updatedUserInfo.portraitUri = user.portraitUri;
                    weakSelf.navigationItem.title =
                    updatedUserInfo.name;
                    [[RCIM sharedRCIM]
                     refreshUserInfoCache:updatedUserInfo
                     withUserId:updatedUserInfo.userId];
                } failure:^(NSError *err) {
                    
                }];
            }];
        }
        //刷新自己信息
        [[RCDUserInfoManager shareInstance]getUserInfo:[RCIM sharedRCIM].currentUserInfo.userId completion:^(RCUserInfo *user) {
            [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:user.userId];
        }];
    }
    //刷新群聊
    if (self.conversationType==ConversationType_GROUP) {
        __weak typeof(self) weakSelf = self;
        [RCDHTTPTOOL getGroupByID:self.targetId successCompletion:^(RCDGroupInfo *group) {
            RCGroup *Group =
            [[RCGroup alloc] initWithGroupId:weakSelf.targetId
                                   groupName:group.groupName
                                 portraitUri:group.portraitUri];
            [[RCIM sharedRCIM] refreshGroupInfoCache:Group
                                         withGroupId:weakSelf.targetId];
        }];
    }
}
#pragma mark--PlusBoardDelegate
-(void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    switch (tag) {
        case PLUGIN_BOARD_ITEM_ALBUM_TAG:
            [self openCamera];
            break;
        default:
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            break;
    }
}
#pragma mark--UzysAssetsPickerControllerDelegate
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    __weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]){
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                               scale:representation.defaultRepresentation.scale
                                         orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
            RCImageMessage*content=[RCImageMessage messageWithImage:img];
            content.extra=@"nihao";
            [weakSelf sendMessage:content pushContent:@""];
        }];
    }
}
#pragma mark-- action funcs
//点击头像
-(void)didTapCellPortrait:(NSString *)userId{
    if(self.conversationType==ConversationType_PRIVATE){
        [[RCDUserInfoManager shareInstance]getUserInfo:userId completion:^(RCUserInfo *user) {
            [self gotoNextPage:user];
        }];
    }
}
-(void)gotoNextPage:(RCUserInfo*)user{
    RCDPersonDetailViewController *temp =[[RCDPersonDetailViewController alloc]init];
    temp.userId=user.userId;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:temp animated:YES];
    });
}
//打开相机
-(void)openCamera{
#if 0
    UzysAppearanceConfig *appearanceConfig = [[UzysAppearanceConfig alloc] init];
    appearanceConfig.finishSelectionButtonColor = [UIColor blueColor];
    appearanceConfig.assetsGroupSelectedImageName = @"checker.png";
    appearanceConfig.cellSpacing = 1.0f;
    appearanceConfig.assetsCountInALine = 5;
    [UzysAssetsPickerController setUpAppearanceConfig:appearanceConfig];
#endif
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = 1;
    [self presentViewController:picker animated:YES completion:^{
    }];
}
#pragma mark--拍照后图片保存相册
-(void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage{
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(
                                   image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
}
@end
