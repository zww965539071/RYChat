//
//  RealTimeLocationStatusView.h
//  RongYun
//
//  Created by zww on 2017/8/10.
//  Copyright © 2017年 zww. All rights reserved.
//
#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>
@protocol RealTimeLocationStatusViewDelegate<NSObject>
-(void)onJoin;
-(void)onShowRealTimeLocationView;
-(RCRealTimeLocationStatus)getStatus;
@end
@interface RealTimeLocationStatusView : UIView
@property(nonatomic,weak)id<RealTimeLocationStatusViewDelegate>delegate;
- (void)updateText:(NSString *)statusText;
- (void)updateRealTimeLocationStatus;
@end
