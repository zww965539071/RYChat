//
//  RCDPersonDetailViewController.m
//  RongYun
//
//  Created by zww on 2017/7/27.
//  Copyright © 2017年 zww. All rights reserved.
//

#import "RCDPersonDetailViewController.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>
#import <Masonry.h>
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "RCDCommonDefine.h"
#import <RongCallKit/RongCallKit.h>
#import "DefaultPortraitView.h"
#import "UIImageView+WebCache.h"
#import "AFHttpTool.h"
@interface RCDPersonDetailViewController ()
@property(nonatomic,strong)UIView*infoV;
@property(nonatomic,strong)UIImageView*ivImageV;
@property(nonatomic,strong)UILabel*lblNameV;
@property(nonatomic,strong)UILabel*phoneNumberV;
@property(nonatomic,strong)UIView*remarksView;
@property(nonatomic, strong) UIButton *conversationBtn;
@property(nonatomic, strong) UIButton *audioCallBtn;
@property(nonatomic, strong) UIButton *videoCallBtn;
@property(nonatomic, strong) RCDUserInfo *friendInfo;
@end
@implementation RCDPersonDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    [self initViews];
    [self initData];
}
#pragma mark--initViews
-(void)initViews{
    //infoV
    self.infoV=[[UIView alloc]init];
    self.infoV.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.infoV];
    //ivImageV
    self.ivImageV=[[UIImageView alloc]init];
    [self.infoV addSubview:self.ivImageV];
    //lblNameV
    self.lblNameV=[[UILabel alloc]init];
    [self.infoV addSubview:self.lblNameV];
    //phoneNumberV
    self.phoneNumberV=[[UILabel alloc]init];
    [self.infoV addSubview:self.phoneNumberV];
    //remarksView
    self.remarksView=[[UIView alloc]init];
    self.remarksView.backgroundColor=[UIColor whiteColor];
    self.remarksView.hidden=NO;
    [self.view addSubview:self.remarksView];
    //发起会话
    self.conversationBtn = [[UIButton alloc]init];
    self.conversationBtn.backgroundColor = [UIColor colorWithHexString:@"0099ff" alpha:1.f];
    [self.conversationBtn setTitle:@"发起会话" forState:UIControlStateNormal];
    self.conversationBtn.layer.masksToBounds = YES;
    self.conversationBtn.layer.cornerRadius = 5.f;
    self.conversationBtn.layer.borderWidth = 0.5;
    self.conversationBtn.layer.borderColor = [HEXCOLOR(0x0181dd) CGColor];
    [self.view addSubview:self.conversationBtn];
    //语音通话
    self.audioCallBtn = [[UIButton alloc]init];
    self.audioCallBtn.backgroundColor = [UIColor whiteColor];
    [self.audioCallBtn setTitle:@"语音通话" forState:UIControlStateNormal];
    [self.audioCallBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.audioCallBtn];
    //视频通话
    self.videoCallBtn = [[UIButton alloc]init];
    self.videoCallBtn.backgroundColor = [UIColor whiteColor];
    [self.videoCallBtn setTitle:@"视频通话" forState:UIControlStateNormal];
    [self.videoCallBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.videoCallBtn];
    /******************layout******************/
    if(![self.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]){//userId不是当前登录用户
        [self layoutForFriend];
    }else{
        [self layoutForSelf];
    }
}
-(void)layoutForFriend{
    [self.infoV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(85);
    }];
    [self.ivImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.infoV).mas_offset(10);
        make.centerY.equalTo(self.infoV);
        make.width.height.mas_equalTo(65);
    }];
    self.friendInfo = [[RCDataBaseManager shareInstance] getFriendInfo:self.userId];
    [self.lblNameV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ivImageV).offset(10);
        make.left.equalTo(self.ivImageV.mas_right).offset(10);
    }];
    [self.phoneNumberV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblNameV.mas_bottom).offset(10);
        make.left.equalTo(self.lblNameV);
    }];
    //remarksView
    self.remarksView.hidden=NO;
    [self.remarksView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoV.mas_bottom).offset(15);
        make.left.right.equalTo(self.infoV);
        make.height.mas_equalTo(43);
    }];
    UILabel*remarkL=[[UILabel alloc]init];
    remarkL.text=@"设置备注";
    [self.remarksView addSubview:remarkL];
    UIImageView*rightArrow=[[UIImageView alloc]init];
    rightArrow.image = [UIImage imageNamed:@"right_arrow"];
    [self.remarksView addSubview:rightArrow];
    [remarkL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.remarksView).offset(10);
        make.bottom.equalTo(self.remarksView).offset(-10);
    }];
    [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.remarksView).offset(-10);
        make.centerY.equalTo(self.remarksView);
    }];
    //发起会话
    [self.conversationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remarksView.mas_bottom).offset(15);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.mas_equalTo(43);
    }];
    //语音通话
    [self.audioCallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.conversationBtn.mas_bottom).offset(15);
        make.left.right.equalTo(self.conversationBtn);
        make.height.equalTo(self.conversationBtn);
        if([[RCCallClient sharedRCCallClient]isAudioCallEnabled:ConversationType_PRIVATE]){
            
        }
    }];
    //视频通话
    [self.videoCallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.audioCallBtn.mas_bottom).offset(15);
        make.left.right.equalTo(self.audioCallBtn);
        make.height.equalTo(self.conversationBtn);
    }];
}
-(void)layoutForSelf{
    [self.infoV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(85);
    }];
    [self.ivImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.infoV).mas_offset(10);
        make.centerY.equalTo(self.infoV);
        make.width.height.mas_equalTo(65);
    }];
    [self.lblNameV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ivImageV.mas_right).offset(10);
        make.centerY.equalTo(self.ivImageV);
    }];
    self.remarksView.hidden=YES;
    //发起会话
    [self.conversationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoV.mas_bottom).offset(15);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.mas_equalTo(43);
    }];
}
#pragma mark--initData
-(void)initData{
    //头像
    NSString*portraitUri;
    NSString*nickName;
    if(![self.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]){
        portraitUri=self.friendInfo.portraitUri;
        nickName=self.friendInfo.name;
    }else{
        portraitUri=[RCIM sharedRCIM].currentUserInfo.portraitUri;
        nickName=[RCIM sharedRCIM].currentUserInfo.name;
    }
    if(portraitUri.length==0){
        DefaultPortraitView *defaultPortrait =[[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:self.friendInfo.userId
                                 Nickname:self.friendInfo.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        self.ivImageV.image = portrait;
    }else{
        [self.ivImageV
         sd_setImageWithURL:[NSURL URLWithString:portraitUri]
         placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    //昵称
    self.lblNameV.text=nickName;
    //手机号
    [AFHttpTool getFriendDetailsByID:self.friendInfo.userId success:^(id response) {
        if ([response[@"code"] integerValue] == 200) {
            NSDictionary *dic = response[@"result"];
            NSDictionary *infoDic = dic[@"user"];
            self.phoneNumberV.text = [NSString stringWithFormat:@"手机号: %@",[infoDic objectForKey:@"phone"]];
            //创建 NSMutableAttributedString
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: self.phoneNumberV.text];
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHexString:@"0099ff" alpha:1.f] range: NSMakeRange(5, 11)];
            self.phoneNumberV.attributedText = attributedStr;
        }
    } failure:^(NSError *err) {
        
    }];
}
@end
