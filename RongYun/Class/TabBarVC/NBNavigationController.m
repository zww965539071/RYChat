//
//  NBNavigationController.m
//  Nibook_Consumer
//
//  Created by Lpkiki on 16/8/22.
//  Copyright © 2016年 hzboru. All rights reserved.
//

#import "NBNavigationController.h"
@interface NBNavigationController ()

@end

@implementation NBNavigationController

+(void)load{
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:self, nil];
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = NibookBFont;
    attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [navBar setTitleTextAttributes:attrs];
    navBar.tintColor = [UIColor whiteColor];
    [navBar setBarTintColor:AppBlueColor];
    //返回键的标题 隐藏
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1.5, 0) forBarMetrics:UIBarMetricsDefault];
    // 设置导航条背景图片
    UIImage *tmpImage = [UIImage imageNamed:@"back"];
    CGSize newSize = CGSizeMake(12, 20);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [tmpImage drawInRect:CGRectMake(2, -2, newSize.width, newSize.height)];
    UIImage *backButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
     navBar.translucent = NO;//important
}

- (void)viewDidLoad {
    [super viewDidLoad];

   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
