//
//  UzysAssetsViewCell.h
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
@interface UzysAssetsViewCell : UICollectionViewCell
- (void)applyData:(ALAsset *)asset index:(NSInteger)index;
@property(nonatomic,copy)void(^backAction)(void);
@end
