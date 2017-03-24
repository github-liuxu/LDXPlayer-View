//
//  LDXPlayer.h
//  LDXPlayer View
//
//  Created by bmd on 2017/3/24.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LDXPlayer : UIView

@property (weak, nonatomic) id delegate;

@property (nonatomic, assign) BOOL isFull;
/**
 *  AVPlayer播放器
 */
@property (nonatomic, strong) AVPlayer *player;
/**
 *  播放状态，YES为正在播放，NO为暂停
 */
@property (nonatomic, assign) BOOL isPlaying;
/**
 *  是否横屏，默认NO -> 竖屏
 */
@property (nonatomic, assign) BOOL isLandscape;
/**
 *  初始化对象
 */
+(instancetype)palyer;

/**
 *  传入视频地址
 *
 *   string 视频url
 */
- (void)updatePlayerWith:(NSURL *)url;

/**
 *  移除通知&KVO
 */
- (void)removeObserverAndNotification;

/**
 *  播放
 */
- (void)play;

/**
 *  暂停
 */
- (void)pause;
/**
 *  设置原始frame的大小
 */
- (void)setOldFrame:(CGRect)rect;
@end
