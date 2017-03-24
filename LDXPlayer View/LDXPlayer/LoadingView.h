//
//  LoadingView.h
//  NvSellerShow
//
//  Created by bmd on 2017/3/21.
//  Copyright © 2017年 Meicam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (strong, nonatomic) UIImageView *imageView;

//是否停止旋转
@property (assign, nonatomic) BOOL isStop;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)run;
- (void)stop;

- (void)showErrorImage;
- (void)dismissErrorImage;

@end
