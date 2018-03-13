//
//  RCDLoginViewController.m
//  RongYun
//
//  Created by zww on 2017/7/19.
//  Copyright © 2017年 zww. All rights reserved.
//

#import "RCDLoginViewController.h"
#import "RCAnimatedImagesView.h"
#import <Masonry.h>
#import "AFHttpTool.h"
#import "MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDSettingUserDefaults.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "RCDRCIMDataSource.h"
#import "NBCTabBarController.h"
#import "RCDUserInfoManager.h"
@interface RCDLoginViewController ()<RCAnimatedImagesViewDelegate,RCIMConnectionStatusDelegate>
@property(nonatomic,strong)RCAnimatedImagesView*animatedImagesView;
@property(nonatomic,strong)UITextField*userNameTextField;
@property(nonatomic,strong)UITextField*passwordTextField;
@end
@implementation RCDLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"登录";
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self initViews];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.animatedImagesView startAnimating];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.animatedImagesView stopAnimating];
}
#pragma mark--initViews
-(void)initViews{
    //动态图
    self.animatedImagesView = [[RCAnimatedImagesView alloc]
                               initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,
                                                        self.view.bounds.size.height)];
    [self.view addSubview:self.animatedImagesView];
    self.animatedImagesView.delegate = self;
    //用户名
    UITextField*userNameTextField=[[UITextField alloc]init];
    userNameTextField.backgroundColor = [UIColor clearColor];
    UIColor *color = [UIColor whiteColor];
    userNameTextField.attributedPlaceholder = [[NSAttributedString alloc]
                                               initWithString:@"手机号"
                                               attributes:@{NSForegroundColorAttributeName : color}];
    userNameTextField.textColor = [UIColor whiteColor];
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [userNameTextField becomeFirstResponder];
    [self.view addSubview:userNameTextField];
    self.userNameTextField=userNameTextField;
    [userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(150);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
        make.height.mas_offset(40);
    }];
    //密码
    UITextField*passwordTextField=[[UITextField alloc]init];
    passwordTextField.backgroundColor = [UIColor clearColor];
    passwordTextField.textColor = [UIColor whiteColor];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.attributedPlaceholder = [[NSAttributedString alloc]
                                               initWithString:@"密码"
                                               attributes:@{NSForegroundColorAttributeName : color}];
    [self.view addSubview:passwordTextField];
    self.passwordTextField=passwordTextField;
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userNameTextField.mas_bottom).offset(30);
        make.left.right.height.equalTo(userNameTextField);
    }];
    //登录
    UIButton*button=[[UIButton alloc]init];
    button.backgroundColor=[UIColor orangeColor];
    [button setTitle:@"登录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordTextField.mas_bottom).offset(20);
        make.left.right.height.equalTo(passwordTextField);
    }];
}
#pragma mark--action
//登录
-(void)login{
    [self login:self.userNameTextField.text password:self.passwordTextField.text];
}
- (void)login:(NSString *)userName password:(NSString *)password{
    if(userName.length==0||password.length==0)return;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AFHttpTool loginWithPhone:userName password:password region:@"86" success:^(id response) {
        if([response[@"code"]integerValue]==200){
            NSString *token = response[@"result"][@"token"];
            NSString *userId = response[@"result"][@"id"];
              [self loginRongCloud:userName userId:userId token:token password:password];
        }
    } failure:^(NSError *err) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
//登录融云服务器
-(void)loginRongCloud:(NSString*)userName
               userId:(NSString*)userId
                token:(NSString*)token
             password:(NSString*)password{
    
    [[RCIM sharedRCIM]connectWithToken:token success:^(NSString *userId) {
        //保存默认用户
        [DEFAULTS setObject:userName forKey:@"userName"];//默认指的是登录的手机号
        [DEFAULTS setObject:password forKey:@"userPwd"];
        [DEFAULTS setObject:token forKey:@"userToken"];
        [DEFAULTS setObject:userId forKey:@"userId"];
        //请求当前登录用户信息
        [AFHttpTool getUserInfo:userId success:^(id response) {//该接口中有用户较详细信息
            if([response[@"code"]integerValue]==200){
                NSDictionary*result=response[@"result"];
                NSString*nickname=result[@"nickname"];
                NSString*portraitUri=result[@"portraitUri"];
                [DEFAULTS setObject:portraitUri forKey:@"userPortraitUri"];
                [DEFAULTS setObject:nickname forKey:@"nickname"];
                RCUserInfo*user=[[RCUserInfo alloc]initWithUserId:userId name:nickname portrait:portraitUri];
                if(portraitUri.length==0||!portraitUri){
                    user.portraitUri=[RCDUtilities defaultUserPortrait:user];//用户没有设置头像则显示默认头像
                }
                [[RCDataBaseManager shareInstance]insertUserToDB:user];//存储到本地数据库
                [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:userId];//刷新融云SDK缓存
                [RCIM sharedRCIM].currentUserInfo=user;//当前登录用户
            }
        } failure:^(NSError *err) {
            
        }];
        //从融云服务器获取联系人列表
        [RCDDataSource syncFriendList:userId
                             complete:^(NSMutableArray *friends){
                             }];
        [RCDDataSource syncGroups];
        if(self.loginSuccess){
            self.loginSuccess();
        }
    } error:^(RCConnectErrorCode status) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[RCIM sharedRCIM]setConnectionStatusDelegate:self];
        });
    } tokenIncorrect:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
#pragma mark--RCAnimatedImageViewDelegate
- (NSUInteger)animatedImagesNumberOfImages:
(RCAnimatedImagesView *)animatedImagesView {
    return 2;
}
- (UIImage *)animatedImagesView:(RCAnimatedImagesView *)animatedImagesView
                   imageAtIndex:(NSUInteger)index {
    return [UIImage imageNamed:@"login_background.png"];
}
#pragma mark--RCIMConnectionStatusDelegate
-(void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
}
#pragma mark--private func
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
