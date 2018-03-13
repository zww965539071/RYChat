//
//  RCDAddressBookViewController.h
//  RongYun
//
//  Created by zww on 2017/8/9.
//  Copyright © 2017年 zww. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDAddressBookViewController : UITableViewController
+ (instancetype)addressBookViewController;

@property(nonatomic, strong) NSArray *keys;

@property(nonatomic, strong) NSMutableDictionary *allFriends;

@property(nonatomic, strong) NSArray *allKeys;

@property(nonatomic, strong) NSArray *seletedUsers;

@property(nonatomic, assign) BOOL hideSectionHeader;

@property(nonatomic, assign) BOOL needSyncFriendList;
@end

