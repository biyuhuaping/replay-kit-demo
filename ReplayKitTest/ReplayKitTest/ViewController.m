//
//  ViewController.m
//  ReplayKitTest
//
//  Created by yfm on 2020/9/7.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>
#import <ZYCodeTools/ZYDeviceManager.h>
#import <ZYImageTools/ZYMovingTracker.h>

@interface ViewController () <RPBroadcastActivityViewControllerDelegate>
@property (nonatomic) RPSystemBroadcastPickerView *broadPickerView;
@property (nonatomic) RPBroadcastController *broadcastController;

@property (strong, nonatomic) ZYMovingTracker* tracker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tracker start];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self addNotification];
    [self start];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 40)];
    [btn setTitle:@"Stop" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(stopScreenRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [ZYDeviceManager.defaultManager scanStabalizerDevice:^(ZYBleState state) {
        
    } deviceHandler:^(ZYDeviceStabilizer *deviceInfo) {
        NSLog(@"%@", deviceInfo.deviceName);
        if([deviceInfo.deviceName containsString:@"SMOOTH-X_3AE8"]) {
            [ZYDeviceManager.defaultManager stopScan];
            [ZYDeviceManager.defaultManager connectDevice:deviceInfo completionHandler:^(ZYBleDeviceConnectionState state) {
                if(state == ZYBleDeviceStateConnected) {
                    NSLog(@"设备已经连接");
                }
            }];
        }
    }];
}

- (void)stopScreenRecord {
//    for(UIView *view in self.broadPickerView.subviews) {
//        if([view isKindOfClass:[UIButton class]]) {
//            UIButton *btn = (UIButton *)view;
//            [btn sendActionsForControlEvents:UIControlEventAllEvents];
//        }
//    }
    
//    [[RPScreenRecorder sharedRecorder] stopCaptureWithHandler:nil];
    
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        
    }];

}

- (void)addNotification {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), observerMethod, CFSTR("broadcastStarted"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

     CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), observerMethod, CFSTR("broadcastPaused"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), observerMethod, CFSTR("broadcastResumed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), observerMethod, CFSTR("broadcastFinished"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), observerMethod, CFSTR("processSampleBuffer"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

void observerMethod(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString *notiName = (__bridge NSString *)name;
    if([notiName isEqualToString:@"broadcastPaused"]) {
        NSLog(@"录屏暂停");
    } else if([notiName isEqualToString:@"broadcastResumed"]) {
        NSLog(@"录屏复用");
    } else if([notiName isEqualToString:@"broadcastFinished"]) {
        NSLog(@"录屏完成");
    } else if([notiName isEqualToString:@"broadcastStarted"]) {
        NSLog(@"录屏开始");
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.zhiyun.ZYReplayKitGroup"];
        NSLog(@"%@", [shared objectForKey:@"test"]);
    } else if([notiName isEqualToString:@"processSampleBuffer"]) {
        NSLog(@"processSampleBuffer");
        
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.zhiyun.ZYReplayKitGroup"];
        NSString *faceInfo = [shared objectForKey:@"faceInfo"];
        NSString *frameSize = [shared objectForKey:@"frameSize"];
        CGRect faceRect = CGRectFromString(faceInfo);
        CGSize srcSize = CGSizeFromString(frameSize);
        
        if(faceInfo.length > 0) {
            ViewController *vc = (__bridge ViewController *)observer;
            CGRect newRect = [vc coverFrame:faceRect srcSize:srcSize];
            [vc moveStabilizer:newRect.origin srcSize:srcSize];
        } else {
            [[ZYDeviceManager defaultManager].stablizerDevice.motionManager cancelMove];
        }
    }
}

- (CGRect)coverFrame:(CGRect)faceRect srcSize:(CGSize)srcSize {
    CGRect returnRect = CGRectZero;
    
    CGFloat faceCenterX = faceRect.origin.x + faceRect.size.width * 0.5;
    CGFloat faceCenterY = faceRect.origin.y + faceRect.size.height * 0.5;
    
    returnRect = CGRectMake(faceCenterX, faceCenterY, faceRect.size.width, faceRect.size.height);
    
    return returnRect;
}

- (BOOL)systemVersionIsAvailable {
    NSString *version = [UIDevice currentDevice].systemVersion;
    //可用的判断是在9.0之后，只需要判断这个即可
    if ([version doubleValue] >= 12.0) {
        return YES;
    }
    return NO;
}

// 全局系统录屏
- (void)start {
    if([self systemVersionIsAvailable]) {
        _broadPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        _broadPickerView.preferredExtension = @"com.zhiyun.ZYLive.ScreenRecord";
        [self.view addSubview:_broadPickerView];
    } else {
        NSLog(@"iOS11的系统需要手动选择扩展程序启动，iOS11以下不支持");
    }
}

/// ======================= test ====================
// 应用内录屏
- (void)startRecordInApp {
//    [RPScreenRecorder.sharedRecorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
//        NSLog(@"CMSampleBufferRef");
//    } completionHandler:^(NSError * _Nullable error) {
//        NSLog(@"%@", error);
//    }];
    
//    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
//        broadcastActivityViewController.delegate = self;
//        [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
//    }];
    
//    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithPreferredExtension:@"com.zhiyun.ZYLive.ScreenRecord" handler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
//        broadcastActivityViewController.delegate = self;
//        [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
//    }];
}

- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error API_AVAILABLE(ios(10.0), tvos(10.0)) {
    self.broadcastController = broadcastController;
    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/// ===========================================

- (void)moveStabilizer:(CGPoint)point srcSize:(CGSize)srcSize {
    if ([[ZYDeviceManager defaultManager].stablizerDevice newtrackingCodeSupport]) {
        float yawT = point.x * 1000; // 航向轴
        if(yawT > 1000) {
            yawT = 1000.0;
        }
        if(yawT < 0) {
            yawT = 0.0;
        }
        yawT = 1000 - yawT;
        
        // 全锁定模式才能跟踪
        [[ZYDeviceManager defaultManager].stablizerDevice.motionManager tracckMove:500 yaw:yawT compeletion:^(BOOL success) {
            
        }];
    }
}

- (ZYMovingTracker *)tracker{
    if (_tracker == nil) {
        _tracker = [[ZYMovingTracker alloc] init];
        _tracker.fps = 15;
        _tracker.asyn = NO;
        _tracker.type = 1;
    }

    return _tracker;
}

@end
