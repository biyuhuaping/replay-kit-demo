//
//  ZYBleProtocol.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/2/27.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBleProtocol.h"

static NSDictionary<NSNumber*, NSString*>* codeDescription = nil;

void initCodeDescription()
{
    if (codeDescription != nil) {
        return;
    }
    NSMutableDictionary<NSNumber*, NSString*>* baseCodeDescription = [NSMutableDictionary dictionaryWithDictionary:@{
                        @(ZYBleInteractCodeDeviceCategory_R):@"读取产品序列号",
                        @(ZYBleInteractCodeVersion_R):@"读取软件版本",
                        @(ZYBleInteractCodeSystemStatus_R):@"读取系统状态",
                        @(ZYBleInteractCodeBatteryVoltage_R):@"读取电池电压",
                        @(ZYBleInteractCodePower_R):@"读取开关机状态",
                        @(ZYBleInteractCodePower_W):@"设置开关机状态",
                        @(ZYBleInteractCodeDebug_R):@"读取调试模式",
                        @(ZYBleInteractCodeDebug_W):@"设置调试模式",
                        @(ZYBleInteractCodeIMUControlRegister_R):@"读取IMU控制寄存器",
                        @(ZYBleInteractCodeIMUControlRegister_W):@"设置IMU控制寄存器",
                        @(ZYBleInteractCodeIMUStateRegister_R):@"读取IMU状态寄存器",
                        @(ZYBleInteractCodeGyroStandardDeviation_R):@"读取陀螺标准差",
                        @(ZYBleInteractCodeIMUAX_R):@"读取IMU AX",
                        @(ZYBleInteractCodeIMUAY_R):@"读取IMU AY",
                        @(ZYBleInteractCodeIMUAZ_R):@"读取IMU AZ",
                        @(ZYBleInteractCodeIMUGX_R):@"读取IMU GX",
                        @(ZYBleInteractCodeIMUGY_R):@"读取IMU GY",
                        @(ZYBleInteractCodeIMUGZ_R):@"读取IMU GZ",
                        @(ZYBleInteractCodePitchAngle_R):@"读取俯仰角度",
                        @(ZYBleInteractCodeRollAngle_R):@"读取横滚角度",
                        @(ZYBleInteractCodeYawAngle_R):@"读取航向角度",
                        @(ZYBleInteractCodePitchSharpTurning_R):@"读取俯仰微调",
                        @(ZYBleInteractCodePitchSharpTurning_W):@"设置俯仰微调",
                        @(ZYBleInteractCodeRollSharpTurning_R):@"读取横滚微调",
                        @(ZYBleInteractCodeRollSharpTurning_W):@"设置横滚微调",
                        @(ZYBleInteractCodeWorkMode_R):@"读取工作模式",
                        @(ZYBleInteractCodeWorkMode_W):@"设置工作模式",
                        @(ZYBleInteractCodePitchDeadArea_R):@"读取俯仰跟随死区",
                        @(ZYBleInteractCodePitchDeadArea_W):@"设置俯仰跟随死区",
                        @(ZYBleInteractCodeRollDeadArea_R):@"读取横滚跟随死区",
                        @(ZYBleInteractCodeRollDeadArea_W):@"设置横滚跟随死区",
                        @(ZYBleInteractCodeYawDeadArea_R):@"读取航向跟随死区",
                        @(ZYBleInteractCodeYawDeadArea_W):@"设置航向跟随死区",
                        @(ZYBleInteractCodePitchFollowMaxRate_R):@"读取俯仰最大跟随速率",
                        @(ZYBleInteractCodePitchFollowMaxRate_W):@"设置俯仰最大跟随速率",
                        @(ZYBleInteractCodeRollFollowMaxRate_R):@"读取横滚最大跟随速率",
                        @(ZYBleInteractCodeRollFollowMaxRate_W):@"设置横滚最大跟随速率",
                        @(ZYBleInteractCodeYawFollowMaxRate_R):@"读取航向最大跟随速率",
                        @(ZYBleInteractCodeYawFollowMaxRate_W):@"设置航向最大跟随速率",
                        @(ZYBleInteractCodePitchSmoothness_R):@"读取俯仰平滑度",
                        @(ZYBleInteractCodePitchSmoothness_W):@"设置俯仰平滑度",
                        @(ZYBleInteractCodeRollSmoothness_R):@"读取横滚平滑度",
                        @(ZYBleInteractCodeRollSmoothness_W):@"设置横滚平滑度",
                        @(ZYBleInteractCodeYawSmoothness_R):@"读取航向平滑度",
                        @(ZYBleInteractCodeYawSmoothness_W):@"设置航向平滑度",
                        @(ZYBleInteractCodePitchControlMaxRate_R):@"读取俯仰最大控制速率",
                        @(ZYBleInteractCodePitchControlMaxRate_W):@"设置俯仰最大控制速率",
                        @(ZYBleInteractCodeRollControlMaxRate_R):@"读取横滚最大控制速率",
                        @(ZYBleInteractCodeRollControlMaxRate_W):@"设置横滚最大控制速率",
                        @(ZYBleInteractCodeYawControlMaxRate_R):@"读取航向最大控制速率",
                        @(ZYBleInteractCodeYawControlMaxRate_W):@"设置航向最大控制速率",
                        @(ZYBleInteractCodeRockerDirectionConfig_R):@"读取摇杆方向配置",
                        @(ZYBleInteractCodeRockerDirectionConfig_W):@"设置摇杆方向配置",
                        @(ZYBleInteractCodeCameraManufacturer_R):@"读取相机厂商",
                        @(ZYBleInteractCodeCameraManufacturer_W):@"设置相机厂商",
                        @(ZYBleInteractCodeMotorForce_R):@"读取电机力度",
                        @(ZYBleInteractCodeMotorForce_W):@"设置电机力度",
                        @(ZYBleInteractXMotorState_R):@"读取X电机状态",
                        @(ZYBleInteractXMotorVersion_R):@"读取X电机软件版本号",
                        @(ZYBleInteractYMotorState_R):@"读取X电机状态",
                        @(ZYBleInteractYMotorVersion_R):@"读取X电机软件版本号",
                        @(ZYBleInteractZMotorState_R):@"读取X电机状态",
                        @(ZYBleInteractZMotorVersion_R):@"读取X电机软件版本号",
                        @(ZYBleInteractProductionNo1_R):@"生产序列号(bit15-0)",
                        @(ZYBleInteractProductionNo2_R):@"生产序列号(bit31-16)",
                        @(ZYBleInteractProductionNo3_R):@"生产序列号(bit47-32)",
                        @(ZYBleInteractProductionNo4_R):@"生产序列号(bit59-48)",
                        @(ZYBleInteractUpgradableModuleCount):@"可升级模块数",
                        @(ZYBleInteractUpgradableDeviceId):@"模块链路及代号",
                        @(ZYBleInteractUpgradableVersion):@"模块版本",
                        @(ZYBleInteractPowerOn):@"开机",
                        @(ZYBleInteractPowerOff):@"关机",
                        @(ZYBleInteractSave):@"保存",
                        @(ZYBleInteractSysReset):@"系统复位",
                        @(ZYBleInteractGetIMUBootAdr):@"IMU BOOT地址",
                        @(ZYBleInteractGetIMUMachineVersion):@"IMU 机械版本",
                        @(ZYBleInteractGetIMUBootVersion):@"IMU BOOT版本",
                        @(ZYBleInteractGetIMUHardwareVersion):@"IMU 硬件版本",
                        @(ZYBleInteractGetIMUUUIDLow):@"IMU UUID低16位",
                        @(ZYBleInteractGetIMUUUIDHigh):@"IMU UUID高16位",
                        @(ZYBleInteractGetIMUFirmwareVersion):@"IMU 固件版本",
                        @(ZYBleInteractGetXMotorBootAdr):@"X电机 BOOT地址",
                        @(ZYBleInteractGetXMotorMachineVersion):@"X电机 机械版本",
                        @(ZYBleInteractGetXMotorBootVersion):@"X电机 BOOT版本",
                        @(ZYBleInteractGetXMotorHardwareVersion):@"X电机 硬件版本",
                        @(ZYBleInteractGetXMotorUUIDLow):@"X电机 UUID低16位",
                        @(ZYBleInteractGetXMotorUUIDHigh):@"X电机 UUID高16位",
                        @(ZYBleInteractGetXMotorFirmwareVersion):@"X电机 固件版本",
                        @(ZYBleInteractGetYMotorBootAdr):@"Y电机 BOOT地址",
                        @(ZYBleInteractGetYMotorMachineVersion):@"Y电机 机械版本",
                        @(ZYBleInteractGetYMotorBootVersion):@"Y电机 BOOT版本",
                        @(ZYBleInteractGetYMotorHardwareVersion):@"Y电机 硬件版本",
                        @(ZYBleInteractGetYMotorUUIDLow):@"Y电机 UUID低16位",
                        @(ZYBleInteractGetYMotorUUIDHigh):@"Y电机 UUID高16位",
                        @(ZYBleInteractGetYMotorFirmwareVersion):@"Y电机 固件版本",
                        @(ZYBleInteractGetZMotorBootAdr):@"Z电机 BOOT地址",
                        @(ZYBleInteractGetZMotorMachineVersion):@"Z电机 机械版本",
                        @(ZYBleInteractGetZMotorBootVersion):@"Z电机 BOOT版本",
                        @(ZYBleInteractGetZMotorHardwareVersion ):@"Z电机 硬件版本",
                        @(ZYBleInteractGetZMotorUUIDLow):@"Z电机 UUID低16位",
                        @(ZYBleInteractGetZMotorUUIDHigh):@"Z电机 UUID高16位",
                        @(ZYBleInteractGetZMotorFirmwareVersion):@"Z电机 固件版本",
                        @(ZYBleInteractGetICUBootAdr):@"ICU BOOT地址",
                        @(ZYBleInteractGetICUMachineVersion):@"ICU 机械版本",
                        @(ZYBleInteractGetICUBootVersion):@"ICU BOOT版本",
                        @(ZYBleInteractGetICUHardwareVersion):@"ICU 硬件版本",
                        @(ZYBleInteractGetICUUUIDLow):@"ICU UUID低16位",
                        @(ZYBleInteractGetICUUUIDHigh):@"ICU UUID高16位",
                        @(ZYBleInteractGetICUFirmwareVersion):@"ICU 固件版本",
                        @(ZYBleInteractFunctionEvent):@"功能事件",
                        @(ZYBleInteractButtonEvent):@"按键事件",
                        @(ZYBleInteractAppControl):@"app接管控制",
                        @(ZYBleInteractPitchControl):@"俯仰速度控制",
                        @(ZYBleInteractRollControl):@"横滚速度控制",
                        @(ZYBleInteractYawControl):@"航向速度控制",
                        @(ZYBleInteractFFControl):@"跟焦位置控制",
                        @(ZYBleInteractZoomControl):@"变焦位置控制",
                        @(ZYBleLocaltionSetPointPowered):@"位置定点使能",
                        @(ZYBleLocaltionSetPointControlRegister):@"位置定点使能控制寄存器",
                        @(ZYBleLocaltionSetPointStateRegister):@"位置定点使能状态寄存器",
                        @(ZYBleLocaltionSetPointStateRegister_R):@"位置定点状态寄存器",
                        @(ZYBlePitchRotateAngleControl):@"俯仰角度制",
                        @(ZYBleRollRotateAngleControl):@"横滚角度控制",
                        @(ZYBleYawRotateAngleControl):@"航向角度控制",
                        @(ZYBleSetPointMotionTimeLowBit):@"位置定点移动时间",
                        @(ZYBleSetPointMotionTimeHighBit):@"位置定点移动时间",
                        @(ZYBleInteractPitchMotionControl):@"体感俯仰参数",
                        @(ZYBleInteractRollMotionControl):@"体感横滚参数",
                        @(ZYBleInteractYawMotionControl):@"体感航向参数",
                        @(ZYBleOneStepCalibration):@"一键校准",
                        @(ZYBleLandscapeOrPortaitCalibration):@"横拍竖拍",
                        @(ZYBleControlSpeedDirect_R):@"读取遥感速度控制",
                        @(ZYBleControlSpeedDirect_W):@"写入遥感速度控制",
                        @(ZYBleContextualModel_R):@"读取情景模式",
                        @(ZYBleContextualModel_W):@"写入情景模式",

                        }];
    
    for (NSNumber* key in baseCodeDescription.allKeys) {
        id value = baseCodeDescription[key];
        NSUInteger code = key.unsignedIntegerValue;
        code = ZYBLEMakeInteractCodeWithoutAdr(code);
        [baseCodeDescription setObject:value forKey:@(code)];
    }
    
    codeDescription = baseCodeDescription;
}



NSString* starCodeToNSString(NSUInteger code)
{
    NSString* name = nil;
    code = ZYBLEMakeInteractCodeWithoutAdr(code);
    
    initCodeDescription();
    name = [codeDescription objectForKey:@(code)];
    if (name == nil)
        name = @"unknown";
    
    return name;
}

