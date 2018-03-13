//
//  RealTimeLocationEndCell.h
//  RongYun
//
//  Created by zww on 2017/8/9.
//  Copyright © 2017年 zww. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface RealTimeLocationEndCell : RCMessageBaseCell
/**
 *  tipMessage显示Label
 */
@property(strong, nonatomic) RCTipLabel *tipMessageLabel;

/**
 *  设置消息数据模型
 *
 *  @param model 消息数据模型
 */
- (void)setDataModel:(RCMessageModel *)model;
@end
