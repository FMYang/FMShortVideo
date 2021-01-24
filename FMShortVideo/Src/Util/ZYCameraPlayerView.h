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
typedef NS_ENUM(NSUInteger, ZYCameraPlayerStatus) {
    // 未知
    ZYCameraPlayerStatus_unKnow,
    // 播放中
    ZYCameraPlayerStatus_playing,
    // 暂停
    ZYCameraPlayerStatus_pause,
    // 播放失败
    ZYCameraPlayerStatus_fail,
    // 播放完成
    ZYCameraPlayerStatus_finished,
};

typedef void(^ZYCameraPlayerTimeDidChanged)(NSTimeInterval currentTime, NSTimeInterval duration);
typedef void(^ZYCameraPlayerBufferTimeDidChanged)(NSTimeInterval bufferTime, NSTimeInterval duration);
typedef void(^ZYCameraPlayerStatusDidChanged)(ZYCameraPlayerStatus status);

@interface ZYCameraPlayerView : UIView

// 视频URL
@property (nonatomic, strong) NSURL *videoUrl;

// urlAsset
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
@property (nonatomic, readonly, assign) ZYCameraPlayerStatus playStatus;

// 监听播放时间
@property (nonatomic, copy) ZYCameraPlayerTimeDidChanged timeDidChanged;

// 缓冲进度改变
@property (nonatomic, copy) ZYCameraPlayerBufferTimeDidChanged bufferTimeDidChanged;

// 播放状态改变
@property (nonatomic, copy) ZYCameraPlayerStatusDidChanged playStatusDidChanged;

// 播放
- (void)play;

// 暂停
- (void)pause;

// 重置播放器
- (void)reset;

- (void)seekToTime:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
