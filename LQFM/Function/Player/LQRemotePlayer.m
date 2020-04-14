//
//  LQRemotePlayer.m
//  LQFM
//
//  Created by lq on 2020/4/13.
//  Copyright © 2020 JC. All rights reserved.
//

#import "LQRemotePlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface LQRemotePlayer ()

/** 播放 */
@property (nonatomic, strong) AVPlayer *player;

@end

static LQRemotePlayer * _instance;
@implementation LQRemotePlayer

+ (instancetype)share {
    if (!_instance) {
        _instance = [[LQRemotePlayer alloc] init];
    }
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (void)playWithURL:(NSURL *)url {
    // 创建一个播放d器对象
    // 步骤：
    //1 资源的请求
    //2 资源的组织
    //3 给播放器， 资源的播放
    
    // 如果资源加载比较慢，有可能，会造成调用了paly方法
    // 但是当前并没有播放音频
    
    //1 资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    // 2 资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];

    // 当前资源的组织者，告诉我们资源准备好了之后，我们再播放
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    self.player = [AVPlayer playerWithPlayerItem:item];
}


- (void)seekWithProgress:(float)progress {
    if (progress < 0 || progress > 1) {
        return;
    }
    // 可以指定时间节点去播放
    // 时间 CMTime : 影片时间
    // 秒 -> 影片时间
    // 影片时间 -> 秒
    // 1 当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    
    
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);
    NSTimeInterval playTimeSec = totalSec * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间i点的音频资源");
        } else {
            NSLog(@"取消加载这个时间点的音频");
        }
    }];
}



- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    // 1 当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);

    // 2. 当前音频, 已经播放的时长
      CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    
    playTimeSec += timeDiffer;
    
    [self seekWithProgress:playTimeSec / totalSec];
    
}


- (void)pause {
    [self.player pause];
}
- (void)resume {
    [self.player play];
}
- (void)stop {
    [self.player pause];
    self.player = nil;
}
// 设置速率
- (void)setRate:(float)rate {
    [self.player setRate:rate];
}

// 是否静音
- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (void)setVolume:(float)volume {
    if (volume < 0 || volume > 1) {
        return;
    }
    
    if (volume > 0) {
        [self setMuted:NO];
    }
    self.player.volume = volume;
}
#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了，可以播放");
            [self.player play];
        } else {
            NSLog(@"状态未知");
        }
    }
}
@end
