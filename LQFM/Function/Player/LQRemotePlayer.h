//
//  LQRemotePlayer.h
//  LQFM
//
//  Created by lq on 2020/4/13.
//  Copyright © 2020 JC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
@end

NS_ASSUME_NONNULL_END
