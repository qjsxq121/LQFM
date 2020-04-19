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
{
    BOOL _isUserPause; // 是否是用户主动停止
}
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
    NSURL *currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([url isEqual:currentURL]) {
        NSLog(@"当前播放任务已经存在");
        [self resume];
        return;
    }
    // 创建一个播放器对象
    // 步骤：
    //1 资源的请求
    //2 资源的组织
    //3 给播放器， 资源的播放
    
    // 如果资源加载比较慢，有可能，会造成调用了paly方法
    // 但是当前并没有播放音频
    
    _url = url;
    
    if (self.player.currentItem) {
        [self removeObserver];
    }
    //1 资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    // 2 资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];

    // 当前资源的组织者，告诉我们资源准备好了之后，我们再播放
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    // 播放结束的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // 播放被打断的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
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
    _isUserPause = YES;
    if (self.player) {
        self.state = LQRemotePlayerStatePause;
    }
}
- (void)resume {
    [self.player play];
    _isUserPause = NO;
    // 就是代表，当前播放器存在，并且 数据组织者里面的数据准备，已经足够播放了
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.state = LQRemotePlayerStatePlaying;
    }
}
- (void)stop {
    [self.player pause];
    self.player = nil;
    if (self.player) {
        self.state = LQRemotePlayerStateStopped;
    }
}
// 移除监听
- (void)removeObserver {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}



#pragma mark -- 数据 事件
- (float)rate {
    return self.player.rate;
}
// 设置速率
- (void)setRate:(float)rate {
    [self.player setRate:rate];
}

- (BOOL)muted {
    return self.player.muted;
}
// 是否静音
- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (float)volume {
    return self.player.volume;
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

- (NSString *)currentTimeFormat {
    return [NSString stringWithFormat:@"%2f:%2zd",(int)self.currentTime / 60,(int)self.currentTime % 60];
}

- (NSString *)totalTimeFormat {
    return [NSString stringWithFormat:@"%2zd:%2zd",(int)self.totalTime / 60,(int)self.totalTime % 60];
}

-(NSTimeInterval)totalTime {
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);
    if (isnan(totalTimeSec)) {
        return 0;
    }
    return totalTimeSec;
}

- (NSTimeInterval)currentTime {
    CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    if (isnan(playTimeSec)) {
        return 0;
    }
    return playTimeSec;
}

- (float)progress {
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime / self.totalTime;
}

- (float)loadDataProgress {
    if (self.totalTime == 0) {
        return 0;
    }
    CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
       
       CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
       NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
       
       return loadTimeSec / self.totalTime;
}

- (void)setState:(LQRemotePlayerState)state {
    _state = state;
    // 如果需要告诉外界相关事件
    // block
    // 代理
    // 通知
}
// 播放结束
- (void)playEnd {
    NSLog(@"播放完成");
    self.state = LQRemotePlayerStateStopped;
    
}

- (void)playInterupt {
    // 来电话，资源加载跟不上
    NSLog(@"播放被打断");
    self.state = LQRemotePlayerStatePause;
}
#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了，可以播放");
            [self resume];
        } else {
            NSLog(@"状态未知");
            self.state = LQRemotePlayerStateFailed;
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
         BOOL ptk = [change[NSKeyValueChangeNewKey] boolValue];
                if (ptk) {
                    NSLog(@"当前的资源, 准备的已经足够播放了");
        //
                    // 用户的手动暂停的优先级最高
                    if (!_isUserPause) {
                        [self resume];
                    }else {
                        
                    }
                    
                }else {
                    NSLog(@"资源还不够, 正在加载过程当中");
                    self.state = LQRemotePlayerStateLoading;
                }
    }
}


@end
