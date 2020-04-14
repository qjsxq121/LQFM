//
//  ViewController.m
//  LQFM
//
//  Created by lq on 2020/4/13.
//  Copyright © 2020 JC. All rights reserved.
//

#import "ViewController.h"
#import "LQRemotePlayer.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)playAction:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
    [[LQRemotePlayer share] playWithURL:url];
    
}

- (IBAction)puseAction:(UIButton *)sender {
    [[LQRemotePlayer share] pause];
}
- (IBAction)resume:(UIButton *)sender {
    [[LQRemotePlayer share] resume];
}
- (IBAction)seekWithProgress:(UISlider *)sender {
    [[LQRemotePlayer share] seekWithProgress:sender.value];
}

- (IBAction)rate:(UIButton *)sender {
    [[LQRemotePlayer share] setRate:1.5];
}
- (IBAction)setMuted:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[LQRemotePlayer share] setMuted:sender.selected];
}
- (IBAction)setVolume:(UISlider *)sender {
    [[LQRemotePlayer share] setVolume:sender.value];
}
- (IBAction)seekWithDiffer:(UIButton *)sender {
    [[LQRemotePlayer share] seekWithTimeDiffer:15];
}


@end
