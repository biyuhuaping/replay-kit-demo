//
//  AppDelegate.m
//  ReplayKitTest
//
//  Created by yfm on 2020/9/7.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    ViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"进入后台");
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"com.replayKit.audioPlay" expirationHandler:^{
        NSLog(@"即将结束后台任务");
        [self.audioPlayer play];
        if(self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"回到前台");
    [self.audioPlayer pause];
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
}

- (AVAudioPlayer *)audioPlayer {
    if(!_audioPlayer) {
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"blank" withExtension:@"mp3"];
        NSLog(@"audio file : %@", fileUrl);
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        _audioPlayer.numberOfLoops = NSUIntegerMax;
        _audioPlayer.volume = 0.5;
        [_audioPlayer prepareToPlay];
    }
    return _audioPlayer;
}

@end
