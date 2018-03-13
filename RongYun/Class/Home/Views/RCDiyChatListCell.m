//
//  RCDiyChatListCell.m
//  RongYun
//
//  Created by zww on 2017/8/21.
//  Copyright © 2017年 zww. All rights reserved.
//

#import "RCDiyChatListCell.h"
#import "RCDHttpTool.h"
#import "UIImageView+WebCache.h"
#import <Masonry.h>
#import "RCDBadgeButton.h"
@interface RCDiyChatListCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet UILabel *nickL;
@property (weak, nonatomic) IBOutlet UILabel *tipL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (strong, nonatomic)RCDBadgeButton*badgeBtn;
@end
@implementation RCDiyChatListCell
-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor=[UIColor clearColor];
    self.iconV.layer.cornerRadius=5;
    self.iconV.layer.masksToBounds=YES;
    [self addSubview:self.badgeBtn];
}
-(CGSize)sizeThatFits:(CGSize)size{
    return self.frame.size;
}
-(void)setDiyModel:(id)diyModel{
    _diyModel=diyModel;
    if([diyModel isKindOfClass:[RCConversationModel class]]){
        RCConversationModel*model=(RCConversationModel*)diyModel;
        if(model.conversationType==ConversationType_GROUP){//群组
            [RCDHTTPTOOL getGroupByID:[NSString stringWithFormat:@"%@",model.targetId ]successCompletion:^(RCDGroupInfo *group) {
                self.nickL.text=group.groupName;
                NSString*tipString;
                if([model.lastestMessage isKindOfClass:[RCTextMessage class]]){
                    RCTextMessage*message=(RCTextMessage*)model.lastestMessage;
                    tipString=message.content;
                }else if ([model.lastestMessage isKindOfClass:[RCImageMessage class]]){
                    tipString=@"[图片]";
                }
                self.tipL.text=tipString;
                self.timeL.text=[RCKitUtility ConvertMessageTime:model.sentTime/1000];
                [self.iconV sd_setImageWithURL:[NSURL URLWithString:group.portraitUri] placeholderImage:[UIImage imageNamed:@"home_pressed"]];
            }];
        }else if (model.conversationType==ConversationType_SYSTEM&&
                  [model.lastestMessage
                   isMemberOfClass:[RCContactNotificationMessage class]]){
                      self.nickL.text=@"System message";
                      self.tipL.text=[NSString stringWithFormat:@"%@%@",@"",@"请求添加好友"];
                      self.iconV.image=[UIImage imageNamed:@"system_notice"];
        }else{
            [RCDHTTPTOOL
             getUserInfoByUserID:model.targetId
             completion:^(RCUserInfo *user) {
                self.nickL.text=user.name;
                self.tipL.text=[RCKitUtility formatMessage:model.lastestMessage];
                [self.iconV sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                      placeholderImage:[UIImage imageNamed:@"home_pressed"]];
                self.timeL.text=[RCKitUtility ConvertMessageTime:model.sentTime/1000];
             }];
        }
        //iconV
        NSInteger unreadCount = model.unreadMessageCount;
        CGFloat w=0.0;
        CGFloat h=0.0;
        if(unreadCount<10&&unreadCount!=0){
            w=h= 18;
        }
        if (unreadCount>=10&&unreadCount<100) {
            w=22;
            h=18;
        }
        if(unreadCount>=100){
        }
        [self.badgeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(w);
            make.height.mas_equalTo(h);
            make.left.equalTo(self.iconV.mas_right).offset(-9);
            make.top.equalTo(self.iconV.mas_top).offset(-9);
        }];
        [self.badgeBtn setTitle:[NSString stringWithFormat:@"%ld",(long)unreadCount] forState:UIControlStateNormal];
    }
}
#pragma mark--getter
-(RCDBadgeButton*)badgeBtn{
    if (_badgeBtn==nil) {
        _badgeBtn=[[RCDBadgeButton alloc]init];
    }
    return _badgeBtn;
}
@end
