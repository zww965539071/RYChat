//
//  HomeConversationController.h
//  RongYun
//
//  Created by zww on 2017/7/26.
//  Copyright © 2017年 zww. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface HomeConversationController : RCConversationViewController
/**
 *  会话数据模型
 */
@property(strong, nonatomic) RCConversationModel *conversation;
-(UIView *)loadEmoticonView:(NSString *)identify index:(int)index;
@end
