//
//  RCDImageCell.m
//  RongYun
//
//  Created by zww on 2017/8/30.
//  Copyright © 2017年 zww. All rights reserved.
//

#import "RCDImageCell.h"
#import <RongIMKit/RongIMKit.h>
#import "UIImageView+WebCache.h"
@implementation RCDImageCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGSize size = [[self class]imageViewSize:model];
    return CGSizeMake(collectionViewWidth, size.height+extraHeight);
}
#pragma mark--initViews
- (void)initialize{
    //bubbleBackgroundView
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    //imageView
    self.imageView=[[UIImageView alloc]initWithFrame:CGRectZero];
    self.imageView.contentMode=UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds=YES;
    [self.messageContentView addSubview:self.imageView];
}
#pragma mark--initData
-(void)setDataModel:(RCMessageModel *)model{
    [super setDataModel:model];
    [self setAutoLayout];
    RCImageMessage*imageModel=(RCImageMessage*)self.model.content;
    NSLog(@"%@",imageModel.imageUrl);
    if([imageModel.imageUrl containsString:@"/Users/zww/Library/Developer/CoreSimulator/Devices"]){
        self.imageView.image=imageModel.thumbnailImage;
    }else{
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.imageUrl]
                          placeholderImage:[UIImage imageNamed:@"square_ph_125x125"]];

    }
}
-(void)setAutoLayout{
    if(self.messageDirection==MessageDirection_RECEIVE){
        self.imageView.frame=CGRectMake(10, 0, 100, 100);
    }else{
        self.imageView.frame=CGRectMake(self.messageContentView.frame.size.width-100-10, 0, 100, 100);
    }
    CGRect messageContentViewRect = self.messageContentView.frame;
    messageContentViewRect.size.height = self.imageView.frame.size.height;
    self.messageContentView.frame = messageContentViewRect;
    self.messageContentView.backgroundColor=[UIColor redColor];
}
#pragma mark--private func
+(CGSize)imageViewSize:(RCMessageModel*)model{
    CGFloat width = 100;
    CGFloat height = 100;
    return CGSizeMake(width, height);
}
@end
