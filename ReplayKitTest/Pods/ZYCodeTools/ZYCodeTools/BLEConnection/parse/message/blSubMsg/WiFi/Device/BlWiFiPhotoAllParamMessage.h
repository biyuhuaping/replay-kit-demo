//
//  BlWiFiPhotoAllParamMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIPHOTOALLPARAMMESSAGE_H__
#define __BLWIFIPHOTOALLPARAMMESSAGE_H__

#include "BlWiFiPhotoMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiPhotoAllParamMessage : public BlWiFiPhotoMessage
{
public:
    BlWiFiPhotoAllParamMessage();
    virtual ~BlWiFiPhotoAllParamMessage();
    
    virtual int subPhotoType() const;
    
    bool buildRequest();
    virtual bool buildResponse(BYTE* data, int size);
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 photoCmdType;
    } MSG_BODY;
    //respond
    typedef struct {
        uint8 Video_Resolution;                 //视频分辨率
        uint8 Video_Frame_Rate;                 //视频帧率
        uint8 Video_FOV;                        //视频帧率
        uint8 Video_AE;                         //视频曝光补偿
        uint8 Video_White_Balance;              //视频白平衡
        uint8 Video_ISO_Max;                    //视频感光度上限
        uint8 Video_ISO_Min;                    //视频感光度下限
        uint8 Video_ISO_limit;                  //视频感光度锁
        uint8 Video_AdvanceMode;               //视频高级模式
        uint8 Video_Interval;                   //视频拍照间隔
        uint8 Video_Loop_Interval;              //视频循环录像间隔
        uint8 Video_Timelapse_Interval;         //视频延时录像间隔
        uint8 Video_Shutter;                    //视频快门
        uint8 Video_Sub_Mode;                   //视频子模式
        
        uint8 Photo_Fov;                        //拍照视野
        uint8 Photo_AE;                         //拍照曝光补偿
        uint8 Photo_White_Balance;              //拍照白平衡
        uint8 Photo_ISO_Max;                    //拍照感光度上限
        uint8 Photo_ISO_Min;                    //拍照感光度下限
        uint8 Photo_AdvanceMode;               //拍照高级模式
        uint8 Photo_Shutter;                    //拍照快门
        uint8 Photo_Night_Shutter;              //拍照夜景拍摄快门
        uint8 Photo_Sub_Mode;                   //拍照子模式
        
        uint8 MultiShot_Fov;                    //多拍视野
        uint8 MultiShot_AE;                     //多拍曝光补偿
        uint8 MultiShot_White_Balance;          //多拍白平衡
        uint8 MultiShot_ISO_Max;                //多拍感光度上限
        uint8 MultiShot_ISO_Min;                //多拍感光度下限
        uint8 MultiShot_Interval;               //多拍拍摄间隔
        uint8 MultiShot_AdvanceMode;            //拍照高级模式
        uint8 MultiShot_Shutter;                //拍照快门
        uint8 MultiShot_Sub_Mode;               //拍照子模式
        
        uint8 Other_LCD_Sleep;                  //LCD超时睡眠时间
        uint8 Other_Default_Boot_Mode;          //默认启动模式
        uint8 Other_Video_Format;               //视频格式
        uint8 Other_Auto_Power_Off;             //自动关机
        uint8 Other_Current_Main_Mode;          //当前主模式
        uint8 Other_Current_Sub_Mode;           //当前子模式
        uint8 Other_Internal_Battery;           //内置电池
        uint8 Other_Battery_Level;              //内置电池电量
        uint8 Other_Processing_status;          //处理状态
        uint8 Other_SD_card;                    //SD卡状态
        uint8 Other_Available_Space;            //可用空间
        
        uint8 MultiShot_Capture_Rate;           //多拍速率
        uint8 Photo_Delay_Interval;             //延时拍照间隔
        uint8 Other_RecordOrPhoto;              //拍照或者录像
        uint8 re4;
        uint8 re5;
        uint8 re6;
        uint8 re7;
        uint8 re8;
        uint8 re9;        
    } MSG_ALL_INFO;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    //respond
    MSG_ALL_INFO m_allInfo;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIPHOTOALLPARAMMESSAGE_H__ */
