//
//  RCDBadgeButton.m
//  RongYun
//
//  Created by zww on 2017/8/24.
//  Copyright © 2017年 zww. All rights reserved.
//
#define kBtnWidth self.bounds.size.width
#define kBtnHeight self.bounds.size.height
#import "RCDBadgeButton.h"
@interface RCDBadgeButton()
@property (nonatomic, strong) UIView *samllCircleView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@end
@implementation RCDBadgeButton{
    CGFloat _maxDistance;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}
#pragma mark--getter
- (UIView *)samllCircleView{
    if (!_samllCircleView) {
        _samllCircleView = [[UIView alloc] init];
        _samllCircleView.backgroundColor = [UIColor blueColor];
    }
    return _samllCircleView;
}
- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [[UIColor yellowColor] CGColor];
    }
    return _shapeLayer;
}
#pragma mark--initView
- (void)setUp{
    self.backgroundColor=RGB(244, 53, 48);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [self.superview insertSubview:self.samllCircleView belowSubview:self];
    [self.superview.layer insertSublayer:self.shapeLayer below:self.layer];
    UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cornerRadius = (kBtnHeight > kBtnWidth ? kBtnWidth / 2.0 : kBtnHeight / 2.0);
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    _maxDistance = cornerRadius*2;
    self.samllCircleView.frame=self.bounds;
    self.samllCircleView.layer.cornerRadius = cornerRadius;
    [self pan:[UITapGestureRecognizer alloc]];
}
#pragma mark--func
- (void)pan:(UITapGestureRecognizer *)pan{
    [self.layer removeAnimationForKey:@"shake"];
    CGFloat shake = 3;
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animation];
    keyAnim.keyPath = @"transform.translation.x";
    keyAnim.values = @[@(-shake), @(shake), @(-shake)];
    keyAnim.removedOnCompletion = NO;
    keyAnim.repeatCount = 2;
    keyAnim.duration = 0.3;
    if ( [self.layer animationForKey:@"shake"] == nil) {
        [self.layer addAnimation:keyAnim forKey:@"shake"];
    }
}
@end
