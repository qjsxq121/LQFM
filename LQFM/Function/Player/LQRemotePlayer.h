//
//  LQRemotePlayer.h
//  LQFM
//
//  Created by lq on 2020/4/13.
//  Copyright © 2020 JC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 播放器的状态
 * 因为UI界面需要加载状态显示, 所以需要提供加载状态
 - XMGRemotePlayerStateUnknown: 未知(比如都没有开始播放音乐)
 - XMGRemotePlayerStateLoading: 正在加载()
 - XMGRemotePlayerStatePlaying: 正在播放
 - XMGRemotePlayerStateStopped: 停止
 - XMGRemotePlayerStatePause:   暂停
 - XMGRemotePlayerStateFailed:  失败(比如没有网络缓存失败, 地址找不到)
 */
typedef NS_ENUM(NSInteger, LQRemotePlayerState) {
    LQRemotePlayerStateUnknown = 0,
    LQRemotePlayerStateLoading   = 1,
    LQRemotePlayerStatePlaying   = 2,
    LQRemotePlayerStateStopped   = 3,
    LQRemotePlayerStatePause     = 4,
    LQRemotePlayerStateFailed    = 5
};
@interface LQRemotePlayer : NSObject

+ (instancetype)share;
- (void)playWithURL:(NSURL *)url;


/// 拖拽快进
/// @param progress  进度
- (void)seekWithProgress:(float)progress;


/// 快进多少秒
/// @param timeDiffer 秒
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;


// 设置速率
- (void)setRate:(float)rate;

// 是否静音
- (void)setMuted:(BOOL)muted;

- (void)setVolume:(float)volume;

// 暂停
- (void)pause;

// 继续
- (void)resume;
// 停止
- (void)stop;


#pragma mark -- 数据提供
// 推模式
// 拉模式
/** 静音 */
@property (nonatomic, assign) BOOL muted;

/** 声音 */
@property (nonatomic, assign) float volume;

/** 速率 */
@property (nonatomic, assign) float rate;

/** 总时长 */
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;

/** 总时间 */
@property (nonatomic, copy, readonly) NSString *totalTimeFormat;

/** 当前时长 */
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;

/** 当前播放的时间 */
@property (nonatomic, copy, readonly) NSString *currentTimeFormat;

/** 进度 */
@property (nonatomic, assign, readonly) float progress;
/** 地址 */
@property (nonatomic, assign, readonly) NSURL *url;
/** 加载进度 */
@property (nonatomic, assign, readonly) float loadDataProgress;

/** 状态 */
@property (nonatomic, assign) LQRemotePlayerState state;


@end

NS_ASSUME_NONNULL_END
