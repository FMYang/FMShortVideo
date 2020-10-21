//
//  FMPlayerView.m
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import "FMPlayerView.h"

static const NSString *PlayerItemStatusContext;

typedef NS_ENUM(NSUInteger, ZYPanDirection) {
    ZYPanDirectionHorizontal,
    ZYPanDirectionVertical,
};

// 视频拍摄的方向
typedef NS_ENUM(NSUInteger, ZYVideoOrientation) {
    ZYVideoOrientationPortrait,
    ZYVideoOrientationPortraitUpsideDown,
    ZYVideoOrientationLandscapeLeft,
    ZYVideoOrientationLandscapeRight
};

@interface FMPlayerView() {
    AVURLAsset *_asset;
    AVPlayerItem *_playerItem;
    AVPlayer *_player;
    AVPlayerLayer *_playerLayer;
    
    // 是否第一次播放，防止后台回到前台的时候再次调用播放
    BOOL _isFirstPlay;
}

// 播放状态
@property (nonatomic, assign) FMPlayerStatus playStatus;
// 时间监听器
@property (nonatomic, strong) id timeObserver;
// pan手势方向
@property (nonatomic, assign) ZYPanDirection direction;
// 快进/快退的总时间
@property (nonatomic, assign) NSTimeInterval sumTime;
// 视频时长
@property (nonatomic, assign) NSTimeInterval totalDuration;
// 当前播放时长
@property (nonatomic, assign) NSTimeInterval currentTime;
// pan手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
// tap手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UILabel *failLabel;

@end

@implementation FMPlayerView

#pragma mark - life cycle
- (void)dealloc {
    [self reset];
    [self removeObsever];
}

- (instancetype)init {
    if(self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _playerLayer.frame = self.bounds;
    
//    _indicatorView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
//    [self bringSubviewToFront:self.indicatorView];
}

- (void)commonInit {
    _isFirstPlay = YES;
    
    // 默认自动播放
    self.shouldAutoPlay = YES;
    self.repeat = YES;
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    _tapGesture.enabled = self.enableTapGesture;
    [self addGestureRecognizer:_tapGesture];

    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    _panGesture.enabled = self.enablePlayProgressGesture;
    [self addGestureRecognizer:_panGesture];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView.color = UIColor.redColor;
    [self addSubview:_indicatorView];
    
    [self addNotification];
}

#pragma mark - notification
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)willResignActive {
    [self pause];
}

- (void)didBecomeActive {
    [self play];
}

#pragma mark - setter
- (void)setAsset:(AVURLAsset *)asset {
    if(!asset || asset == _asset) return;
    _asset = asset;
    _isFirstPlay = YES;
    [self reset];
    [self prepareToPlay];
}

- (void)setPlayStatus:(FMPlayerStatus)playStatus {
    _playStatus = playStatus;
    if(self.playStatusDidChanged) {
        self.playStatusDidChanged(playStatus);
    }
}

- (void)setSilenceVolume:(BOOL)silenceVolume {
    _silenceVolume = silenceVolume;
}

- (void)setVolume:(CGFloat)volume {
    _player.volume = volume;
}

// 设置是否允许调节播放进度手势
- (void)setEnablePlayProgressGesture:(BOOL)enablePlayProgressGesture {
    _enablePlayProgressGesture = enablePlayProgressGesture;
    self.panGesture.enabled = enablePlayProgressGesture;
}

- (void)setEnableTapGesture:(BOOL)enableTapGesture {
    _enableTapGesture = enableTapGesture;
    self.tapGesture.enabled = enableTapGesture;
}

#pragma mark - gesture
- (void)tapAction {
    if(self.playStatus == FMPlayerStatus_playing) {
        self.playStatus = FMPlayerStatus_pause;
        [_player pause];
    } else {
        self.playStatus = FMPlayerStatus_playing;
        [_player play];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    // 滑动速率
    CGPoint velocityPoint = [pan velocityInView:self];
    
    CGPoint translationPoint = [pan translationInView:self];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            
            CGFloat x = abs((int)velocityPoint.x);
            CGFloat y = abs((int)velocityPoint.y);
            
            // 判断滑动方向
            if(x > y) {
                self.direction = ZYPanDirectionHorizontal;
            } else {
                self.direction = ZYPanDirectionVertical;
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            if(self.direction == ZYPanDirectionHorizontal) {
                [_player pause];

                CGFloat distance = translationPoint.x;
                CGFloat jumpTime = distance / self.bounds.size.width * self.totalDuration / 4;
                self.sumTime = self.currentTime + jumpTime;
                if(self.sumTime > self.totalDuration) {
                    self.sumTime = self.totalDuration;
                } else if(self.sumTime < 0.0) {
                    self.sumTime = 0.0;
                }
                
                if(self.timeDidChanged) {
                    self.timeDidChanged(self.sumTime, self.totalDuration);
                }
            }
            
        }
            break;
        
        case UIGestureRecognizerStateEnded: {
            if(self.direction == ZYPanDirectionHorizontal) {
                [self seekToTime:self.sumTime completionHandler:^(BOOL finished) {
                    if(finished) {
                        self.playStatus = FMPlayerStatus_pause;
                        [self play];
                    }
                }];
                
                self.sumTime = 0.0;
            }
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"进度改变 %f %f", self.sumTime, self.totalDuration);
}

#pragma mark - player action
- (void)reset {
    [self pause];
    [_asset cancelLoading];
    [self removeObsever];
    _playerItem = nil;
    [_playerLayer removeFromSuperlayer];
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
}
            
- (void)prepareToPlay {
    // 创建AVPlayerItem
    _playerItem = [AVPlayerItem playerItemWithAsset:_asset];
    _playerItem.preferredForwardBufferDuration = 5; // 至少缓存2s后播放
    // 监听播放状态
    [self addObserver];
    // 创建AVPlayer实例
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    // 创建渲染层
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    // 填充屏幕，保持宽高比，超过的部分会被裁剪
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

    [self.layer insertSublayer:_playerLayer atIndex:0];

    if(self.silenceVolume) {
        // 静音
        _player.volume = 0.0;
    } else {
        _player.volume = 4.0;
    }
    
    [self addPlayerItemTimeObserver];
}

- (void)play {
    NSLog(@"fm play");
    if(self.playStatus != FMPlayerStatus_playing) {
        self.playStatus = FMPlayerStatus_playing;
        [_player play];
    }
}

- (void)pause {
    if(self.playStatus == FMPlayerStatus_playing) {
        self.playStatus = FMPlayerStatus_pause;
        [_player pause];
    }
}

- (void)seekToTime:(NSTimeInterval)time {
    [_playerItem cancelPendingSeeks];
    [_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(nullable void (^)(BOOL))completionHandler {
    [_playerItem cancelPendingSeeks];
    [_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:completionHandler];
}

#pragma mark - observer
- (void)addObserver {
    
    // 监听播放状态
    [_playerItem addObserver:self
                  forKeyPath:@"status"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
    
    [_playerItem addObserver:self
                  forKeyPath:@"loadedTimeRanges"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
    
    [_playerItem addObserver:self
                  forKeyPath:@"playbackBufferEmpty"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
    
    [_playerItem addObserver:self
                  forKeyPath:@"playbackLikelyToKeepUp"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
        
    // 监听播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishPlay:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
}

- (void)removeObsever {
    [_playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_playerItem];
    
    [_player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
}

// 监听播放时间
- (void)addPlayerItemTimeObserver {
    // 监听间隔0.5s
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
        
    __weak FMPlayerView *weakSelf = self;
    void (^callback)(CMTime time) = ^(CMTime time) {
        __strong FMPlayerView *strongSelf = weakSelf;
        if(strongSelf) {
            NSTimeInterval currentTime = CMTimeGetSeconds(time);
            NSTimeInterval duration = CMTimeGetSeconds(strongSelf->_playerItem.duration);
            strongSelf.currentTime = currentTime;
            strongSelf.totalDuration = duration;
            NSLog(@"play time changed %f %f", currentTime, duration);
            if(strongSelf.timeDidChanged) {
                strongSelf.timeDidChanged(strongSelf.currentTime, duration);
            }
        }
    };
    
    self.timeObserver = [_player addPeriodicTimeObserverForInterval:interval
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:callback];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if(UIApplication.sharedApplication.applicationState != UIApplicationStateActive) return;

    if([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        NSLog(@"播放状态改变 : %ld", (long)item.status);
        switch (item.status) {
            case AVPlayerItemStatusUnknown:
                self.playStatus = FMPlayerStatus_unKnow;
                break;

            case AVPlayerItemStatusReadyToPlay: {
                [_indicatorView startAnimating];
                if(self.shouldAutoPlay) {
                    if(_isFirstPlay) {
                        [self play];
                        _isFirstPlay = NO;
                    }
                }
            }
                break;

            case AVPlayerItemStatusFailed:
                NSLog(@"加载失败");
                self.playStatus = FMPlayerStatus_fail;
                self.failLabel.hidden = NO;
                break;

            default:
                NSLog(@"未知错误");
                self.playStatus = FMPlayerStatus_unKnow;
                self.failLabel.hidden = NO;
                break;
        }
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSLog(@"缓存中");
        NSArray *timeRanges = [_playerItem loadedTimeRanges];
        // 缓存进度
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        CMTime bufferTime = CMTimeRangeGetEnd(timeRange);
        NSTimeInterval duration = CMTimeGetSeconds(bufferTime);
        NSLog(@"缓冲时间 %f", duration);
        
        if(self.bufferTimeDidChanged) {
            NSTimeInterval duration = CMTimeGetSeconds(_playerItem.duration);
            NSTimeInterval curBufferTime = CMTimeGetSeconds(bufferTime);
            self.bufferTimeDidChanged(curBufferTime, duration);
        }

        NSLog(@"ZF 计算缓存进度 %f", [self availableDuration]);
        
    } else if([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        [_indicatorView startAnimating];
        
        [self pause];
        // 没有声音的情况
        if(_playerItem.isPlaybackLikelyToKeepUp) {
            [self play];
            if(!_playerItem.isPlaybackLikelyToKeepUp) {
                [self pause];
            }
        }
        
        NSLog(@"缓存为空");
    } else if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        [_indicatorView stopAnimating];
        NSLog(@"缓存可以在不停顿的情况下播放了");
        if(_playerItem.isPlaybackLikelyToKeepUp) {
            [self play];
        }
    }
}

/// Calculate buffer progress
- (NSTimeInterval)availableDuration {
    NSArray *timeRangeArray = _playerItem.loadedTimeRanges;
    CMTime currentTime = [_player currentTime];
    BOOL foundRange = NO;
    CMTimeRange aTimeRange = {0};
    if (timeRangeArray.count) {
        aTimeRange = [[timeRangeArray objectAtIndex:0] CMTimeRangeValue];
        if (CMTimeRangeContainsTime(aTimeRange, currentTime)) {
            foundRange = YES;
        }
    }
    
    if (foundRange) {
        CMTime maxTime = CMTimeRangeGetEnd(aTimeRange);
        NSTimeInterval playableDuration = CMTimeGetSeconds(maxTime);
        if (playableDuration > 0) {
            return playableDuration;
        }
    }
    return 0;
}


// 播放完成
- (void)didFinishPlay:(NSNotification *)notify {
    self.playStatus = FMPlayerStatus_finished;
        
    [self seekToTime:0 completionHandler:nil];

    if(self.repeat) {
        // 重复播放
        [self play];
    }
}

- (UILabel *)failLabel {
    if(!_failLabel) {
        _failLabel = [[UILabel alloc] init];
        _failLabel.frame = CGRectMake(20, self.frame.size.height*0.5-10, UIScreen.mainScreen.bounds.size.width-40, 20);
        _failLabel.textColor = UIColor.redColor;
        _failLabel.text = @"加载失败";
        _failLabel.textAlignment = NSTextAlignmentCenter;
        _failLabel.font = [UIFont systemFontOfSize:14];
        _failLabel.hidden = YES;
        [self addSubview:_failLabel];
    }
    return _failLabel;
}

@end
