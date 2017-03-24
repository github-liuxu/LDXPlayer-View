//
//  LDXPlayer.m
//  LDXPlayer View
//
//  Created by bmd on 2017/3/24.
//  Copyright © 2017年 刘东旭. All rights reserved.
//
#define WeakSealf(weakself) __weak typeof(self) weakself = self;
#import "LDXPlayer.h"
#import "LoadingView.h"
@interface LDXPlayer()
{
    BOOL isIntoBackground;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    id _playTimeObserver; // 播放进度观察者
    CGFloat windowLevel;
    
}
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property(nonatomic,assign)CGRect oldFrame;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *fullButton;
@property (nonatomic, strong) UILabel *currentTime;
@property (nonatomic, strong) UILabel *totalTime;
@property (nonatomic, strong) UIProgressView *bufferViewProgress;
@property (nonatomic, strong) UISlider *playSliderProgress;
@property (nonatomic, strong) LoadingView *loadingView;

@end
@implementation LDXPlayer

+(instancetype)palyer {
    return [[[NSBundle mainBundle] loadNibNamed:@"LDXPlayer" owner:self options:nil] firstObject];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setUp];

}

- (void)setOldFrame:(CGRect)rect {
    _oldFrame = rect;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self=[[[NSBundle mainBundle] loadNibNamed:@"JWPlayer" owner:self options:nil] firstObject];
        self.frame=frame;
        _oldFrame=frame;
        [self setUp];
    }
     return self;
}

- (void)setUp {
    self.player = [[AVPlayer alloc] init];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [self.playerView.layer addSublayer:_playerLayer];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake(0, self.frame.size.height-44, 44, 44);
    [self.playButton setImage:[UIImage imageNamed:@"player_stop"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    
    self.fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullButton.frame = CGRectMake(self.frame.size.width-44, self.frame.size.height-44, 44, 44);
    [self.fullButton setImage:[UIImage imageNamed:@"player_half"] forState:UIControlStateNormal];
    [self.fullButton setImage:[UIImage imageNamed:@"player_full"] forState:UIControlStateSelected];
    [self addSubview:self.fullButton];
    [self.fullButton addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentTime = [[UILabel alloc] initWithFrame:CGRectMake(self.playButton.frame.origin.x+self.playButton.frame.size.width+8, self.frame.size.height-44, 44, 44)];
    self.currentTime.textAlignment = NSTextAlignmentCenter;
    self.currentTime.textColor = [UIColor whiteColor];
    [self addSubview:self.currentTime];
    
    self.totalTime = [[UILabel alloc] initWithFrame:CGRectMake(self.fullButton.frame.origin.x - 50, self.frame.size.height-44, 44, 44)];
    self.totalTime.textAlignment = NSTextAlignmentCenter;
    self.totalTime.textColor = [UIColor whiteColor];
    self.totalTime.text = @"00:00";
    [self addSubview:self.totalTime];
    
    self.bufferViewProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(self.currentTime.frame.origin.x+self.currentTime.frame.size.width + 8, self.frame.size.height-22, self.frame.size.width-(self.currentTime.frame.origin.x+self.currentTime.frame.size.width)-8-self.totalTime.frame.size.width-8-self.fullButton.frame.size.width-8, 1)];
    self.bufferViewProgress.tintColor = [UIColor whiteColor];
    [self addSubview:self.bufferViewProgress];
    
    self.playSliderProgress = [[UISlider alloc] initWithFrame:CGRectMake(self.currentTime.frame.origin.x+self.currentTime.frame.size.width + 8, self.frame.size.height-44, self.frame.size.width-(self.currentTime.frame.origin.x+self.currentTime.frame.size.width)-8-self.totalTime.frame.size.width-8-self.fullButton.frame.size.width-8, 31)];
    self.playSliderProgress.center = self.bufferViewProgress.center;
    [self.playSliderProgress setThumbImage:[UIImage imageNamed:@"player_slide"] forState:UIControlStateNormal];
    [self.playSliderProgress addTarget:self action:@selector(sliderChange) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.playSliderProgress];
    
    self.loadingView = [[LoadingView alloc] initWithFrame:CGRectMake((self.playerView.frame.size.width-48)/2, (self.playerView.frame.size.height-48)/2, 48, 48)];
    [self addSubview:self.loadingView];
    [self.loadingView run];
    
    [self setPortraitLayout];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    windowLevel = window.windowLevel;
}

- (void)sliderChange {
    [self pause];
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(self.playSliderProgress.value, 1);
    [_playerItem seekToTime:dragedCMTime];
}

- (void)playOrPause {
    if (_isPlaying) {
        [self pause];
    }else{
        [self play];
    }
}

- (void)fullScreen {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (_isFull) {
        window.windowLevel = windowLevel;
        //创建一个CGAffineTransform  transform对象
        CGAffineTransform  transform;
        //设置旋转度数
        transform = CGAffineTransformRotate(self.transform,-M_PI/2.0);
        //动画开始
        [UIView beginAnimations:@"rotate" context:nil];
        //动画时常
        [UIView setAnimationDuration:0.5];
        //获取transform的值
        [self setTransform:transform];
        //关闭动画
        [UIView commitAnimations];
        [self setPortraitLayout];
        _isFull=NO;
        
    }else{
        window.windowLevel = UIWindowLevelStatusBar + 1;
        
        //创建一个CGAffineTransform  transform对象
        CGAffineTransform  transform;
        //设置旋转度数
        transform = CGAffineTransformRotate(self.transform,M_PI/2.0);
        //动画开始
        [UIView beginAnimations:@"rotate" context:nil];
        //动画时常
        [UIView setAnimationDuration:0.5];
        //获取transform的值
        [self setTransform:transform];
        //关闭动画
        [UIView commitAnimations];
        [self setlandscapeLayout];
        _isFull=YES;
    }
//    [self.viewController setNeedsStatusBarAppearanceUpdate];
}

// 后台
- (void)resignActiveNotification{
    NSLog(@"进入后台");
    isIntoBackground = YES;
    [self pause];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.playerView.frame = self.bounds;
    _playerLayer.frame = self.bounds;
    
    self.loadingView.frame = CGRectMake((self.playerView.frame.size.width-48)/2, (self.playerView.frame.size.height-48)/2, 48, 48);
    
    self.playButton.frame = CGRectMake(0, self.playerView.frame.size.height-44, 44, 44);
    self.fullButton.frame = CGRectMake(self.playerView.frame.size.width-44, self.playerView.frame.size.height-44, 44, 44);
    self.currentTime.frame = CGRectMake(self.playButton.frame.origin.x+self.playButton.frame.size.width+8, self.playerView.frame.size.height-44, 48, 44);
    self.totalTime.frame = CGRectMake(self.fullButton.frame.origin.x-56, self.playerView.frame.size.height-44, 48, 44);
    self.bufferViewProgress.frame = CGRectMake(self.currentTime.frame.origin.x+self.currentTime.frame.size.width + 10, self.playerView.frame.size.height-21, self.playerView.frame.size.width-(self.currentTime.frame.origin.x+self.currentTime.frame.size.width)-8-self.totalTime.frame.size.width-8-self.fullButton.frame.size.width-8-4, 1);
    self.playSliderProgress.frame = CGRectMake(self.currentTime.frame.origin.x+self.currentTime.frame.size.width + 8, self.playerView.frame.size.height-35, self.playerView.frame.size.width-(self.currentTime.frame.origin.x+self.currentTime.frame.size.width)-8-self.totalTime.frame.size.width-8-self.fullButton.frame.size.width-8, 30);
}
- (void)updatePlayerWith:(NSURL *)url{
    if (_playerItem) {
        [self removeObserverAndNotification];
    }
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    _playerItem.seekingWaitsForVideoCompositionRendering = YES;
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
    [self addObserverAndNotification];
    [self.loadingView run];
}

- (void)addObserverAndNotification{
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听缓冲进度
    [self monitoringPlayback:_playerItem];// 监听播放状态
    [self addNotification];
}

-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    _playerItem = [notification object];
    [_playerItem seekToTime:kCMTimeZero];
    [self pause];
}

#pragma mark - KVO - status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (isIntoBackground) {
            return;
        }else{
            if ([item status] == AVPlayerStatusReadyToPlay) {
                NSLog(@"AVPlayerStatusReadyToPlay");
                CMTime duration = item.duration;// 获取视频总长度
                NSLog(@"%f", CMTimeGetSeconds(duration));
                [self setMaxDuratuin:CMTimeGetSeconds(duration)];
                [self play];
                [self.loadingView stop];
            }else if([item status] == AVPlayerStatusFailed) {
                NSLog(@"AVPlayerStatusFailed");
                [self.loadingView showErrorImage];
            }else{
                NSLog(@"AVPlayerStatusUnknown");
                [self.loadingView showErrorImage];
            }
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSTimeInterval timeInterval = [self availableDurationRanges];//缓冲进度
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        self.lastTime = totalDuration;
        [self.bufferViewProgress setProgress: timeInterval / totalDuration animated:YES];
    }else if (object == _playerItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (_playerItem.playbackBufferEmpty) {
            //Your code here
            NSLog(@"bufer Empty---");
        }
    }
    
    else if (object == _playerItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (_playerItem.playbackLikelyToKeepUp)
        {
            //Your code here
            NSLog(@"keep up");

        }
    }

}

- (NSTimeInterval)availableDurationRanges {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
#pragma mark - 移除通知&KVO
- (void)removeObserverAndNotification{
    NSLog(@"开始清除KVO和通知");
    [_player replaceCurrentItemWithPlayerItem:nil];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_player removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMaxDuratuin:(float)total{
    self.playSliderProgress.maximumValue = total;
    self.totalTime.text = [self convertTime:self.playSliderProgress.maximumValue];
}

#pragma mark - _playTimeObserver
- (void)monitoringPlayback:(AVPlayerItem *)item {
    WeakSealf(ws);
    //这里设置每秒执行30次
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {

            // 计算当前在第几秒
            float currentPlayTime = (double)item.currentTime.value/item.currentTime.timescale;
            [ws updateVideoSlider:currentPlayTime];
    }];
}

- (void)updateVideoSlider:(float)currentTime{
    self.playSliderProgress.value = currentTime;
    self.currentTime.text = [self convertTime:currentTime];
}

- (void)setlandscapeLayout{
    self.isLandscape = YES;
    self.frame=[UIScreen mainScreen].bounds;
    [self.fullButton setImage:[UIImage imageNamed:@"player_half"] forState:UIControlStateNormal];
}

- (void)setPortraitLayout{
    self.isLandscape = NO;
    self.frame=_oldFrame;
    [self.fullButton setImage:[UIImage imageNamed:@"player_full"] forState:UIControlStateNormal];
}

- (void)play{
    _isPlaying = YES;
    [_player play];
    [self.playButton  setImage:[UIImage imageNamed:@"player_stop"] forState:UIControlStateNormal];
}


- (void)pause{
    _isPlaying = NO;
    [_player pause];
    [self.playButton  setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

-(UIViewController *)viewController {
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        } else {
            next = next.nextResponder;
        }
    } while (next);
    return nil;
}

- (void)dealloc
{
    [self removeObserverAndNotification];
    NSLog(@"播放器释放");
}

@end
