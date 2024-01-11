//
//  ZYBlWiFiPhotoAllParamData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiPhotoAllParamData : ZYBlData

//以下与相机参数表对应
@property (nonatomic, readonly) NSUInteger Video_Resolution;                 //视频分辨率
@property (nonatomic, readonly) NSUInteger Video_Frame_Rate;                 //视频帧率
@property (nonatomic, readonly) NSUInteger Video_FOV;                        //视频帧率
@property (nonatomic, readonly) NSUInteger Video_AE;                         //视频曝光补偿
@property (nonatomic, readonly) NSUInteger Video_White_Balance;              //视频白平衡
@property (nonatomic, readonly) NSUInteger Video_ISO_Max;                    //视频感光度上限
@property (nonatomic, readonly) NSUInteger Video_ISO_Min;                    //视频感光度下限
@property (nonatomic, readonly) NSUInteger Video_ISO_limit;                  //视频感光度锁
@property (nonatomic, readonly) NSUInteger Video_AdvanceMode;               //视频高级模式
@property (nonatomic, readonly) NSUInteger Video_Interval;                   //视频拍照间隔
@property (nonatomic, readonly) NSUInteger Video_Loop_Interval;              //视频循环录像间隔
@property (nonatomic, readonly) NSUInteger Video_Timelapse_Interval;         //视频延时录像间隔
@property (nonatomic, readonly) NSUInteger Video_Shutter;                    //视频快门
@property (nonatomic, readonly) NSUInteger Video_Sub_Mode;                   //视频子模式

@property (nonatomic, readonly) NSUInteger Photo_Fov;                        //拍照视野
@property (nonatomic, readonly) NSUInteger Photo_AE;                         //拍照曝光补偿
@property (nonatomic, readonly) NSUInteger Photo_White_Balance;              //拍照白平衡
@property (nonatomic, readonly) NSUInteger Photo_ISO_Max;                    //拍照感光度上限
@property (nonatomic, readonly) NSUInteger Photo_ISO_Min;                    //拍照感光度下限
@property (nonatomic, readonly) NSUInteger Photo_AdvanceMode;               //拍照高级模式
@property (nonatomic, readonly) NSUInteger Photo_Shutter;                    //拍照快门
@property (nonatomic, readonly) NSUInteger Photo_Night_Shutter;              //拍照夜景拍摄快门
@property (nonatomic, readonly) NSUInteger Photo_Sub_Mode;                   //拍照子模式

@property (nonatomic, readonly) NSUInteger MultiShot_Fov;                    //多拍视野
@property (nonatomic, readonly) NSUInteger MultiShot_AE;                     //多拍曝光补偿
@property (nonatomic, readonly) NSUInteger MultiShot_White_Balance;          //多拍白平衡
@property (nonatomic, readonly) NSUInteger MultiShot_ISO_Max;                //多拍感光度上限
@property (nonatomic, readonly) NSUInteger MultiShot_ISO_Min;                //多拍感光度下限
@property (nonatomic, readonly) NSUInteger MultiShot_Interval;               //多拍感光度下限
@property (nonatomic, readonly) NSUInteger MultiShot_AdvanceMode;           //拍照高级模式
@property (nonatomic, readonly) NSUInteger MultiShot_Shutter;                //拍照快门
@property (nonatomic, readonly) NSUInteger MultiShot_Sub_Mode;               //拍照子模式

@property (nonatomic, readonly) NSUInteger Other_LCD_Sleep;                  //LCD超时睡眠时间
@property (nonatomic, readonly) NSUInteger Other_Default_Boot_Mode;          //默认启动模式
@property (nonatomic, readonly) NSUInteger Other_Video_Format;               //视频格式
@property (nonatomic, readonly) NSUInteger Other_Auto_Power_Off;             //自动关机
@property (nonatomic, readonly) NSUInteger Other_Current_Main_Mode;          //当前主模式
@property (nonatomic, readonly) NSUInteger Other_Current_Sub_Mode;           //当前子模式
@property (nonatomic, readonly) NSUInteger Other_Internal_Battery;           //内置电池
@property (nonatomic, readonly) NSUInteger Other_Battery_Level;              //内置电池电量
@property (nonatomic, readonly) NSUInteger Other_Processing_status;          //处理状态
@property (nonatomic, readonly) NSUInteger Other_SD_card;                    //SD卡状态
@property (nonatomic, readonly) NSUInteger Other_Available_Space;            //可用空间

@property (nonatomic, readonly) NSUInteger MultiShot_Capture_Rate;           //多拍速率
@property (nonatomic, readonly) NSUInteger Photo_Delay_Interval;             //延时拍照间隔
@property (nonatomic, readonly) NSUInteger Other_RecordOrPhoto;             //拍照或者录像



@end
