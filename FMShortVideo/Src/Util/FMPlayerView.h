//
//  FMPlayerView.h
//  FMShortVideo
//
//  Created by yfm on 2020/10/20.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

// 播放状态
typedef NS_ENUM(NSUInteger, FMPlayerStatus) {
    // 未知
    FMPlayerStatus_unKnow,
    // 播放中
    FMPlayerStatus_playing,
    // 暂停
    FMPlayerStatus_pause,
    // 播放失败
    FMPlayerStatus_fail,
    // 播放完成
    FMPlayerStatus_finished,
};

typedef void(^FMPlayerStatusTimeDidChanged)(NSTimeInterval currentTime, NSTimeInterval duration);
typedef void(^FMPlayerBufferTimeDidChanged)(NSTimeInterval bufferTime, NSTimeInterval duration);
typedef void(^FMPlayerStatusDidChanged)(FMPlayerStatus status);

@interface FMPlayerView : UIView

@property (nonatomic, strong) AVURLAsset *asset;

// 是否重复播放
@property (nonatomic, assign) BOOL repeat;

// 是否静音
@property (nonatomic, assign) BOOL silenceVolume;

// 音量
@property (nonatomic, assign) CGFloat volume;

// 是否允许tap手势，播放/暂停
@property (nonatomic, assign) BOOL enableTapGesture;

// 是否允许调节播放进度手势
@property (nonatomic, assign) BOOL enablePlayProgressGesture;

// 是否自动播放
@property (nonatomic, assign) BOOL shouldAutoPlay;

// 播放状态
@property (nonatomic, readonly, assign) FMPlayerStatus playStatus;

// 监听播放时间
@property (nonatomic, copy) FMPlayerStatusTimeDidChanged timeDidChanged;

@property (nonatomic, copy) FMPlayerBufferTimeDidChanged bufferTimeDidChanged;

// 播放状态改变
@property (nonatomic, copy) FMPlayerStatusDidChanged playStatusDidChanged;

// 播放
- (void)play;

// 暂停
- (void)pause;

// 重置播放器
- (void)reset;

- (void)seekToTime:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
