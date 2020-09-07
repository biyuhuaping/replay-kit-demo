//
//  RdisMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __RDISMESSAGE_H__
#define __RDISMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "BaseMessage.h"

NAMESPACE_ZY_BEGIN

class RdisMessage : public BaseMessage
{
public:
    RdisMessage();
    virtual ~RdisMessage();

#pragma pack(push)
#pragma pack(1)
    typedef struct {
        struct {
            uint8 systemReady:1;        //0         系统启动
            uint8 zoomer:1;             //1         变焦器连接
            uint8 re:1;                 //2         图传连接标志
            uint8 motorState:1;         //3         电机状态就绪
            uint8 paramListFlag:1;      //4         参数表解锁标志
            uint8 backword:1;           //5         回头模式标志
            uint8 calibration:1;        //6         进入校准状态
            uint8 followFocus:1;        //7         跟焦器连接
            uint8 IMUException:1;       //8         IMU异常
            uint8 MotorXOffLine:1;      //9         X电机掉线
            uint8 MotorYOffLine:1;      //10        Y电机掉线
            uint8 MotorZOffLine:1;      //11        Z电机掉线
            uint8 ICUOffLine:1;         //12        ICU掉线
            uint8 lowVoltage:1;         //13        欠压
            uint8 overcurrent:1;        //14        过流
            uint8 workStatus:1;         //15        工作状态，0表示待机
        } SYS_STATUS;                   //2Bytes    系统状态
        struct {
            uint16 mode:4;              //0~3       云台模式
            uint16 re:12;               //4~15      保留
        } SYS_MODE;                     //2Bytes    系统模式
        struct {
            uint8 type:4;               //0~3    参数数据类型
            uint8 vid:4;                //4~7    USB VID
            uint8 re:1;                 //8      保留
            uint8 recroding:1;          //9      相机录像标志
            uint8 living:1;             //10     相机开启实时预览标志
            uint8 conneting:1;          //11     相机已连接标志
            uint8 extend:4;             //12~15  扩展接口
        } PTP_DATA;                     //2Bytes 系统模式
        struct {
            uint32 data;                //0~31   参数
        } PARAM;                        //4Bytes 系统模式
    } RDIS_ALL_INFO;
#pragma pack(pop)

    void setRdisInfo(const RDIS_ALL_INFO& info);
    const RDIS_ALL_INFO& getRdisInfo() const;
private:
    RDIS_ALL_INFO m_rdis;
};

NAMESPACE_ZY_END

#endif /* __RDISMESSAGE_H__ */
