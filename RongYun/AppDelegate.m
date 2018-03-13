//
//  AppDelegate.m
//  RongYun
//
//  Created by zww on 2017/7/18.
//  Copyright © 2017年 zww. All rights reserved.
//
#import "AppDelegate.h"
#import "NBCTabBarController.h"
#import "RCDCommonDefine.h"
#import "RCDLoginViewController.h"
#import "NBNavigationController.h"
#import "AFHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDHttpTool.h"
#import <YYModel.h>
@interface AppDelegate ()
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self setupRongYun];
    [self initRootViewController];
    return YES;
}
/****************启动融云******************/
-(void)setupRongYun{
    [[RCIM sharedRCIM]initWithAppKey:@"n19jmcy59f1q9"];
}
/***************初始化根控制器**************/
-(void)initRootViewController{
    [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;//设置用户信息源
    [RCIM sharedRCIM].groupInfoDataSource = RCDDataSource;//设置群组信息源
    [RCIM sharedRCIM].groupMemberDataSource = RCDDataSource;
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    NSString *token = [DEFAULTS objectForKey:@"userToken"];
    if(token.length){
        //连接RongCloud服务器
        [[RCIM sharedRCIM]connectWithToken:token success:^(NSString *userId) {
            [RCDHTTPTOOL getUserInfoByUserID:userId completion:^(RCUserInfo *user) {
                [DEFAULTS setObject:user.portraitUri forKey:@"userPortraitUri"];
                [DEFAULTS setObject:user.name forKey:@"nickname"];
                [RCIM sharedRCIM].currentUserInfo=[[RCUserInfo alloc]initWithUserId:userId name:user.name portrait:user.portraitUri];
            }];
        } error:^(RCConnectErrorCode status) {
        } tokenIncorrect:^{
        }];
        NBCTabBarController *main =[[NBCTabBarController alloc]init];
        self.window.rootViewController = main;
        [self insertSharedMessageIfNeed];
    }else{
        RCDLoginViewController *vc = [[RCDLoginViewController alloc] init];
        NBNavigationController*nav=[[NBNavigationController alloc]initWithRootViewController:vc];
        self.window.rootViewController = nav;
        vc.loginSuccess = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NBCTabBarController *main =[[NBCTabBarController alloc]init];
                self.window.rootViewController = main;
            });
        };
    }
}
/***************插入分享消息************/
- (void)insertSharedMessageIfNeed{
    NSUserDefaults *shareUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.rongcloud.im.share"];
    NSArray *sharedMessages = [shareUserDefaults valueForKey:@"sharedMessages"];
    if (sharedMessages.count > 0){
        for (NSDictionary *sharedInfo in sharedMessages){
            RCRichContentMessage *richMsg = [[RCRichContentMessage alloc]init];
            richMsg.title = [sharedInfo objectForKey:@"title"];
            richMsg.digest = [sharedInfo objectForKey:@"content"];
            richMsg.url = [sharedInfo objectForKey:@"url"];
            richMsg.imageURL = [sharedInfo objectForKey:@"imageURL"];
            richMsg.extra = [sharedInfo objectForKey:@"extra"];
            RCMessage *message = [[RCIMClient sharedRCIMClient] insertOutgoingMessage:[[sharedInfo objectForKey:@"conversationType"] intValue] targetId:[sharedInfo objectForKey:@"targetId"] sentStatus:SentStatus_SENT content:richMsg];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCDSharedMessageInsertSuccess" object:message];
        }
        [shareUserDefaults removeObjectForKey:@"sharedMessages"];
        [shareUserDefaults synchronize];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
