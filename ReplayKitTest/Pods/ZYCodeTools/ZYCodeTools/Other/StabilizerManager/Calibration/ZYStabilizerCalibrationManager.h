//
//  ZYStabilizerCalibrationManager.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/2/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZYBleProtocol.h"
#import "ZYSendRequest.h"


/**
 校准状态

 - ZYCalibrationStateAccelerate1: 完成校准加速1
 - ZYCalibrationStateAccelerate2: 完成校准加速2
 - ZYCalibrationStateAccelerate3: 完成校准加速3
 - ZYCalibrationStateAccelerate4: 完成校准加速4
 - ZYCalibrationStateAccelerate5: 完成校准加速5
 - ZYCalibrationStateAccelerate6: 完成校准加速6
 - ZYCalibrationGyroTrackingReady: 完成陀螺仪运动跟踪就绪
 - ZYCalibrationStateGyroAdjustSuccess: 完成陀螺仪校准通过
 - ZYCalibrationCompleted: 校准完成.
 */
typedef NS_ENUM(NSInteger,ZYCalibrationState) {
    ZYCalibrationStateAccelerate1 = 0,
    ZYCalibrationStateAccelerate2,
    ZYCalibrationStateAccelerate3,
    ZYCalibrationStateAccelerate4,
    ZYCalibrationStateAccelerate5,
    ZYCalibrationStateAccelerate6,
    ZYCalibrationGyroTrackingReady,
    ZYCalibrationStateGyroAdjustSuccess,
    ZYCalibrationCompleted

};

typedef void(^ZYCalibrationStateBlock)(ZYCalibrationState calibrationState);


/**
 校准管理工具.
 校准过程:
 进入IMU调试模式->关机->清除控制寄存器->循环读取IMUX、Y、Z和陀螺仪的数值，根据当前的步骤进行相应的计算->手机计算成功后，发指令让硬件计算是否校准->依次循环完成6面校准、加速计和陀螺仪校准->清除控制寄存器->设置IMU正常状态->保存.
 */
@interface ZYStabilizerCalibrationManager : NSObject

@property (nonatomic, weak)   id<ZYSendRequest> sendDelegate;


/**
 当前校准状态回调Block
 */
@property(nonatomic,copy) ZYCalibrationStateBlock calibrationStateBlock;


/**
 开始校准
 @param completed 完成的回调
 */
-(void)beginCalibration:(void (^)(void))completed;


/**
 结束校准，如果在校准完成前需要停止校准功能，需调用该发方法.停止内部的循环
 */
-(void)endCalibration;



@end
