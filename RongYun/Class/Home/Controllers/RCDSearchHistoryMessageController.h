//
//  RCDSearchHistoryMessageController.h
//  RongYun
//
//  Created by zww on 2017/8/4.
//  Copyright © 2017年 zww. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
@interface RCDSearchHistoryMessageController : UITableViewController
/*!
 当前会话的会话类型
 */
@property(nonatomic) RCConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;
@end
