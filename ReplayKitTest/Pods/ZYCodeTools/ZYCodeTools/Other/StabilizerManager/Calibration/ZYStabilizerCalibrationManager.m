//
//  ZYStabilizerCalibrationManager.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/2/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYStabilizerCalibrationManager.h"
#import "ZYBleDeviceClient.h"
#import "ZYAxisCalibrationLoop.h"
#import "SpaceBlocksHandle.h"

#define BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };
#define BLOCK_EXEC_ON_MAINQUEUE(block, ...) dispatch_async(dispatch_get_main_queue(), ^{ \
    if (block) { block(__VA_ARGS__); }; \
    });

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define kSixSidesCalibration 6

@interface ZYStabilizerCalibrationManager ()

@property (nonatomic, copy)SpaceDelayedBlockHandle delayedBlockHandle;
@property(nonatomic, assign)NSInteger step;
@property(nonatomic, strong)ZYAxisCalibrationLoop *axisCalibrationloop;

@end

@implementation ZYStabilizerCalibrationManager

-(void)setSendDelegate:(id<ZYSendRequest>)sendDelegate{
    self.axisCalibrationloop.sendDelegate = sendDelegate;
    _sendDelegate = sendDelegate;
}


-(instancetype)init{
    if ([super init]) {
        _step = 0;
    }
    return self;
}

-(ZYAxisCalibrationLoop *)axisCalibrationloop{
    
    if (!_axisCalibrationloop) {
        _axisCalibrationloop = [ZYAxisCalibrationLoop new];
    }
    _axisCalibrationloop.axisMapindex = self.step;
    [_axisCalibrationloop closeLoop];
    
    return _axisCalibrationloop;
}

-(void)beginCalibration:(void (^)(void))completed{
    
    @weakify(self)
    [self prepareCalibration:^(BOOL success) {
        @strongify(self)
           [self loopCalibation:^() {
               @strongify(self)
               [self calibrationCompeted:^{
                   BLOCK_EXEC(completed);
               }];
           }];
      }];
}

-(void)prepareCalibration:(void(^)(BOOL success))completed{
    self.step = 0;
    [self endCalibration];
    @weakify(self)
    [self setIMUModel:ZYBleInteractDeviceDebugModeIMUDebug completed:^() {
        @strongify(self)
        [self closeDevceWithCompleted:^() {
            @strongify(self)

            [self clearRegisterCompleted:^() {
                BLOCK_EXEC(completed,YES);
                
            }];
        }];
        
    }];
}

-(void)calibrationCompeted:(void(^)(void))completed{
    @weakify(self)
    [self clearRegisterCompleted:^() {
        @strongify(self)
        [self setIMUModel:ZYBleInteractDeviceDebugModeNormal completed:^(){
            @strongify(self)
            [self saveSettingCompleted:completed];
        }];
    }];
}

-(void)setIMUModel:(ZYBleInteractDeviceDebugMode )model completed:(void(^)(void))completed{
    ZYBleDeviceClient* client = [ZYBleDeviceClient defaultClient];
    __weak ZYBleDeviceDataModel* value = client.dataCache;
    
    @weakify(self)
    [self sendRequest:ZYBleInteractCodeDebug_R completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"读取当前模式 0x%02lx %lu", param, value.debugMode);
            if (value.debugMode != model) {
                [self sendRequest:ZYBleInteractCodeDebug_W data:@(model) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
                    @strongify(self)
                    if (state == ZYBleDeviceRequestStateResponse) {
                        NSLog(@"设置模式 成功");
                        BLOCK_EXEC(completed);

                    }else{
                        NSLog(@"设置模式 失败");
                        self.delayedBlockHandle = perform_block_after_delay_seconds(kLooTimeTnterval, ^{
                            @strongify(self)

                            [self setIMUModel:model completed:completed];
                            self.delayedBlockHandle = nil;
                        });
                    }
                }];
            }else{
                NSLog(@"设置模式 成功");

                BLOCK_EXEC(completed);
            }
        } else {
            NSLog(@"读取模式失败");
            self.delayedBlockHandle = perform_block_after_delay_seconds(kLooTimeTnterval, ^{
                @strongify(self)
                [self setIMUModel:model completed:completed];
                self.delayedBlockHandle = nil;
            });
        }
    }];
}

-(void)closeDevceWithCompleted:(void(^)(void))completed{
    @weakify(self)
    [self sendRequest:ZYBleInteractPowerOff data:@(0x55AA) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"关机成功");
            BLOCK_EXEC(completed);
        }else{
            NSLog(@"关机失败");
            self.delayedBlockHandle = perform_block_after_delay_seconds(kLooTimeTnterval, ^{
                @strongify(self)
                [self closeDevceWithCompleted:completed];
                self.delayedBlockHandle = nil;
            });
        }
    }];
}

-(void)clearRegisterCompleted:(void(^)(void))completed{
    @weakify(self)
    [self sendRequest:ZYBleInteractCodeIMUControlRegister_W data:@(ZYBleInteractIMUControlResigterClear) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)

        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"IMU模式清除成功");
            BLOCK_EXEC(completed);
        } else {
            NSLog(@"IMU模式清除 失败");
            self.delayedBlockHandle = perform_block_after_delay_seconds(kLooTimeTnterval, ^{
                @strongify(self)
                [self clearRegisterCompleted:completed];
                self.delayedBlockHandle = nil;
            });

        }
    }];
}

-(void) loopCalibation:(void(^)(void))completed{
    NSUInteger code = ZYBleInteractCodeIMUControlRegister_W;
    NSInteger writeData = ZYBleInteractIMUControlResigterAccelerate1;
    ZYBleInteractIMUStateResigterMask controlResigterstate = 0;

    switch (self.step) {
        case 0:
            writeData = ZYBleInteractIMUControlResigterAccelerate1;
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate1;
            break;
        case 1:
            writeData = ZYBleInteractIMUControlResigterAccelerate2;
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate2;

            break;
        case 2:
            writeData = ZYBleInteractIMUControlResigterAccelerate3;
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate3;

            break;
        case 3:
            writeData = ZYBleInteractIMUControlResigterAccelerate4;
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate4;

            break;
        case 4:
            writeData = ZYBleInteractIMUControlResigterAccelerate5;
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate5;

            break;
        case 5:
            writeData = ZYBleInteractIMUControlResigterAccelerate6;
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate6;

            break;
        case 6:
            writeData = ZYBleInteractIMUControlResigterAccelerateSixCalc;
            controlResigterstate = ZYBleInteractIMUStateResigterGyroTrackingReady;

            break;
        case 7:
            writeData = ZYBleInteractIMUControlResigterGyroAdjust;
            controlResigterstate = ZYBleInteractIMUStateResigterGyroAdjustSuccess;

            break;
            
        default:
            break;
    }
    
    @weakify(self)
    NSLog(@"开始校准第   %ld  个步骤   writeData:  %lx,   controlResigterstate: %lx", self.step, writeData, controlResigterstate);
    [self sendRequest:code data:@(writeData) completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)
        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"校准回调  %ld  个步骤 writeData:  %lx,   controlResigterstate: %lx", self.step, writeData, controlResigterstate);
            NSLog(@"写入IMU控制寄存器成功 %lxu", code);
            if (self.step>kSixSidesCalibration - 1 ) {//是否完成6面轴校准
                [self queryCalibrationtStateWithAdjustModel:controlResigterstate Complate:^(BOOL isAdjust) {//step 7 : 加速计校准
                        @strongify(self)
                        if ((!isAdjust)||self.step<8){
                            [self loopCalibation:completed];
                        }else{
                            BLOCK_EXEC(completed);
                        }
                }];
                 return ;
            }
            self.axisCalibrationloop.sendDelegate  = self.sendDelegate;
            //轴校准
            [self.axisCalibrationloop loopQueryAnglesIsStandardWithCompleted:^(){
                @strongify(self)

                [self queryCalibrationtStateWithAdjustModel:controlResigterstate Complate:^(BOOL isAdjust) {
                    @strongify(self)

                    if (isAdjust) {
                    }
                    [self loopCalibation:completed];
                }];
            }];
        }else{
            NSLog(@"写入IMU控制寄存器失败:%s %lx",__func__, (unsigned long)code);
            self.delayedBlockHandle = perform_block_after_delay_seconds(kLooTimeTnterval, ^{
                @strongify(self)
                [self loopCalibation:completed];
                self.delayedBlockHandle = nil;
            });
        }
    }];
}

- (ZYBleInteractIMUStateResigterMask)getStepIMUStateResigterMask{
    ZYBleInteractIMUStateResigterMask controlResigterstate = 0;
    switch (self.step) {
        case 0:
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate1;
            break;
        case 1:
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate2;
            break;
        case 2:
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate3;
            break;
        case 3:
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate4;
            break;
        case 4:
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate5;
            break;
        case 5:
            controlResigterstate = ZYBleInteractIMUStateResigterAccelerate6;
            break;
        case 6:
            controlResigterstate = ZYBleInteractIMUStateResigterGyroTrackingReady;
            break;
        case 7:
            controlResigterstate = ZYBleInteractIMUStateResigterGyroAdjustSuccess;
            break;
        default:
            break;
    }
    return controlResigterstate;
}

-(void) queryCalibrationtStateWithAdjustModel:(ZYBleInteractIMUStateResigterMask)adjustModel Complate:(void(^)(BOOL isAdjust))completed{
    @weakify(self)
    BOOL stepMatch = [self getStepIMUStateResigterMask] == adjustModel;
    if (!stepMatch) {
        return;
    }
    [self sendRequest:ZYBleInteractCodeIMUStateRegister_R  completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {//读取IMU状态寄存器
        @strongify(self)
        NSLog(@"   匹配前：   %ld   stepMatch:%d", self.step, stepMatch);
         if (state == ZYBleDeviceRequestStateResponse) {
             
             BOOL isAdjust =(CheckMask(param,adjustModel));
             if (isAdjust) {
                 if (self.calibrationStateBlock) {
                     self.calibrationStateBlock(self.step);
                 }
                 NSLog(@"匹配成功——————————");
                 self.step ++;
                 
                 BLOCK_EXEC(completed,YES);
                 
             }else{
                 NSLog(@"匹配不成功~~~~");
                 
                 BLOCK_EXEC(completed,NO);
             }
        }else{

            NSLog(@"读取IMU状态寄存器失败:%s %lx",__func__, (unsigned long)read);
            self.delayedBlockHandle = perform_block_after_delay_seconds(kLooTimeTnterval, ^{
                @strongify(self)
                [self queryCalibrationtStateWithAdjustModel:adjustModel Complate:completed];
                self.delayedBlockHandle = nil;
            });

        }
    }];
}

-(void)saveSettingCompleted:(void(^)(void))completed{
    @weakify(self)

    [self sendRequest:ZYBleInteractSave data:@(0xA151)  completionHandler:^(ZYBleDeviceRequestState state, NSUInteger param) {
        @strongify(self)

        if (state == ZYBleDeviceRequestStateResponse) {
            NSLog(@"保存成功 ");

            if (self.calibrationStateBlock) {
                self.calibrationStateBlock(ZYCalibrationCompleted);
            }
            BLOCK_EXEC(completed);
        }else{

            NSLog(@"保存失败 ");
            self.delayedBlockHandle = perform_block_after_delay_seconds(kLooTimeTnterval, ^{
                @strongify(self)
                [self saveSettingCompleted:completed];
                self.delayedBlockHandle = nil;
            });
        }
    }];
}

-(void)endCalibration{
    if (nil != _delayedBlockHandle) {
        _delayedBlockHandle(YES);
    }
    _delayedBlockHandle = nil;
    if (_axisCalibrationloop) {
        [_axisCalibrationloop closeLoop];
        _axisCalibrationloop = nil;
    }
}

-(void)dealloc{
#ifdef DEBUG
    
    NSLog(@"%@",[self class]);
#endif

}

-(void) sendRequest:(NSUInteger)code completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    [self sendRequest:code data:@(0) completionHandler:handler];
}

-(void) sendRequest:(NSUInteger)code data:(NSNumber*)data completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler
{
    
    if (code == ZYBleInteractInvalid) {
        handler(ZYBleDeviceRequestStateFail, 0);
        return;
    }
    ZYBleDeviceRequest* request = [[ZYBleDeviceRequest alloc] initWithCodeAndParam:code param:data];
    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(configEncodeAndTransmissionForRequest:)]) {
        [self.sendDelegate configEncodeAndTransmissionForRequest:request];
    }
    [[ZYBleDeviceClient defaultClient] sendBLERequest:request completionHandler:handler];
}
@end
