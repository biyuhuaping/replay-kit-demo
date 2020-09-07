//
//  ZYBleDeviceDataModel.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/6.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBleProtocol.h"
#import "ZYBleDeviceMotorModel.h"
#import "ZYProductNoModel.h"
#define CheckMask(val, mask) ((val & mask) == mask)

extern NSString* const  modelNumberUnknown      ;
extern NSString* const  modelNumberPround       ;
extern NSString* const  modelNumberEvolution    ;
extern NSString* const  modelNumberEvolution2   ;
extern NSString* const  modelNumberEvolution3   ;

extern NSString* const  modelNumberSmooth       ;
extern NSString* const  modelNumberSmooth2      ;
extern NSString* const  modelNumberSmooth3      ;
extern NSString* const  modelNumberSmoothQ      ;
extern NSString* const  modelNumberSmoothQ2     ;
extern NSString* const  modelNumberSmoothX     ;
extern NSString* const  modelNumberSmoothXS   ;
extern NSString* const  modelNumberLiveStabilizer  ;//sm111直播云台

extern NSString* const  modelNumberSmoothP1;
extern NSString* const  modelNumberSmooth4      ;
extern NSString* const  modelNumberSmoothC11    ;

extern NSString* const  modelNumberRider        ;
extern NSString* const  modelNumberRiderM       ;
extern NSString* const  modelNumberCrane        ;
extern NSString* const  modelNumberCraneM       ;
extern NSString* const  modelNumberCraneS       ;
extern NSString* const  modelNumberCraneL       ;
extern NSString* const  modelNumberCraneH       ;

extern NSString* const  modelNumberCraneTwoS     ;
extern NSString* const  modelNumberCraneTwo     ;
extern NSString* const  modelNumberCranePlus    ;
extern NSString* const  modelNumberCrane3S       ;
extern NSString* const  modelNumberCrane3Lab    ;

extern NSString* const  modelNumberWeebill      ;
extern NSString* const  modelNumberWeebillLab   ;
extern NSString* const  modelNumberWeebillS      ;
extern NSString* const  modelNumberImageTransBox;
extern NSString* const  modelNumberImageTransBoxRecive;
extern NSString* const  modelNumberImageTransBoxTwo;

extern NSString* const  modelNumberCraneM2      ;

extern NSString* const  modelNumberShining      ;

extern NSString* const  modelNumberCraneZWB     ;

extern NSString* const  modelNumberCraneEngineering ;


@interface ZYBleDeviceDataModel : NSObject
/**
发送队列里面的数据需要打包一起发送
*/
@property(nonatomic, readwrite) BOOL newSendMessagePakge;


/**
 产品型号
 */
@property(nonatomic, readwrite, copy) NSString* modelNumberString;

/**
 产品型号
 */
@property(nonatomic, assign) NSUInteger modelNumber;


/**
 软件版本号
 */
@property(nonatomic, readwrite) NSUInteger softwareVersion;

/**
 欠压
 */
@property(nonatomic, readwrite) BOOL bLowVoltage;
/**
 ICU掉线
 */
@property(nonatomic, readwrite) BOOL bICUOffLine;
/**
 Z电机掉线
 */
@property(nonatomic, readwrite) BOOL bZOffLine;
/**
 Y电机掉线
 */
@property(nonatomic, readwrite) BOOL bYOffLine;
/**
 X电机掉线
 */
@property(nonatomic, readwrite) BOOL bXOffLine;
/**
 IMU异常
 */
@property(nonatomic, readwrite) BOOL bIMUExeption;
/**
 回头模式标志
 */
@property(nonatomic, readwrite) BOOL bTurnRound;
/**
 开机状态标志
 */
@property(nonatomic, readwrite) BOOL bPower;

/**
 电池电压 单位V
 */
@property(nonatomic, readwrite) float fBatteryVoltage;

/**
 开关机状态
 */
@property(nonatomic, readwrite) ZYBleInteractMotorPower powerStatus;

/**
 调试模式
 */
@property(nonatomic, readwrite) ZYBleInteractDeviceDebugMode debugMode;

/**
 陀螺仪标准差
 */
@property(nonatomic, readwrite) NSInteger gyroStandardDeviation;
/**
 IMU X轴加速度
 */
@property(nonatomic, readwrite) NSInteger IMUAX;
/**
 IMU Y轴加速度
 */
@property(nonatomic, readwrite) NSInteger IMUAY;
/**
 IMU Z轴加速度
 */
@property(nonatomic, readwrite) NSInteger IMUAZ;
/**
 IMU X轴陀螺仪原始数据
 */
@property(nonatomic, readwrite) NSUInteger IMUGX;
/**
 IMU Y轴陀螺仪原始数据
 */
@property(nonatomic, readwrite) NSUInteger IMUGY;
/**
 IMU Z轴陀螺仪原始数据
 */
@property(nonatomic, readwrite) NSUInteger IMUGZ;


/**
 俯仰角度
 */
@property(nonatomic, readwrite) float pitchAngle;
/**
 横滚角度
 */
@property(nonatomic, readwrite) float rollAngle;
/**
 航向角度
 */
@property(nonatomic, readwrite) float yawAngle;

/**
 俯仰微调
 */
@property(nonatomic, readwrite) float pitchSharpTurning;
/**
 横滚微调
 */
@property(nonatomic, readwrite) float rollSharpTurning;

/**
 工作模式
 */
@property(nonatomic, readwrite) ZYBleDeviceWorkMode workMode;

/**
 俯仰跟随死区 度
 */
@property(nonatomic, readwrite) float pitchDeadArea;
/**
 横滚跟随死区 度
 */
@property(nonatomic, readwrite) float rollDeadArea;
/**
 航向跟随死区 度
 */
@property(nonatomic, readwrite) float yawDeadArea;

/**
 俯仰最大跟随速率   度/秒
 */
@property(nonatomic, readwrite) float pitchFollowMaxRate;
/**
 横滚最大跟随速率   度/秒
 */
@property(nonatomic, readwrite) float rollFollowMaxRate;
/**
 航向最大跟随速率   度/秒
 */
@property(nonatomic, readwrite) float yawFollowMaxRate;

/**
 俯仰平滑度
 */
@property(nonatomic, readwrite) float pitchSmoothness;
/**
 横滚平滑度
 */
@property(nonatomic, readwrite) float rollSmoothness;
/**
 航向平滑度
 */
@property(nonatomic, readwrite) float yawSmoothness;

/**
 俯仰最大控制速率 度/秒
 */
@property(nonatomic, readwrite) float pitchControlMaxRate;
/**
 横滚最大控制速率 度/秒
 */
@property(nonatomic, readwrite) float rollControlMaxRate;
/**
 航向最大控制速率 度/秒
 */
@property(nonatomic, readwrite) float yawControlMaxRate;

/**
 摇杆方向X轴是否反向 俯仰
 */
@property(nonatomic, readwrite) BOOL bControllerXAnti;
/**
 摇杆方向Y轴是否反向 横滚
 */
@property(nonatomic, readwrite) BOOL bControllerYAnti;
/**
 摇杆方向Z轴是否反向 航向
 */
@property(nonatomic, readwrite) BOOL bControllerZAnti;

/**
 相机厂商
 */
@property(nonatomic, readwrite, copy) NSString* cameraManufacturerString;

/**
 电机力度模式
 */
@property(nonatomic, readwrite) ZYBleDeviceMotorForceMode motorForceMode;

/**
 xyz轴电机状态
 */
@property(nonatomic, readwrite, strong) NSArray<ZYBleDeviceMotorModel*>* motorStatus;

/**
 产品生产序列号
 */
@property(nonatomic, readonly, strong) ZYProductNoModel* productionNo;

/**
 更新数据

 @param aCode 指令代号
 @param aParam 指令参数
 */
-(void) updateModel:(NSUInteger)aCode param:(NSUInteger)aParam;

/**
 系列号转换成型号

 @param aParam 产品系列号
 @return 型号
 */
+(NSString*) translateToModelNumber:(NSUInteger)aParam;

/**
 支持wifi的产品型号列表

 @return <#return value description#>
 */
+(NSArray<NSString*>*) supportWIFIModelList;

/**
 指定的产品型号是否支持wifi

 @param modelString 产品型号
 @return 是否支持wifi
 */
+(BOOL) isModelSupportWIFI:(NSString*)modelString;


/**
 是否是支持HID的设备，如果是HID的设备需要屏蔽掉volume
 
 @return 设备
 */
+(BOOL)isHIDSupportDeviceWithModelString:(NSString *)modelNameString;

/// 跟weebills一样的功能
/// @param modelString string
+(BOOL)likeWeebillsWithString:(NSString *)modelString;

/// 跟图传盒子一样的功能
/// @param modelString string
+(BOOL)likeImageTransBoxWithString:(NSString *)modelString;
/// 跟smoothX一样的功能
/// @param modelString smoothX
+(BOOL)likeSmoothXWithString:(NSString *)modelString;

@end
