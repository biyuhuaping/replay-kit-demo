//
//  ZYBleProtocol.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/6.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#ifndef __ZYBLEPROTOCOL_H__
#define __ZYBLEPROTOCOL_H__


#define ZYBLE_CMD_WRITE     0xC0
#define ZYBLE_CMD_READ      0x40
#define ZYBLE_DATA_WRITE    0x80
#define ZYBLE_DATA_READ     0x00
#define ZYBLE_CMD_CONTR     0x10


#define ZYBLE_POWER_ON_PARAM    0xAA55
#define ZYBLE_POWER_OFF_PARAM   0x55AA
#define ZYBLE_SAVE_PARAM        0xA151
#define ZYBLE_SYS_RESET_PARAM   0xA153

#define ZYBLEMakeInteractCode(cmd, adr, idx) (((cmd >> 4) << 12) | ((adr & 0x0F) << 8) | idx)
#define ZYBLEMakeInteractCodeToCmd(code) ((code >> 8) & 0xF0)
#define ZYBLEDataReadCodeToWriteCode(code) (((ZYBLE_DATA_WRITE >> 4) << 12) | (code&0x0FFF))
#define ZYBLEMakeInteractCodeWithoutAdr(code) ((code)&0xF0FF)
#define ZYBLEMakeInteractCodeWithoutAdrCmp(code, value) (((code)&0xF0FF) == ((value)&0xF0FF))

#define ZYBLE_FIRM_SEND_HEAD 0x243C
#define ZYBLE_FIRM_RECV_HEAD 0x243E
#define ZYBLE_FIRM_RECV_HEAD_REVERSE 0x3E24

#define ZYBLE_DATA_RESET     0xA153
#define ZYBLAdressFromCode(code) (code>>4)
#define ZYBLCommandFromCode(code) (code&0x0F)

typedef NS_ENUM(NSUInteger, ZYBleInteractCode) {
    ZYBleInteractCodeDeviceCategory_R               = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x02),   //读取产品序列号
    ZYBleInteractCodeVersion_R                      = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x04),   //读取软件版本
    ZYBleInteractCodeSystemStatus_R                 = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x05),   //读取系统状态
    ZYBleInteractCodeBatteryVoltage_R               = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x06),   //读取电池电压
    ZYBleInteractCodePower_R                        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x07),   //读取开关机状态
    ZYBleInteractCodePower_W                        = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x07),  //设置开关机状态
    ZYBleInteractCodeDebug_R                        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x09),   //读取调试模式
    ZYBleInteractCodeDebug_W                        = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x09),  //设置调试模式
    ZYBleInteractCodeIMUControlRegister_R           = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x10),   //读取IMU控制寄存器
    ZYBleInteractCodeIMUControlRegister_W           = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x10),  //设置IMU控制寄存器
    ZYBleInteractCodeIMUStateRegister_R             = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x11),   //读取IMU状态寄存器
    ZYBleInteractCodeGyroStandardDeviation_R        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x12),   //读取陀螺标准差
    ZYBleInteractCodeIMUAX_R                        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x1C),   //读取IMU AX  [0, 4096]
    ZYBleInteractCodeIMUAY_R                        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x1D),   //读取IMU AY  [0, 4096]
    ZYBleInteractCodeIMUAZ_R                        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x1E),   //读取IMU AZ  [0, 4096]
    ZYBleInteractCodeIMUGX_R                        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x1F),   //读取IMU GX
    ZYBleInteractCodeIMUGY_R                        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x20),   //读取IMU GY
    ZYBleInteractCodeIMUGZ_R                        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x21),   //读取IMU GZ
    ZYBleInteractCodePitchAngle_R                   = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x22),   //读取俯仰角度
    ZYBleInteractCodeRollAngle_R                    = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x23),   //读取横滚角度
    ZYBleInteractCodeYawAngle_R                     = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x24),   //读取航向角度
    ZYBleInteractCodePitchSharpTurning_R            = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x25),   //读取俯仰微调
    ZYBleInteractCodePitchSharpTurning_W            = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x25),  //设置俯仰微调    [-5.00, 5.00]
    ZYBleInteractCodeRollSharpTurning_R             = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x26),   //读取横滚微调    [-5.00, 5.00]
    ZYBleInteractCodeRollSharpTurning_W             = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x26),  //设置横滚微调    [-5.00, 5.00]
    ZYBleInteractCodeWorkMode_R                     = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x27),   //读取工作模式
    ZYBleInteractCodeWorkMode_W                     = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x27),  //设置工作模式
    ZYBleInteractCodePitchDeadArea_R                = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x5B),   //读取俯仰跟随死区  [0.0 30.0]
    ZYBleInteractCodePitchDeadArea_W                = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x5B),  //设置俯仰跟随死区  [0.0 30.0]
    ZYBleInteractCodeRollDeadArea_R                 = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x5C),   //读取横滚跟随死区  [0.0 30.0]
    ZYBleInteractCodeRollDeadArea_W                 = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x5C),  //设置横滚跟随死区  [0.0 30.0]
    ZYBleInteractCodeYawDeadArea_R                  = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x5D),   //读取航向跟随死区  [0.0 30.0]
    ZYBleInteractCodeYawDeadArea_W                  = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x5D),  //设置航向跟随死区  [0.0 30.0]
    ZYBleInteractCodePitchFollowMaxRate_R           = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x5E),   //读取俯仰最大跟随速率    [0, 120]
    ZYBleInteractCodePitchFollowMaxRate_W           = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x5E),  //设置俯仰最大跟随速率    [0, 120]
    ZYBleInteractCodeRollFollowMaxRate_R            = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x5F),   //读取横滚最大跟随速率    [0, 120]
    ZYBleInteractCodeRollFollowMaxRate_W            = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x5F),  //设置横滚最大跟随速率    [0, 120]
    ZYBleInteractCodeYawFollowMaxRate_R             = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x60),   //读取航向最大跟随速率    [0, 120]
    ZYBleInteractCodeYawFollowMaxRate_W             = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x60),  //设置航向最大跟随速率    [0, 120]
    ZYBleInteractCodePitchSmoothness_R              = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x61),   //读取俯仰平滑度   [50, 200]
    ZYBleInteractCodePitchSmoothness_W              = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x61),  //设置俯仰平滑度   [50, 200]
    ZYBleInteractCodeRollSmoothness_R               = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x62),   //读取横滚平滑度   [50, 200]
    ZYBleInteractCodeRollSmoothness_W               = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x62),  //设置横滚平滑度   [50, 200]
    ZYBleInteractCodeYawSmoothness_R                = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x63),   //读取航向平滑度   [50, 200]
    ZYBleInteractCodeYawSmoothness_W                = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x63),  //设置航向平滑度   [50, 200]
    ZYBleInteractCodePitchControlMaxRate_R          = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x64),   //读取俯仰最大控制速率    [0, 100]
    ZYBleInteractCodePitchControlMaxRate_W          = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x64),  //设置俯仰最大控制速率    [0, 100]
    ZYBleInteractCodeRollControlMaxRate_R           = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x65),   //读取横滚最大控制速率    [0, 100]
    ZYBleInteractCodeRollControlMaxRate_W           = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x65),  //设置横滚最大控制速率    [0, 100]
    ZYBleInteractCodeYawControlMaxRate_R            = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x66),   //读取航向最大控制速率    [0, 100]
    ZYBleInteractCodeYawControlMaxRate_W            = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x66),  //设置航向最大控制速率    [0, 100]
    ZYBleInteractCodeRockerDirectionConfig_R        = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x67),   //读取摇杆方向配置
    ZYBleInteractCodeRockerDirectionConfig_W        = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x67),  //设置摇杆方向配置
    ZYBleInteractCodeCameraManufacturer_R           = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x68),   //读取相机厂商
    ZYBleInteractCodeCameraManufacturer_W           = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x68),  //设置相机厂商
    ZYBleInteractCodeMotorForce_R                   = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x69),   //读取电机力度
    ZYBleInteractCodeMotorForce_W                   = ZYBLEMakeInteractCode(ZYBLE_DATA_WRITE, 0x01, 0x69),  //设置电机力度
    ZYBleInteractXMotorState_R                      = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x02, 0x02),   //读取X电机状态
    ZYBleInteractXMotorVersion_R                    = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x02, 0x3F),   //读取X电机软件版本号
    ZYBleInteractYMotorState_R                      = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x03, 0x02),   //读取X电机状态
    ZYBleInteractYMotorVersion_R                    = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x03, 0x3F),   //读取X电机软件版本号
    ZYBleInteractZMotorState_R                      = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x04, 0x02),   //读取X电机状态
    ZYBleInteractZMotorVersion_R                    = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x04, 0x3F),   //读取X电机软件版本号
    ZYBleInteractProductionNo1_R                    = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x7C),   //生产序列号（bit15-0）
    ZYBleInteractProductionNo2_R                    = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x7D),   //生产序列号（bit31-16）
    ZYBleInteractProductionNo3_R                    = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x7E),   //生产序列号（bit47-32）
    ZYBleInteractProductionNo4_R                    = ZYBLEMakeInteractCode(ZYBLE_DATA_READ, 0x01, 0x7F),   //生产序列号（bit59-48）
    
    ZYBleInteractPowerOn                            = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x03),   //开机
    ZYBleInteractPowerOff                           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x04),   //关机
    ZYBleInteractSave                               = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x05),   //保存
    ZYBleInteractSysReset                           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x07),   //系统复位
    ZYBleInteractGetIMUBootAdr                      = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x10),   //IMU BOOT地址
    ZYBleInteractGetIMUMachineVersion               = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x11),   //IMU 机械版本
    ZYBleInteractGetIMUBootVersion                  = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x12),   //IMU BOOT版本
    ZYBleInteractGetIMUHardwareVersion              = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x13),   //IMU 硬件版本
    ZYBleInteractGetIMUUUIDLow                      = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x14),   //IMU UUID低16位
    ZYBleInteractGetIMUUUIDHigh                     = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x15),   //IMU UUID高16位
    ZYBleInteractGetIMUFirmwareVersion              = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x16),   //IMU 固件版本
    ZYBleInteractGetXMotorBootAdr                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x02, 0x10),   //X电机 BOOT地址
    ZYBleInteractGetXMotorMachineVersion            = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x02, 0x11),   //X电机 机械版本
    ZYBleInteractGetXMotorBootVersion               = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x02, 0x12),   //X电机 BOOT版本
    ZYBleInteractGetXMotorHardwareVersion           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x02, 0x13),   //X电机 硬件版本
    ZYBleInteractGetXMotorUUIDLow                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x02, 0x14),   //X电机 UUID低16位
    ZYBleInteractGetXMotorUUIDHigh                  = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x02, 0x15),   //X电机 UUID高16位
    ZYBleInteractGetXMotorFirmwareVersion           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x02, 0x16),   //X电机 固件版本
    ZYBleInteractGetYMotorBootAdr                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x03, 0x10),   //Y电机 BOOT地址
    ZYBleInteractGetYMotorMachineVersion            = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x03, 0x11),   //Y电机 机械版本
    ZYBleInteractGetYMotorBootVersion               = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x03, 0x12),   //Y电机 BOOT版本
    ZYBleInteractGetYMotorHardwareVersion           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x03, 0x13),   //Y电机 硬件版本
    ZYBleInteractGetYMotorUUIDLow                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x03, 0x14),   //Y电机 UUID低16位
    ZYBleInteractGetYMotorUUIDHigh                  = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x03, 0x15),   //Y电机 UUID高16位
    ZYBleInteractGetYMotorFirmwareVersion           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x03, 0x16),   //Y电机 固件版本
    ZYBleInteractGetZMotorBootAdr                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x10),   //Z电机 BOOT地址
    ZYBleInteractGetZMotorMachineVersion            = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x11),   //Z电机 机械版本
    ZYBleInteractGetZMotorBootVersion               = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x12),   //Z电机 BOOT版本
    ZYBleInteractGetZMotorHardwareVersion           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x13),   //Z电机 硬件版本
    ZYBleInteractGetZMotorUUIDLow                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x14),   //Z电机 UUID低16位
    ZYBleInteractGetZMotorUUIDHigh                  = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x15),   //Z电机 UUID高16位
    ZYBleInteractGetZMotorFirmwareVersion           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x16),   //Z电机 固件版本
    ZYBleInteractGetICUBootAdr                      = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x10),   //ICU BOOT地址
    ZYBleInteractGetICUMachineVersion               = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x11),   //ICU 机械版本
    ZYBleInteractGetICUBootVersion                  = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x12),   //ICU BOOT版本
    ZYBleInteractGetICUHardwareVersion              = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x13),   //ICU 硬件版本
    ZYBleInteractGetICUUUIDLow                      = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x14),   //ICU UUID低16位
    ZYBleInteractGetICUUUIDHigh                     = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x15),   //ICU UUID高16位
    ZYBleInteractGetICUFirmwareVersion              = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x04, 0x16),   //ICU 固件版本
    ZYBleInteractFunctionEvent                      = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x21),   //功能事件
    ZYBleInteractButtonEvent                        = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x20),   //按键事件
    ZYBleInteractAppControl                         = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x38),   //app接管控制
    
    ZYBleInteractUpgradableModuleCount              = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x80),   //可升级模块数
    ZYBleInteractUpgradableDeviceId                 = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x81),   //模块链路及代号
    ZYBleInteractUpgradableVersion                  = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x82),   //模块版本
    ZYBleInteractFFLow16bit                         = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x50),   //跟焦器位置低16位
    ZYBleInteractFFHigh16bit                        = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x51),   //跟焦器位置高16位
    ZYBleInteractFFVirtualPos                       = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x52),   //跟焦器app虚拟滚轮位置
    ZYBleInteractZoomLow16bit                       = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x60),   //变焦器位置低16位
    ZYBleInteractZoomHigh16bit                      = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x61),   //变焦器位置高16位
    ZYBleInteractZoomVirtualPos                     = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x62),   //变焦器app虚拟滚轮位置
    
    ZYBleInteractPitchControl                       = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x01),   //俯仰速度控制 [-2048, 2048]
    ZYBleInteractRollControl                        = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x02),   //横滚速度控制 [-2048, 2048]
    ZYBleInteractYawControl                         = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x03),   //航向速度控制 [-2048, 2048]
    ZYBleInteractFFControl                          = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x04),   //跟焦位置控制 [0, 65535]
    ZYBleInteractZoomControl                        = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x05),   //变焦位置控制 [0, 65535]
    
    ZYBleLocaltionSetPointPowered                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x30),   //位置定点使能 [0,1]-->[关闭,打开] ZYBleLocationSetPointPowered

    ZYBleLocaltionSetPointControlRegister           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x31),   //位置定点使能控制寄存器[0,3]-->[清零，开始，保留，暂停] ZYBleLocationSetPointControlRegisterType
    
    ZYBleLocaltionSetPointStateRegister             = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x32),   //位置定点使能状态寄存器[15:4,3,2,1,0]->[保留,暂停,完成,开始,使能] ZYBleLocationSetPointStateRegisterType
    ZYBleLocaltionSetPointStateRegister_R             = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x32),   //位置定点状态寄存器[15:4,3,2,1,0]->[保留,暂停,完成,开始,使能] ZYBleLocationSetPointStateRegisterType

    ZYBlePitchRotateAngleControl                    = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x33),   //俯仰角度制 [-9000, 9000] 对应[ -90°,90°]
    ZYBleRollRotateAngleControl                     = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x34),   //横滚角度控制 [-4500, 4500] 对应[ -45°,45°]
    ZYBleYawRotateAngleControl                      = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x35),   //航向角度控制 [-18000, 18000] 对应[ - 180°,180°]
    
    ZYBlePitchSomatosensoryControl_R                 = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x70),   //俯仰体感[0, FFFF]
    ZYBleRollSomatosensoryControl_R                  = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x71),   //横滚体感[0, FFFF]
    ZYBleYawSomatosensoryControl_R                   = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x72),   //航向体感[0, FFFF]
    
    ZYBlePitchSomatosensoryControl_W                 = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x70),   //俯仰体感[0, FFFF]
    ZYBleRollSomatosensoryControl_W                  = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x71),   //横滚体感[0, FFFF]
    ZYBleYawSomatosensoryControl_W                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x72),   //航向体感[0, FFFF]
    ZYBlePitchPowerSet_W                = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x90),   //x轴（俯仰轴）力矩设置    [5, 100]
    ZYBleRollPowerSet_W                 = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x91),   //y轴（横滚轴）力矩设置    [5, 100]

    ZYBleYawPowerSet_W                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x92),   //Z轴（航向轴）力矩设置    [5, 100]
    ZYBlePitchPowerSet_R                 = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x90),   //x轴（俯仰轴）力矩设置    [5, 100]
      ZYBleRollPowerSet_R                = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x91),   //y轴（横滚轴）力矩设置    [5, 100]

      ZYBleYawPowerSet_R                 = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0x92),   //Z轴（航向轴）力矩设置    [5, 100]

    ZYBleOneStepCalibration                          = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0xA0),//一键校准
    ZYBleLandscapeOrPortaitCalibration               = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0xA1),//横拍和竖拍
    
    ZYBleControlSpeedDirect_R                        = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0xA2),//遥感控制
    ZYBleControlSpeedDirect_W                        = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0xA2),//遥感控制
    ZYBleContextualModel_R                           = ZYBLEMakeInteractCode(ZYBLE_CMD_READ, 0x01, 0xA3),//情景模式
    ZYBleContextualModel_W                           = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0xA3),//情景模式
    
    ZYBleInteractPitchMotionControl                       = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x06),   //体感俯仰参数 [ -9000, 9000]
    ZYBleInteractRollMotionControl                        = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x07),   //体感横滚参数 [ -4500, 4500]
    ZYBleInteractYawMotionControl                         = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x08),   //体感航向参数 [-18000,18000]
    
    ZYBleInteractPitchTrackControl                       = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x09),   //体感俯仰参数 [0,1000] ，500为屏幕中间
    ZYBleInteractYawTrackControl                         = ZYBLEMakeInteractCode(ZYBLE_CMD_CONTR, 0x00, 0x0A),   //体感航向参数 [0,1000] ，500为屏幕中间
    
    ZYBleSetPointMotionTimeLowBit                   = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x36),   //位置定点移动时间（低16bit）[0,FFFF]
    
    ZYBleSetPointMotionTimeHighBit                  = ZYBLEMakeInteractCode(ZYBLE_CMD_WRITE, 0x01, 0x37),   //位置定点移动时间（高16bit）[0,FFFF]

    ZYBleInteractInvalid                            = ZYBLEMakeInteractCode(0x00, 0x00, 0x00),   //无效指令
    
    
    //zyble 蓝牙控制事件 默认超时时间200ms
    ZYBleInteractCmdGetLocalAddr    = 0x01,  //获取蓝牙模块MAC地址
    ZYBleInteractCmdStatus          = 0x02,  //获取蓝牙模块状态
    ZYBleInteractCmdStartScan       = 0x03,  //开启扫描
    ZYBleInteractCmdStopScan        = 0x04,  //停止扫描
    ZYBleInteractCmdConnect         = 0x05,  //连接设备    超时时间3000ms
    ZYBleInteractCmdDisconnect      = 0x06,  //断开连接设备
    ZYBleInteractCmdReconnect       = 0x07,  //重新连接上一设备
    ZYBleInteractCmdRssi            = 0x08,  //获取RSSI值
    ZYBleInteractCmdDevice          = 0x09,  //设备信息命令
    ZYBleInteractCmdErr             = 0x0A,  //蓝牙模块错误指令
    
    //zyble 蓝牙模块状态列表
    ZYBleInteractStatusNone         = 0x00,
    ZYBleInteractStatusIdle         = 0x01,  //空闲状态
    ZYBleInteractStatusScaning      = 0x02,  //扫描状态
    ZYBleInteractStatusConnected    = 0x03,  //已连接状态
    
    //zyble 手柄指令列表
    ZYBleInteractHDLFocusMode       = 0x01,  //调焦和变焦
    
    ZYBleInteractErrNone        = 0x00,
    ZYBleInteractErrCrc         = 0x01,
    ZYBleInteractErrWrite       = 0x02,
    ZYBleInteractErrErase       = 0x03,
    ZYBleInteractErrCMD         = 0x04,
};

typedef NS_ENUM(NSUInteger, ZYBleInteractDeviceCategory) {
    ZYBleInteractDevice_Pround          =   0x0200,
    ZYBleInteractDevice_Evolution       =   0x0300,
    ZYBleInteractDevice_Smooth          =   0x0210,
    ZYBleInteractDevice_Smooth2         =   0x0220,
    ZYBleInteractDevice_Smooth3         =   0x0230,
    ZYBleInteractDevice_Rider_M         =   0x0400,
    ZYBleInteractDevice_Crane           =   0x0500,
    ZYBleInteractDevice_Crane_M            =   0x0510,
    ZYBleInteractDevice_Shining         =   0x1000,
};

/**
 <#Description#> 设备系统状态掩码,未定义为保留

 - ZYBleInteractSysStateMaskLowVoltage: 欠压
 - ZYBleInteractSysStateMaskICUOffLine: ICU掉线
 - ZYBleInteractSysStateMaskZOffLine: Z电机掉线
 - ZYBleInteractSysStateMaskYOffLine: Y电机掉线
 - ZYBleInteractSysStateMaskXOffLine: X电机掉线
 - ZYBleInteractSysStateMaskIMUExeption: IMU异常
 - ZYBleInteractSysStateMaskTurnRound: 回头模式标志
 - ZYBleInteractSysStateMaskPower: 开机状态标志
 */
typedef NS_OPTIONS(NSUInteger, ZYBleInteractSysStateMask) {
    ZYBleInteractSysStateMaskLowVoltage         =   0x01 << 13,
    ZYBleInteractSysStateMaskICUOffLine         =   0x01 << 12,
    ZYBleInteractSysStateMaskZOffLine           =   0x01 << 11,
    ZYBleInteractSysStateMaskYOffLine           =   0x01 << 10,
    ZYBleInteractSysStateMaskXOffLine           =   0x01 << 9,
    ZYBleInteractSysStateMaskIMUExeption        =   0x01 << 8,
    ZYBleInteractSysStateMaskTurnRound          =   0x01 << 5,
    ZYBleInteractSysStateMaskPower              =   0x01 ,
};

/**
 <#Description#> 稳定器电机开关机状态

 - ZYBleInteractDevicePowerStandby: 待机
 - ZYBleInteractDevicePowerOn: 开机
 */
typedef NS_ENUM(NSInteger, ZYBleInteractMotorPower) {
    ZYBleInteractMotorPowerUnkown          =   -1,
    ZYBleInteractMotorPowerStandby         =   0,
    ZYBleInteractMotorPowerOn              =   1,
};

/**
 <#Description#> 调试模式

 - ZYBleInteractDeviceDebugModeNormal: 正常
 - ZYBleInteractDeviceDebugModeAuxiliaryPower: 附属电源调式
 - ZYBleInteractDeviceDebugModeIMUDebug: IMU调试
 - ZYBleInteractDeviceDebugModeIMUAdjust: IMU补偿
 */
typedef NS_ENUM(NSUInteger, ZYBleInteractDeviceDebugMode) {
    ZYBleInteractDeviceDebugModeNormal                  =   0,
    ZYBleInteractDeviceDebugModeAuxiliaryPower          =   1,
    ZYBleInteractDeviceDebugModeIMUDebug                =   2,
    ZYBleInteractDeviceDebugModeIMUAdjust               =   3,
};

/**
 <#Description#> IMU控制寄存器掩码,未定义部分保留

 - ZYBleInteractIMUControlResigterClear: 清除IMU状态寄存器
 - ZYBleInteractIMUControlResigterAccelerate1: 加速计面1捕获
 - ZYBleInteractIMUControlResigterAccelerate2: 加速计面2捕获
 - ZYBleInteractIMUControlResigterAccelerate3: 加速计面3捕获
 - ZYBleInteractIMUControlResigterAccelerate4: 加速计面4捕获
 - ZYBleInteractIMUControlResigterAccelerate5: 加速计面5捕获
 - ZYBleInteractIMUControlResigterAccelerate6: 加速计面6捕获
 - ZYBleInteractIMUControlResigterAccelerateSixCalc: 加速计六面计算
 - ZYBleInteractIMUControlResigterGyroAdjust: 陀螺仪校准
 */
typedef NS_OPTIONS(NSUInteger, ZYBleInteractIMUControlResigterMask) {
    ZYBleInteractIMUControlResigterClear                =   0x00,
    ZYBleInteractIMUControlResigterAccelerate1          =   0x01,
    ZYBleInteractIMUControlResigterAccelerate2          =   0x02,
    ZYBleInteractIMUControlResigterAccelerate3          =   0x03,
    ZYBleInteractIMUControlResigterAccelerate4          =   0x04,
    ZYBleInteractIMUControlResigterAccelerate5          =   0x05,
    ZYBleInteractIMUControlResigterAccelerate6          =   0x06,
    ZYBleInteractIMUControlResigterAccelerateSixCalc    =   0x07,
    ZYBleInteractIMUControlResigterGyroAdjust           =   0x08,
};

/**
 <#Description#> IMU状态寄存器掩码,未定义部分保留

 - ZYBleInteractIMUStateResigterAccelerate1: 加速计完成面1捕获标志
 - ZYBleInteractIMUStateResigterAccelerate2: 加速计完成面2捕获标志
 - ZYBleInteractIMUStateResigterAccelerate3: 加速计完成面3捕获标志
 - ZYBleInteractIMUStateResigterAccelerate4: 加速计完成面4捕获标志
 - ZYBleInteractIMUStateResigterAccelerate5: 加速计完成面5捕获标志
 - ZYBleInteractIMUStateResigterAccelerate6: 加速计完成面6捕获标志
 - ZYBleInteractIMUStateResigterAccelerateAdjustFinish: 加速计校准完成标志
 - ZYBleInteractIMUStateResigterAccelerateAdjustError: 加速计校准错误标志
 - ZYBleInteractIMUStateResigterGyroFinish: 陀螺仪校准完成标志
 - ZYBleInteractIMUStateResigterTemperature: 温度通过标志
 - ZYBleInteractIMUStateResigterGyroAdjustSuccess: 陀螺仪校准通过标志
 - ZYBleInteractIMUStateResigterGyroTrackingReady: 陀螺仪运动跟踪就绪标志
 - ZYBleInteractIMUStateResigterIMUInitializeReady: IMU初始化就绪标志
 */
typedef NS_OPTIONS(NSUInteger, ZYBleInteractIMUStateResigterMask) {
    ZYBleInteractIMUStateResigterAccelerate1            =   0x01,
    ZYBleInteractIMUStateResigterAccelerate2            =   0x01 << 1,
    ZYBleInteractIMUStateResigterAccelerate3            =   0x01 << 2,
    ZYBleInteractIMUStateResigterAccelerate4            =   0x01 << 3,
    ZYBleInteractIMUStateResigterAccelerate5            =   0x01 << 4,
    ZYBleInteractIMUStateResigterAccelerate6            =   0x01 << 5,
    ZYBleInteractIMUStateResigterAccelerateAdjustFinish =   0x01 << 6,
    ZYBleInteractIMUStateResigterAccelerateAdjustError  =   0x01 << 7,
    ZYBleInteractIMUStateResigterGyroFinish             =   0x01 << 8,
    ZYBleInteractIMUStateResigterTemperature            =   0x01 << 12,
    ZYBleInteractIMUStateResigterGyroAdjustSuccess      =   0x01 << 13,
    ZYBleInteractIMUStateResigterGyroTrackingReady      =   0x01 << 14,
    ZYBleInteractIMUStateResigterIMUInitializeReady     =   0x01 << 15,

};

/**
 工作模式

 - ZYBleDeviceWorkModeFollow: 航向跟随模式
 - ZYBleDeviceWorkModeLock: 锁定模式
 - ZYBleDeviceWorkModeFullyFollow: 全跟随模式
 - ZYBleDeviceWorkModePOV: 横滚跟随模式
 */
typedef NS_ENUM(NSInteger, ZYBleDeviceWorkMode) {
    ZYBleDeviceWorkModeUnkown        =   -1,
    ZYBleDeviceWorkModeFollow        =   0,
    ZYBleDeviceWorkModeLock          =   1,
    ZYBleDeviceWorkModeFullyFollow   =   2,
    ZYBleDeviceWorkModePOV           =   3,
    ZYBleDeviceWorkModeGo            =   4,
    ZYBleDeviceWorkMode360           =   5,
};


/**
 相机厂商
 - ZYCameraManufacturerTypeClose: 关闭
 - ZYCameraManufacturerTypeCanon: 佳能
 - ZYCameraManufacturerTypeSony: 索尼
 - ZYCameraManufacturerTypePanasonic: 松下
 */
typedef NS_ENUM(NSInteger,ZYCameraManufacturerType) {
    ZYCameraManufacturerTypeClose = 0,
    ZYCameraManufacturerTypeCanon = 1,
    ZYCameraManufacturerTypeSony = 2,
    ZYCameraManufacturerTypePanasonic = 3,
    ZYCameraManufacturerTypeNikon = 4,
    ZYCameraManufacturerTypeCCS = 5,
    ZYCameraManufacturerTypeFUJI = 6,
    ZYCameraManufacturerTypeOLYMPUS = 7,
    ZYCameraManufacturerTypev_canon = 8,
    ZYCameraManufacturerTypev_sony = 9,
    ZYCameraManufacturerTypev_ZCAM = 10,
    ZYCameraManufacturerTypev_BMPCC = 11,
    ZYCameraManufacturerTypev_SIGMA = 12,
    ZYCameraManufacturerTypeCount,
};


/**
 电机力度

 - ZYBleDeviceMotorForceLow: 低
 - ZYBleDeviceMotorForceMedium: 中
 - ZYBleDeviceMotorForceHigh: 高

*/
typedef NS_ENUM(NSUInteger, ZYBleDeviceMotorForceMode) {
    ZYBleDeviceMotorForceLow        =   0,
    ZYBleDeviceMotorForceMedium     =   1,
    ZYBleDeviceMotorForceHigh       =   2,
    ZYBleDeviceMotorAutotuneing     =   3,//自动整定进行中状态
    ZYBleDeviceMotorAutotuned       =   4,//自动整定完成状态
    ZYBleDeviceMotorAutotuneLower   =   5,//较弱
    ZYBleDeviceMotorAutotuneLow     =   6,//弱
    ZYBleDeviceMotorAutotuneMedium_mid  =   7,//中小
    ZYBleDeviceMotorAutotuneMedium      =   8,//中
    ZYBleDeviceMotorAutotunehigh        =   9,//强
    ZYBleDeviceMotorAutotunehigh_mid    =   10,//较强
};

/**
  电机状态

 - ZYBleInteractMotorStateOffLine: 节点掉线
 - ZYBleInteractMotorStateOverheat: 过热
 - ZYBleInteractMotorStatePowerTrouble: 电源故障
 - ZYBleInteractMotorStateZeroException: 零点异常
 - ZYBleInteractMotorStateFeedbackException: 反馈异常
 - ZYBleInteractMotorStateWorking: 运行
 - ZYBleInteractMotorStateReady: 就绪
 */
typedef NS_OPTIONS(NSUInteger, ZYBleInteractMotorState) {
    ZYBleInteractMotorStateOffLine                  =   0x01 << 15,
    ZYBleInteractMotorStateOverheat                 =   0x01 << 11,
    ZYBleInteractMotorStatePowerTrouble             =   0x01 << 10,
    ZYBleInteractMotorStateZeroException            =   0x01 << 9,
    ZYBleInteractMotorStateFeedbackException        =   0x01 << 8,
    ZYBleInteractMotorStateWorking                  =   0x01 << 1,
    ZYBleInteractMotorStateReady                    =   0x01,
};

/**
 功能事件

 - ZYBleInteractDeviceEventReturn: 一键回中
 - ZYBleInteractDeviceEventBackhead: 回头模式
 */
typedef NS_ENUM(NSUInteger, ZYBleInteractDeviceEvent) {
    ZYBleInteractDeviceEventReturn         =   0,
    ZYBleInteractDeviceEventBackhead       =   1,
};

typedef NS_ENUM(NSInteger, ZYBleLocationSetPointPowered) {
    ZYBleLocationSetPointPoweredOFF = 0,
    ZYBleLocationSetPointPoweredOn  = 1
};

typedef NS_ENUM(NSInteger, ZYBleLocationSetPointControlRegisterType) {
    ZYBleLocationSetPointControlRegisterTypeClean = 0,
    ZYBleLocationSetPointControlRegisterTypeStart,
    ZYBleLocationSetPointControlRegisterTypeResvered,
    ZYBleLocationSetPointControlRegisterTypeStop,
};

typedef NS_ENUM(NSInteger, ZYBleLocationSetPointStateRegisterType) {
    ZYBleLocationSetPointStateRegisterTypeEnable      = 0,
    ZYBleLocationSetPointStateRegisterTypeStart       = 1,
    ZYBleLocationSetPointStateRegisterTypeCompleted   = 2,
    ZYBleLocationSetPointStateRegisterTypeStop        = 3,
    ZYBleLocationSetPointStateRegisterTypeResveredMin = 4,
    ZYBleLocationSetPointStateRegisterTypeResveredMax = 15
};
typedef NS_ENUM(NSInteger, ZYBleOneStepCalibrationType) {
    ZYBleOneStepCalibrationTypeBegain = 0x55AA,
    ZYBleOneStepCalibrationTypeEnd  = 0xA5A5
};

typedef NS_ENUM(NSInteger, ZYBleScapeCaptureCalibrationType) {
    ZYBleScapeCaptureCalibrationTypeLandscape = 0x55AA,
    ZYBleScapeCaptureCalibrationTypePortait  = 0xA5A5
};

typedef NS_ENUM(NSInteger, ZYBleControlSpeedDirectType) {
    ZYBleControlSpeedDirectTypeLow = 0x00,
    ZYBleControlSpeedDirectTypeMid = 0x01,
    ZYBleControlSpeedDirectTypeHeight = 0x02
};


typedef NS_ENUM(NSInteger, ZYBleContextualModelType) {
    ZYBleContextualModelTypeWalk = 0x00,
    ZYBleContextualModelTypeMove  = 0x01
};


#define KCLICK_KEY_TYPE_SINGLE 0x0000 // 按键类型 key_type 独立按键
#define KCLICK_KEY_TYPE_ENCODE 0x1000 // 按键类型 key_type 编码器
#define KCLICK_KEY_TYPE_PRESSURE 0x2000 // 按键类型 key_type 压感按键

#define kCLICK_GROUP    0x0000
#define kCLICK_GROUP_0  0x0000 //键组0
#define kCLICK_GROUP_1  0x0100 //键组1
#define kCLICK_GROUP_2  0x0200 //键组2
#define kCLICK_GROUP_3  0x0300 //键组3
#define kCLICK_GROUP_4  0x0400 //键组4

#define kCLICK_EVENT_NONE_NOTIFY_KEY        0x00
#define kCLICK_EVENT_PRESSED_NOTIFY_KEY     0x10
#define kCLICK_EVENT_RELEASE_NOTIFY_KEY     0x20
#define kCLICK_EVENT_CLICKED_NOTIFY_KEY     0x30
#define kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY  0x40
#define kCLICK_EVENT_PRESSED_3S_NOTIFY_KEY  0x50
#define kCLICK_EVENT_CLICKED_DOUBLE_NOTIFY_KEY  0x60
#define kCLICK_EVENT_CLICKED_TRIPLE_NOTIFY_KEY  0x70

#define kCLICK_EVENT_BUTTON_NONE_KEY        0x00
#define kCLICK_EVENT_BUTTON_UP_KEY          0x01
#define kCLICK_EVENT_BUTTON_DOWN_KEY        0x02
#define kCLICK_EVENT_BUTTON_MOD_KEY         0x03
#define kCLICK_EVENT_BUTTON_LEFT_KEY        0x04
#define kCLICK_EVENT_BUTTON_RIGHT_KEY       0x05
#define kCLICK_EVENT_BUTTON_PHOTOS_KEY      0x06
#define kCLICK_EVENT_BUTTON_T_KEY           0x07   //T键 长焦
#define kCLICK_EVENT_BUTTON_W_KEY           0x08   //W键 广角
#define kCLICK_EVENT_BUTTON_CW_KEY          0x09
#define kCLICK_EVENT_BUTTON_CCW_KEY         0x0A
#define kCLICK_EVENT_BUTTON_FN_KEY          0x0B
#define kCLICK_EVENT_BUTTON_CAPTURE_KEY     0x0C
#define kCLICK_EVENT_BUTTON_RECORD_KEY      0x0D
#define kCLICK_EVENT_BUTTON_FN_KEY_Down     0x0E // fn下
#define kCLICK_EVENT_BUTTON_PHOTO_KEY       0x0F //拍摄按键smoothX

#define kCLICK_EVENT_BUTTON1_UP_KEY         0x01
#define kCLICK_EVENT_BUTTON1_FOCUS_KEY      0x02   //对焦
#define kCLICK_EVENT_BUTTON1_LEFT_KEY       0x03
#define kCLICK_EVENT_BUTTON1_RIGHT_KEY      0x04
#define kCLICK_EVENT_BUTTON1_RECORD_KEY     0x05   //录像
#define kCLICK_EVENT_BUTTON1_ENC_CW_KEY     0x06
#define kCLICK_EVENT_BUTTON1_ENC_CCW_KEY    0x07
#define kCLICK_EVENT_BUTTON1_CAPTURE_KEY    0x08
#define kCLICK_EVENT_BUTTON1_DOWN_KEY       0x09
#define kCLICK_EVENT_BUTTON1_STEP_A_KEY     0x0A   //调焦步进A档
#define kCLICK_EVENT_BUTTON1_STEP_B_KEY     0x0B   //调焦步进B档
#define kCLICK_EVENT_BUTTON1_STEP_C_KEY     0x0C   //调焦步进C档

#define kCLICK_EVENT_BUTTON2_MENU_KEY           0x00
#define kCLICK_EVENT_BUTTON2_DISP_KEY           0x01  //DISP按键
#define kCLICK_EVENT_BUTTON2_UP_KEY             0x02
#define kCLICK_EVENT_BUTTON2_DOWN_KEY           0x03
#define kCLICK_EVENT_BUTTON2_LEFT_KEY           0x04
#define kCLICK_EVENT_BUTTON2_RIGHT_KEY          0x05
#define kCLICK_EVENT_BUTTON2_FLASH_KEY          0x06  //中键，闪光灯
#define kCLICK_EVENT_BUTTON2_SWITCH_KEY         0x07  //拨轮功能切换
#define kCLICK_EVENT_BUTTON2_STEP_B_KEY         0x08
#define kCLICK_EVENT_BUTTON2_PHOTOS_MODE_KEY    0x09
#define kCLICK_EVENT_BUTTON2_PHOTOS_KEY         0x0A
#define kCLICK_EVENT_BUTTON2_FRONT_CW_KEY       0x0B  //前拨轮+(顺时针)
#define kCLICK_EVENT_BUTTON2_FRONT_CCW_KEY      0x0C  //后拨轮-(逆时针)
#define kCLICK_EVENT_BUTTON2_SIDE_CW_KEY        0x0D  //侧拨轮+(顺时针)
#define kCLICK_EVENT_BUTTON2_SIDE_CCW_KEY       0x0E  //侧拨轮-(逆时针)

#define kCLICK_EVENT_BUTTON3_TV_KEY             0x01    //TV键
#define kCLICK_EVENT_BUTTON3_AV_KEY             0x02    //AV键
#define kCLICK_EVENT_BUTTON3_ISO_KEY            0x03    //ISO键
#define kCLICK_EVENT_BUTTON3_MOD_F_KEY          0x04    //模式键F
#define kCLICK_EVENT_BUTTON3_MOD_P_KEY          0x05    //模式键P
#define kCLICK_EVENT_BUTTON3_MOD_M_KEY          0x06    //模式键M
#define kCLICK_EVENT_BUTTON3_MOD_POV_KEY        0x07    //模式键POV
#define kCLICK_EVENT_BUTTON3_MIDDLE_KEY         0x08    //云台3轴归中按键
#define kCLICK_EVENT_BUTTON3_ENC_CW_KEY         0x09    //后滚轮（正）
#define kCLICK_EVENT_BUTTON3_ENC_CCW_KEY        0x0A    //后滚轮（反）
#define kCLICK_EVENT_BUTTON3_ZOOM_T_KEY         0x0B    //7级压感变焦T（长焦端）
#define kCLICK_EVENT_BUTTON3_ZOOM_W_KEY         0x0C    //7级压感变焦W（广角端）

#define kCLICK_EVENT_BUTTON4_MENU_KEY                   0x00        // 菜单
#define kCLICK_EVENT_BUTTON4_UP_KEY                     0x01        // 拨轮上
#define kCLICK_EVENT_BUTTON4_DOWN_KEY                   0x02        // 拨轮下
#define kCLICK_EVENT_BUTTON4_LEFT_KEY                   0x03        // 拨轮左
#define kCLICK_EVENT_BUTTON4_RIGHT_KEY                  0x04        // 拨轮右
#define kCLICK_EVENT_BUTTON4_LEVER_T_KEY                0x05        // 拨杆T（长焦端）
#define kCLICK_EVENT_BUTTON4_LEVER_W_KEY                0x06        // 拨杆W
#define kCLICK_EVENT_BUTTON4_TAKEPICBTN_KEY             0x07        // 录像/拍照、切换拍照/录像、切换前后摄像头，分别对应个于单击、双击、三击
#define kCLICK_EVENT_BUTTON4_WHEEL_CLOCKWISE_KEY        0x08        // 拨轮+(顺时针)
#define kCLICK_EVENT_BUTTON4_WHEEL_ANTICLOCKWISE_KEY    0x09        // 拨轮-(逆时针)
#define kCLICK_EVENT_BUTTON4_ZOOM_UP_KEY                0x0A        // 变焦+(顺时针)
#define kCLICK_EVENT_BUTTON4_ZOOM_DOWN_KEY              0x0B        // 变焦-(逆时针)
#define kCLICK_EVENT_BUTTON4_FOCUS_UP_KEY               0x0C        // 对焦+(顺时针)
#define kCLICK_EVENT_BUTTON4_FOCUS_DOWN_KEY             0x0D        // 对焦-(逆时针)

/**
 设备点击事件的状态
 
 - ZYBleClickNotifyEventNone: 无
 - ZYBleClickNotifyEventPressed: 按下
 - ZYBleClickNotifyEventRelease: 释放
 - ZYBleClickNotifyEventClicked: 单机
 - ZYBleClickNotifyEventPressed1S: 按下1秒
 - ZYBleClickNotifyEventPressed3S: 按下3秒
 */
typedef NS_ENUM(NSInteger,ZYBleClickNotifyEvent) {
    ZYBleClickNotifyEventNone        = 0,
    ZYBleClickNotifyEventPressed,
    ZYBleClickNotifyEventRelease,
    ZYBleClickNotifyEventClicked,
    ZYBleClickNotifyEventPressed1S,
    ZYBleClickNotifyEventPressed3S
};

/**
 <#Description#>获取调焦、变焦的状态

 - ZYBleInteractHDLFocusModeUnknown: 查询
 - ZYBleInteractHDLFocusModeMF: 对焦
 - ZYBleInteractHDLFocusModeWT: 变焦
 */
typedef NS_ENUM(NSInteger, ZYBleInteractHDLFocusModeType) {
    ZYBleInteractHDLFocusModeUnknown  = 0x0000,
    ZYBleInteractHDLFocusModeMF       = 0x0001,
    ZYBleInteractHDLFocusModeWT       = 0x0002,
};
/**
  设备工作模式改变的通知，稳定器主动通知，目前只支持云鹤界面 obj是工作模式
 */
extern NSString* const ZYDeviceWorkModeChangeNoti;
/**
 RDIS改变的通知 ZYBlRdisData对象 在object里面取
 */

extern NSString* const ZYDeviceRDISReciveNoti;


/**
  设备点击状态通知 带参数： userinfo: @{@"Key":@(NSData)}
 */
extern NSString* const Device_Button_Event_Notification_ResourceData  ;

/**
 设备状态通知 带参数： userinfo: @{@"Key":@(Dictionary)}
 */
extern NSString* const Device_State_Event_Notification_ResourceData  ;
/**
ZYBlOtherHeart心跳收到
*/
extern NSString* const ZYBlOtherHeartReciveNoti ;


/**
  设备蓝牙指令可用
 */
extern NSString* const Device_BLEReadyToUse;

/**
  设备蓝牙指令不可用
 */
extern NSString* const Device_BLEOffLine;


extern NSString* const Device_SYSTEM_ID_UUID;
extern NSString* const Device_FIRMWARE_UUID;
extern NSString* const Device_MANUFACTURER_UUID;

extern NSString* starCodeToNSString(NSUInteger code);


#pragma -mark 提取事件定义
#define KEY_BUTTON_PRESS_MASK 0x0F
#define KEY_BUTTON_PRESS_KEY(val)  (val&KEY_BUTTON_PRESS_MASK)
#define KEY_BUTTON_PRESS_EQUAL(val, eventVal) ((val&KEY_BUTTON_PRESS_MASK)==eventVal)

#define KEY_BUTTON_EVENT_MASK  0xF0
#define KEY_BUTTON_EVENT_PRESS(val)  (val&KEY_BUTTON_EVENT_MASK)
#define KEY_BUTTON_EVENT_PRESS_EQUAL(val, eventVal) ((val&KEY_BUTTON_EVENT_MASK)==eventVal)

#define makeEventParam(button, event) ((button&KEY_BUTTON_PRESS_MASK)|(event&KEY_BUTTON_EVENT_MASK))   //组成1字节按键事件
#define makeGroupParam(group, button, event) ((group&0xFF00)|makeEventParam(button, event))//组成2字节按键事件

#define KEY_BUTTON_KEY_TYPE_MASK  0x7000
#define KEY_BUTTON_KEY_Group_MASK  0x0F00
#define makeKeyTypeGroupParam(type,group, event, value) ((type&KEY_BUTTON_KEY_TYPE_MASK)|(group&KEY_BUTTON_KEY_Group_MASK)|(event&KEY_BUTTON_EVENT_MASK)|(value&KEY_BUTTON_PRESS_MASK))//组成2字节按键类型事件

#define KEY_BUTTON_EVENT_2_MASK  0x0F00
#define KEY_BUTTON_GROUP(val) (val&KEY_BUTTON_EVENT_2_MASK)

#import "common_def.h"

//#import "ZYBlRdisData.h"

#endif /* __ZYBLEPROTOCOL_H__ */
