//
//  ZYDeviceStabilizer+BodySensation.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/8/19.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceStabilizer+BodySensation.h"

@implementation ZYDeviceStabilizer (BodySensation)

/**
 读取体感的 平滑度 和 最大速度

 @param direction 方向
 @param completionHandler 回调
 */
-(void)readSomatosenoryAndMaximumSpeedByStabilizerDirection:(ZYStabilizeAxis )direction  completionHandler:(void(^)(BOOL success,short somatosenory,short maximumSpeed))completionHandler{
    if (!completionHandler) {
        return;
    }
    ZYBleInteractCode code  ;
    switch (direction) {
        case ZYStabilizeAxis_Pitch:
            code = ZYBlePitchSomatosensoryControl_R;
            break;

        case ZYStabilizeAxis_Roll:
            code = ZYBleRollSomatosensoryControl_R;
            break;

        case ZYStabilizeAxis_Yaw:
            code = ZYBleYawSomatosensoryControl_R;
            break;

        default:
            break;
    }
    [self sendRequestCode:code completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        BOOL success =(state == ZYBleDeviceRequestStateResponse);
        if (success) {
            completionHandler(YES, (param >> 8), (param & 0x00ff));
        } else {
            completionHandler(NO,0,0);
        }
    }];
}

static NSUInteger ZYAxisAngleValue_Useless = 1000;
- (void)getMotionSpeedAndSmoothWithComplete:(void (^)(BOOL success, _Nullable id info))complete{
    if (!complete) {
        return;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block NSUInteger smooth_pitch = ZYAxisAngleValue_Useless;
    __block NSUInteger smooth_roll = ZYAxisAngleValue_Useless;
    __block NSUInteger smooth_yaw = ZYAxisAngleValue_Useless;
    
    __block NSUInteger speed_pitch = ZYAxisAngleValue_Useless;
    __block NSUInteger speed_roll = ZYAxisAngleValue_Useless;
    __block NSUInteger speed_yaw = ZYAxisAngleValue_Useless;
    dispatch_group_async(group, queue, ^{
        [self readSomatosenoryAndMaximumSpeedByStabilizerDirection:ZYStabilizeAxis_Pitch completionHandler:^(BOOL success, short smooth, short speed) {
            if (success) {
                smooth_pitch = smooth;
                speed_pitch = speed;
            }
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_group_async(group, queue, ^{
        [self readSomatosenoryAndMaximumSpeedByStabilizerDirection:ZYStabilizeAxis_Roll completionHandler:^(BOOL success, short smooth, short speed) {
            if (success) {
                smooth_roll = smooth;
                speed_roll = speed;
            }
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_group_async(group, queue, ^{
        [self readSomatosenoryAndMaximumSpeedByStabilizerDirection:ZYStabilizeAxis_Yaw completionHandler:^(BOOL success, short smooth, short speed) {
            if (success) {
                smooth_yaw = smooth;
                speed_yaw = speed;
            }
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_group_notify(group, queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if ((smooth_pitch == ZYAxisAngleValue_Useless) ||
            (smooth_roll == ZYAxisAngleValue_Useless) ||
            (smooth_yaw == ZYAxisAngleValue_Useless) ||
            (speed_pitch == ZYAxisAngleValue_Useless) ||
            (speed_roll == ZYAxisAngleValue_Useless) ||
            (speed_yaw == ZYAxisAngleValue_Useless)) {
            complete(NO, nil);
            return;
        }
        NSMutableDictionary *retInfo = @{}.mutableCopy;
        retInfo[@"smooth_pitch"] = @(smooth_pitch);
        retInfo[@"smooth_roll"] = @(smooth_roll);
        retInfo[@"smooth_yaw"] = @(smooth_yaw);
        retInfo[@"speed_pitch"] = @(speed_pitch);
        retInfo[@"speed_roll"] = @(speed_roll);
        retInfo[@"speed_yaw"] = @(speed_yaw);
        complete(YES, retInfo);
    });
}


/**
 写入体感的 平滑度 和 最大速度

 @param somatosenory 平滑度
 @param maxSpeed 最大速度
 @param direction 方向
 @param completionHandler 回调
 */
//-(void)WriteBodySensationBySomatosenory:(short)somatosenory maximumSpeed:(short)maxSpeed direction:(ZYStabilizeAxis )direction  completionHandler:(void (^)(ZYBleDeviceRequestState state, NSUInteger param,short somatosenory,short maximumSpeed))completionHandler{
//    ZYBleInteractCode code  ;
//
//    switch (direction) {
//        case ZYStabilizeAxis_Pitch:
//            code = ZYBlePitchSomatosensoryControl_W;
//            break;
//
//        case ZYStabilizeAxis_Roll:
//            code = ZYBleRollSomatosensoryControl_W;
//            break;
//
//        case ZYStabilizeAxis_Yaw:
//            code = ZYBleYawSomatosensoryControl_W;
//            break;
//
//        default:
//            BLOCK_EXEC(completionHandler,ZYBleDeviceRequestStateFail,0,somatosenory,maxSpeed);
//            return;
//            break;
//    }
//    short value = (somatosenory << 8) | maxSpeed;
//
//    [self sendRequestCode:code data:@(value) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
//        if (state == ZYBleDeviceRequestStateFail || state == ZYBleDeviceRequestStateTimeout) {
//            BLOCK_EXEC(completionHandler,state,param,somatosenory,maxSpeed);
//
//        }else if (state == ZYBleDeviceRequestStateResponse ){
//            BLOCK_EXEC(completionHandler,state,param,somatosenory, maxSpeed);
//        }
//    }];
//}

- (void)setMotionSpeedAndSmooth:(NSArray <NSDictionary *>*)requestArray complete:(void (^)(BOOL success))complete{
    if (!complete) {
        return;
    }
    if (!requestArray ||(requestArray.count == 0)) {
        complete(NO);
        return;
    }
    NSDictionary *codeDict = @{@"pitch":@(ZYBlePitchSomatosensoryControl_W),
                               @"roll":@(ZYBleRollSomatosensoryControl_W),
                               @"yaw":@(ZYBleYawSomatosensoryControl_W)};
    NSMutableArray *requests = @[].mutableCopy;
    // 开始组装指令对象
    for (NSInteger idx = 0; idx < requestArray.count; idx++) {
        NSDictionary *infoDict = requestArray[idx];
        NSString *axisName = [infoDict objectForKey:@"axis"];
        if (axisName && [codeDict.allKeys containsObject:axisName]) {
            NSUInteger codeValue = [codeDict[axisName] unsignedIntegerValue];
            NSUInteger speed = [infoDict[@"speed"] unsignedIntegerValue];
            NSUInteger smooth = [infoDict[@"smooth"] unsignedIntegerValue];
            NSUInteger value = ((smooth << 8) | speed);
            NSLog(@"体感发送的      平滑度：%lu，速度：%lu，合并的值：%lx", smooth, speed, value);
            ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:codeValue param:@(value)];
            [requests addObject:request];
        }
    }
    if (requests.count == 0) {
        complete(NO);
        return;
    }
    for (ZYBleDeviceRequest *req in requests) {
        [self configRequest:req];
    }
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    [client sendRequests:requests completionHandler:complete];
}

+ (NSDictionary *)formatMotionDict:(ZYStabilizeAxis)axis speed:(NSUInteger)speed smooth:(NSUInteger)smooth{
    NSString *axisName = @"pitch";
    if (axis == ZYStabilizeAxis_Roll) {
        axisName = @"roll";
    } else if (axis == ZYStabilizeAxis_Yaw){
        axisName = @"yaw";
    }
    return @{    @"axis":axisName,
                 @"speed":@(speed),
                 @"smooth":@(smooth)};
}



//
//-(void)readMaximumSpeedByStabilizerDirection:(StabilizerDirection )direction completionHandler:(ZYDeviceRequestResultBlock)completionHandler{
//    ZYBleInteractCode code  ;
//
//    switch (direction) {
//        case StabilizerDirection_Pitch:
//            code = ZYBlePitchSomatosensoryControl_R;
//            break;
//
//        case StabilizerDirection_Roll:
//            code = ZYBleRollSomatosensoryControl_R;
//            break;
//
//        case StabilizerDirection_Yaw:
//            code = ZYBleYawSomatosensoryControl_R;
//            break;
//
//        default:
//            BLOCK_EXEC(completionHandler,ZYBleDeviceStateFail,0);
//            return;
//            break;
//    }
//    [self sendRequestCode:code completionHandler:completionHandler];
//}
//
//-(void)WriteMaximumSpeedByStabilizerDirection:(StabilizerDirection )direction completionHandler:(ZYDeviceRequestResultBlock)completionHandler{
//    ZYBleInteractCode code  ;
//
//    switch (direction) {
//        case StabilizerDirection_Pitch:
//            code = ZYBlePitchSomatosensoryControl_R;
//            break;
//
//        case StabilizerDirection_Roll:
//            code = ZYBleRollSomatosensoryControl_R;
//            break;
//
//        case StabilizerDirection_Yaw:
//            code = ZYBleYawSomatosensoryControl_R;
//            break;
//
//        default:
//            BLOCK_EXEC(completionHandler,ZYBleDeviceRequestStateFail,0);
//            return;
//            break;
//    }
//    [self sendRequestCode:code completionHandler:completionHandler];
//}
@end
