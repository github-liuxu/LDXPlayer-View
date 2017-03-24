//
//  LoadingView.m
//  NvSellerShow
//
//  Created by bmd on 2017/3/21.
//  Copyright © 2017年 Meicam. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView()

@property (assign, nonatomic) double angle;

@end

@implementation LoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isStop = YES;
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"player_loading"]];
        self.imageView.frame = CGRectMake((self.frame.size.width-48)/2, (self.frame.size.height-48)/2, 48, 48);
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)run {
    self.isStop = NO;
    self.imageView.hidden = NO;

    //创建一个CGAffineTransform  transform对象
    CGAffineTransform transform;
    //设置旋转度数
    transform = CGAffineTransformMakeRotation(self.angle * (M_PI/180.0f));
    //动画开始
    [UIView beginAnimations:@"rotate" context:nil];
    //动画时常
    [UIView setAnimationDuration:0.03];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(end)];
    //获取transform的值
    [self.imageView setTransform:transform];
    //关闭动画
    [UIView commitAnimations];
}

- (void)stop {
    self.isStop = YES;
    self.imageView.hidden = YES;
    self.angle = 0;
}

- (void)end {
    if (self.isStop) {
        return;
    }else{
        self.angle += 10;
        [self run];
    }
}

- (void)showErrorImage {
    [self stop];
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.hidden = NO;
    self.imageView.image = [UIImage imageNamed:@"player_loadfail"];
}

- (void)dismissErrorImage {
    self.imageView.image = [UIImage imageNamed:@"player_loading"];
    self.imageView.hidden = YES;
}

@end
