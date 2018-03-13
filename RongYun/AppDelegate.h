//
//  AppDelegate.h
//  RongYun
//
//  Created by zww on 2017/7/18.
//  Copyright © 2017年 zww. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,RCIMConnectionStatusDelegate,RCIMReceiveMessageDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

