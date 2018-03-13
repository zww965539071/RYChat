//
//  NBCTabBarController.m
//  Nibook_Consumer
//
//  Created by Lpkiki on 16/8/18.
//  Copyright © 2016年 hzboru. All rights reserved.
//

#import "NBCTabBarController.h"
#import "NBNavigationController.h"
#import "MeViewController.h"
#import "NewHomeViewController.h"
#import "NewDiscoverViewController.h"
#import <RongIMKit/RongIMKit.h>
@interface NBCTabBarController ()
@end
@implementation NBCTabBarController

// 只会调用一次
+ (void)load
{
    // 获取哪个类中UITabBarItem
    UITabBarItem *item = [UITabBarItem appearanceWhenContainedIn:self, nil];

    // 创建一个描述文本属性的字典
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = AppBlueColor;
    [item setTitleTextAttributes:attrs forState:UIControlStateSelected];
    // 设置字体尺寸:只有设置正常状态下,才会有效果
    NSMutableDictionary *attrsNor = [NSMutableDictionary dictionary];
    attrsNor[NSForegroundColorAttributeName] = TextColor4C535D;
//    attrsNor[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    [item setTitleTextAttributes:attrsNor forState:UIControlStateNormal];
    
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    [UITabBar appearance].backgroundColor = AppBlueColor;
    [UITabBar appearance].barTintColor = [UIColor whiteColor];
    [UITabBar appearance].translucent = NO;
    //去除黑线
//    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
//    [[UITabBar appearance] setShadowImage:[UIImage new]];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 1 添加子控制器
    [self setupAllChildViewController];
    
    // 2 设置tabBar上按钮内容 -> 由对应的子控制器的tabBarItem属性
    [self setupAllTitleButton];
}
#pragma mark - 添加所有子控制器
- (void)setupAllChildViewController
{
    // 0
    NewHomeViewController *homeVc = [[NewHomeViewController alloc] init];
    NBNavigationController *navHome = [[NBNavigationController alloc] initWithRootViewController:homeVc];
    [self addChildViewController:navHome];
    // 1
    NewDiscoverViewController *discoverVc = [[NewDiscoverViewController alloc] init];
    NBNavigationController *navDiscover = [[NBNavigationController alloc] initWithRootViewController:discoverVc];
    [self addChildViewController:navDiscover];
    // 2
    MeViewController *meVc = [[MeViewController alloc] init];
    NBNavigationController *navMe = [[NBNavigationController alloc] initWithRootViewController:meVc];
    [self addChildViewController:navMe];
    
}

// 设置tabBar上所有按钮内容
- (void)setupAllTitleButton
{
    // 0:nav
    UINavigationController *navHome = self.childViewControllers[0];
    navHome.tabBarItem.title = @"首页";
    navHome.tabBarItem.image = [ImageNamed(@"home_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navHome.tabBarItem.selectedImage  = [ImageNamed(@"home_pressed") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    
    // 1:nav
    UINavigationController *discoverVc = self.childViewControllers[1];
    discoverVc.tabBarItem.title = @"发现";
    discoverVc.tabBarItem.image = [ImageNamed(@"listing_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
   
    discoverVc.tabBarItem.selectedImage  = [ImageNamed(@"listing_pressed") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    
    
    // 1:nav
    UINavigationController *navMe = self.childViewControllers[2];
    navMe.tabBarItem.title = @"我的";
    navMe.tabBarItem.image = [ImageNamed(@"profile_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navMe.tabBarItem.selectedImage  = [ImageNamed(@"profile_pressed") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    
}
@end
