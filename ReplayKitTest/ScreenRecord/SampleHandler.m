//
//  SampleHandler.m
//  ScreenRecord
//
//  Created by yfm on 2020/9/7.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//


#import "SampleHandler.h"
#import "ZFUploadTool.h"
#import "ZYFaceTrack.h"
#import <CoreFoundation/CoreFoundation.h>

static int jump = 0;
BOOL getSize = NO;

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // 用户已请求开始广播。可以提供来自UI扩展程序的设置信息，是可选的
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
//    NSLog(@"%s", __func__);
    
    NSLog(@"extention pid %d", getpid());
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.yes.GanodermaDiagnosis"];
    [shared setObject:@"test value" forKey:@"test"];
    [shared synchronize];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),CFSTR("broadcastStarted"),NULL,nil,YES);
}

- (void)broadcastPaused {
   /*
    CF_EXPORT void CFNotificationCenterPostNotification(CFNotificationCenterRef center, CFNotificationName name, const void *object, CFDictionaryRef userInfo, Boolean deliverImmediately);
    */
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),CFSTR("broadcastPaused"),NULL,nil,YES);
    // 暂停广播
    // User has requested to pause the broadcast. Samples will stop being delivered.
//    NSLog(@"%s", __func__);
}

- (void)broadcastResumed {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),CFSTR("broadcastResumed"),NULL,nil,YES);
    // 恢复广播
    // User has requested to resume the broadcast. Samples delivery will resume.
//    NSLog(@"%s", __func__);
}

- (void)broadcastFinished {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),CFSTR("broadcastFinished"),NULL,nil,YES);
    // 广播完成
    // User has requested to finish the broadcast.
//    NSLog(@"%s", __func__);
}

/**
 实时获取视频和音频流数据，73帧左右/每秒
 */
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),CFSTR("processSampleBuffer"),NULL,nil,YES);
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo: {
            
            // Handle video sample buffer
            CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            
            size_t frameW = CVPixelBufferGetWidth(imageBuffer);
            size_t frameH = CVPixelBufferGetHeight(imageBuffer);
            CGSize frameSize = CGSizeMake(frameW, frameH);
            
            if(!getSize) {
                NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.yes.GanodermaDiagnosis"];
                [shared setObject:NSStringFromCGSize(frameSize) forKey:@"frameSize"];
                [shared synchronize];
                getSize = YES;
            }
            
            if(jump++ % 2) {
                [ZFUploadTool.shareTool.faceTrack checkFace:imageBuffer];
            }
            
            // 推流
            [ZFUploadTool.shareTool sendVideoBuffer:sampleBuffer];
        }
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}

@end
