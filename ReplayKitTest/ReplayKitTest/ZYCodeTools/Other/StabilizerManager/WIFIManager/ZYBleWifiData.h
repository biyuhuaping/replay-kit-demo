//
//  ZYBleWifiData.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/6/6.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBlWiFiPhotoAllParamData.h"

//extern NSString * const GPRFirstConnected;
//extern NSString * const GPRWIFISSIDChange;
//extern NSString * const GPRParameterChange;


/*!
 主模式

 - WiFimodeVideo: 视频
 - WiFimodePhoto: 照片
 - WiFimodeMultiShot: MultiShot
 */
typedef NS_ENUM(NSUInteger, WiFiMain_mode) {
    WiFiMain_modeVideo = 0,
    WiFiMain_modePhoto,
    WiFiMain_modeMultiShot,
    WiFiMain_modeOther,
    WiFiMain_mode_count,
};

typedef NS_ENUM(NSUInteger, WiFi_subMode) {
    WiFisubMode_Video_Single_Burst = 0,
    WiFisubMode_TLVideo_Continuous_TimeLapse,
    WiFisubMode_VideoPhoto_NightPhoto_NightLapse,
    WiFi_subMode_count,
};

// 相机的模式 ,通过mainMode 和 subMode 得到
typedef NS_ENUM(NSUInteger, WiFiMode) {
    WiFiModeVideo,
    WiFiModeVideoPhoto,
    WiFiModeVideoLoop,
    WiFiModePhoto,
    WiFiModePhotoNight,
    WiFiModePhotoContinuous,
    WiFiModeDelayRecording,
    WiFiModeDelayShoot,
    WiFiModeDelayNight,
};

 


typedef NS_ENUM(NSUInteger, WiFiVideo_para_Sub_Mode) {
    WiFiVideo_para_Sub_ModeVideo = 0,
    WiFiVideo_para_Sub_ModeTimeLapseVideo,
    WiFiVideo_para_Sub_ModeVideo_Photo,
    WiFiVideo_para_Sub_ModeLooping,
    WiFiVideo_para_Sub_Mode_count,
};

typedef NS_ENUM(NSUInteger, WiFiPhoto_para_Sub_Mode) {
    WiFiPhoto_para_Sub_ModeSingle = 1,
//    WiFiPhoto_para_Sub_ModeContinuous,
    WiFiPhoto_para_Sub_ModeNight,
    WiFiPhoto_para_Sub_Mode_count,
};

typedef NS_ENUM(NSUInteger, WiFiMultiShot_para_Sub_Mode) {
    WiFiMultiShot_para_Sub_Mode_Burst = 0, //连拍
    WiFiMultiShot_para_Sub_Mode_TimeLapse,
    WiFiMultiShot_para_Sub_Mode_Night_TimeLapse,
    WiFiMultiShot_para_Sub_Mode_count,
};

typedef NS_ENUM(NSUInteger, WiFiResolution) {
//    WiFiResolution4K_SuperView = 2,
    WiFiResolution4K = 1,
//    WiFiResolution2_7k_SuperView = 5,
//    WiFiResolution2_7k = 4,
    WiFiResolution2_7k_4_3 = 6,
    WiFiResolution1440 = 7,
//    WiFiResolution1080_SuperView = 8,
    WiFiResolution1080 = 9,
    WiFiResolution960 = 10,
//    WiFiResolution720_SuperView = 11,
    WiFiResolution720 = 12,
    WiFiResolution480 = 17,
    WiFiResolution4k_4_3 = 18,
//    WiFiResolutionWVGA = 13
};

typedef NS_ENUM(NSUInteger, WiFiFPS) {
    WiFiFPS240 = 0,
    WiFiFPS120,
    WiFiFPS100,
    WiFiFPS90,
    WiFiFPS80,
    WiFiFPS60,
    WiFiFPS50,
    WiFiFPS48,
    WiFiFPS30,
    WiFiFPS25,
    WiFiFPS24,
    WiFiFPS200 = 13,
};
typedef NS_ENUM(NSUInteger, WiFiFOV) {
    WiFiFOVVideoW = 0,
    WiFiFOVVideoM = 1,
    WiFiFOVVideoL = 4,
    WiFiFOVVideoN = 2,
    WiFiFOVVideoSuperView = 3,
    WiFiFOVPhotoW = WiFiFOVVideoW,
    WiFiFOVPhotoM = 8,
    WiFiFOVPhotoN = 9,
    WiFiFOVPhotoL = 10,
    WiFiFOVMultiShotW = WiFiFOVVideoW,
    WiFiFOVMultiShotM = WiFiFOVPhotoM,
    WiFiFOVMultiShotN = WiFiFOVPhotoN,
    WiFiFOVMultiShotL = WiFiFOVPhotoL,
};

typedef NS_ENUM(NSUInteger, WiFiInterval) {
    WiFiIntervalDelayRecordingSec1_2 = 0,
    WiFiIntervalDelayRecordingSec1,
    WiFiIntervalDelayRecordingSec2,
    WiFiIntervalDelayRecordingSec5,
    WiFiIntervalDelayRecordingSec10,
    WiFiIntervalDelayRecordingSec30,
    WiFiIntervalDelayRecordingSec60,
    
    WiFiIntervalVideoLoopMax = 0,
    WiFiIntervalVideoLoopMin5,
    WiFiIntervalVideoLoopMin20,
    WiFiIntervalVideoLoopMin60,
    WiFiIntervalVideoLoopMin120,
    
    WiFiIntervalVideoPhotoSec1_5 = 1,
    WiFiIntervalVideoPhotoSec1_10 ,
    WiFiIntervalVideoPhotoSec1_30 ,
    WiFiIntervalVideoPhotoSec1_60 ,
    
    WiFiIntervalDelayNightContinuous = 0,
    WiFiIntervalDelayNightSec4 = 4,
    WiFiIntervalDelayNightSec5 = 5,
    WiFiIntervalDelayNightSec10 = 10,
    WiFiIntervalDelayNightSec15 = 15,
    WiFiIntervalDelayNightSec20 = 20,
    WiFiIntervalDelayNightSec30 = 30,
    WiFiIntervalDelayNightSecMin1 = 60,
    WiFiIntervalDelayNightSecMin2 = 120,
    WiFiIntervalDelayNightSecMin5 = 300,
    WiFiIntervalDelayNightSecMin30 = 1800,
    WiFiIntervalDelayNightSecMin60 = 3600,
    
    WiFiIntervalDelayShootSec0_5 = 0,
    WiFiIntervalDelayShootSec1,
    WiFiIntervalDelayShootSec2,
    WiFiIntervalDelayShootSec5 = 5,
    WiFiIntervalDelayShootSec10 = 10,
    WiFiIntervalDelayShootSec30 = 30,
    WiFiIntervalDelayShootSec60 = 60,
};

typedef NS_ENUM(NSUInteger, WiFiRate) {
    WiFiRateSec3,
    WiFiRateSec5,
    WiFiRateSec10,
    WiFiRateSec10_2,
    WiFiRateSec10_3,
    WiFiRateSec30,
    WiFiRateSec30_2,
    WiFiRateSec30_3,
    WiFiRateSec30_6,
};

typedef NS_ENUM(NSUInteger, WiFiShutter) {
    WiFiShutterAuto,
    WiFiShutterSec2,
    WiFiShutterSec5,
    WiFiShutterSec10,
    WiFiShutterSec15,
    WiFiShutterSec20,
    WiFiShutterSec30,
    
    WiFiShutterVideo1_24 = 3,
    WiFiShutterVideo1_25,
    WiFiShutterVideo1_30,
    WiFiShutterVideo1_48,
    WiFiShutterVideo1_50,
    WiFiShutterVideo1_60,
    WiFiShutterVideo1_80,
    WiFiShutterVideo1_90,
    WiFiShutterVideo1_96,
    WiFiShutterVideo1_100,
    WiFiShutterVideo1_120,
    WiFiShutterVideo1_160,
    WiFiShutterVideo1_180,
    WiFiShutterVideo1_192,
    WiFiShutterVideo1_200 = 1,
    WiFiShutterVideo1_240 = 18,
    WiFiShutterVideo1_320,
    WiFiShutterVideo1_360,
    WiFiShutterVideo1_400,
    WiFiShutterVideo1_480,
    WiFiShutterVideo1_960,
    
    WiFiShutterDelayAuto = 0,
    WiFiShutterDelay1_125,
    WiFiShutterDelay1_250,
    WiFiShutterDelay1_500,
    WiFiShutterDelay1_1000,
    WiFiShutterDelay1_2000,
};

typedef NS_ENUM(NSUInteger, WiFiEV) {
    WiFiEV2,
    WiFiEV1_5,
    WiFiEV1,
    WiFiEV0_5,
    WiFiEV0,
    WiFiEV_0_5,
    WiFiEV_1,
    WiFiEV_1_5,
    WiFiEV_2,
};

typedef NS_ENUM(NSUInteger, WiFiISOMax) {
    WiFiISOMaxVideo6400,
    WiFiISOMaxVideo1600,
    WiFiISOMaxVideo400,
    WiFiISOMaxVideo3200,
    WiFiISOMaxVideo800,
    WiFiISOMaxVideo200 = 7,
    WiFiISOMaxVideo100 = 8,
    WiFiISOMaxPhoto400 = WiFiISOMaxVideo1600,
    WiFiISOMaxPhoto800 = WiFiISOMaxVideo6400,
    WiFiISOMaxPhoto200 = WiFiISOMaxVideo400,
    WiFiISOMaxPhoto100 = WiFiISOMaxVideo3200,
    WiFiISOMaxDelay400 = WiFiISOMaxPhoto400,
    WiFiISOMaxDelay800 = WiFiISOMaxPhoto800,
    WiFiISOMaxDelay200 = WiFiISOMaxPhoto200,
    WiFiISOMaxDelay100 = WiFiISOMaxPhoto100,
};

typedef NS_ENUM(NSUInteger, WiFiISOMin) {
    WiFiISOMin800,
    WiFiISOMin400,
    WiFiISOMin200,
    WiFiISOMin100,
};

typedef NS_ENUM(NSUInteger, WiFiWhite) {
    WiFiWhiteAuto = 0,
    WiFiWhite3000K = 1,
    WiFiWhite4000K = 5,
    WiFiWhite4800K = 6,
    WiFiWhite5500K = 2,
    WiFiWhite6000K = 7,
    WiFiWhite6500K = 3,
    WiFiWhiteNative = 4,
};

typedef NS_ENUM(NSUInteger, BatteryLevel) {
    BatteryLevelEmpty = 0,
    BatteryLevelLow = 1,
    BatteryLevelMiddle = 2,
    BatteryLevelFull = 3,
    BatteryLevelChargeing = 4,
};

typedef NS_ENUM(NSUInteger, AutoPowerOff) {
    AutoPowerOffNever = 0,
    AutoPowerOff5_min = 4,
    AutoPowerOff15_min = 6,
    AutoPowerOff30_min = 7,
//    AutoPowerOff4_min = 4,
};

typedef NS_ENUM(NSUInteger, VideoFormater) {
    VideoFormaterNTSC = 0,
    VideoFormaterPAL = 1,
};

typedef NS_ENUM(NSUInteger, LCDSleep) {
    LCDSleepNever = 0,
    LCDSleep1_min = 1,
    LCDSleep2_min = 2,
    LCDSleep3_min = 3,
};

typedef NS_ENUM(NSUInteger, DefaultLaunchMainMode) {
    DefaultLaunchMainModeVideo = 0,
    DefaultLaunchMainModePhoto = 1,
    DefaultLaunchMainModeMutil = 2,
};

/*
 记录gopro状态的模型类
 很多属性被KVO 监听,改属性名时要注意
 */
@interface ZYBleWifiData : NSObject

/**
 gopro是否在拍照或者录像中
 */
@property (nonatomic)       BOOL  shutting;

/**
 剩下的可拍张数
 */
@property (nonatomic)       NSUInteger remainderMaxPhotoCount;

/**
 剩下的多少秒
 */
@property (nonatomic)       NSUInteger remainderMaxVideoSecs;

/**
 SD Avaliable 1有内存，0内存不足
 */
@property (nonatomic)       NSUInteger SDEnough;


/**
 SD 状态 0，插入了SD卡，1为插入SD卡
 */
@property (nonatomic)       NSUInteger SDStatus;

/**
 电池电量
 */
@property (nonatomic)       BatteryLevel  battery;
/**
 电池是否可用
 */
@property (nonatomic)       BOOL  batteryAvaliable;

/**
 自动关机的时间间隔
 */
@property (nonatomic)       AutoPowerOff autoPowerOff;

/**
 视频格式
 */
@property (nonatomic)       VideoFormater videoFormater;

/**
 默认启动模式
 */
@property (nonatomic)        DefaultLaunchMainMode launchMainMode;

/**
 lcd
 */
@property (nonatomic)        LCDSleep lcdSleep;


#pragma -mark 其他设置

/*!
 gopro设备的Wi-Fi名字
 
 */
@property (nonatomic, copy) NSString *ssid;

/*!
 gopro设备的Wi-Fi秘密
 */
@property (nonatomic, copy) NSString *password;

/**
 当前应该显示的模式,可用于读取,00,01...
 */
@property (assign, nonatomic) WiFiMode wifiMode;



//以下与相机参数表对应
@property (nonatomic, assign) NSUInteger Video_Resolution;                 //视频分辨率
@property (nonatomic, assign) NSUInteger Video_Frame_Rate;                 //视频帧率
@property (nonatomic, assign) NSUInteger Video_FOV;                        //视频帧率
@property (nonatomic, assign) NSUInteger Video_AE;                         //视频曝光补偿
@property (nonatomic, assign) NSUInteger Video_White_Balance;              //视频白平衡
@property (nonatomic, assign) NSUInteger Video_ISO_Max;                    //视频感光度上限
@property (nonatomic, assign) NSUInteger Video_ISO_Min;                    //视频感光度下限
@property (nonatomic, assign) NSUInteger Video_ISO_limit;                  //视频感光度锁
@property (nonatomic, assign) NSUInteger Video_AdvanceMode;               //视频高级模式
@property (nonatomic, assign) NSUInteger Video_Interval;                   //视频拍照间隔
@property (nonatomic, assign) NSUInteger Video_Loop_Interval;              //视频循环录像间隔
@property (nonatomic, assign) NSUInteger Video_Timelapse_Interval;         //视频延时录像间隔
@property (nonatomic, assign) NSUInteger Video_Shutter;                    //视频快门
@property (nonatomic, assign) NSUInteger Video_Sub_Mode;                   //视频子模式

@property (nonatomic, assign) NSUInteger Photo_Fov;                        //拍照视野
@property (nonatomic, assign) NSUInteger Photo_AE;                         //拍照曝光补偿
@property (nonatomic, assign) NSUInteger Photo_White_Balance;              //拍照白平衡
@property (nonatomic, assign) NSUInteger Photo_ISO_Max;                    //拍照感光度上限
@property (nonatomic, assign) NSUInteger Photo_ISO_Min;                    //拍照感光度下限
@property (nonatomic, assign) NSUInteger Photo_AdvanceMode;               //拍照高级模式
@property (nonatomic, assign) NSUInteger Photo_Shutter;                    //拍照快门
@property (nonatomic, assign) NSUInteger Photo_Night_Shutter;              //拍照夜景拍摄快门
@property (nonatomic, assign) NSUInteger Photo_Sub_Mode;                   //拍照子模式

@property (nonatomic, assign) NSUInteger MultiShot_Fov;                    //多拍视野
@property (nonatomic, assign) NSUInteger MultiShot_AE;                     //多拍曝光补偿
@property (nonatomic, assign) NSUInteger MultiShot_White_Balance;          //多拍白平衡
@property (nonatomic, assign) NSUInteger MultiShot_ISO_Max;                //多拍感光度上限
@property (nonatomic, assign) NSUInteger MultiShot_ISO_Min;                //多拍感光度下限
@property (nonatomic, assign) NSUInteger MultiShot_Interval;               //多拍感光度下限
@property (nonatomic, assign) NSUInteger MultiShot_AdvanceMode;           //拍照高级模式
@property (nonatomic, assign) NSUInteger MultiShot_Shutter;                //拍照快门
@property (nonatomic, assign) NSUInteger MultiShot_Sub_Mode;               //拍照子模式

@property (nonatomic, assign) NSUInteger Other_Current_Main_Mode;          //当前主模式
@property (nonatomic, assign) NSUInteger Other_Current_Sub_Mode;           //当前子模式
@property (nonatomic, assign) NSUInteger MultiShot_Capture_Rate;           //
@property (nonatomic, assign) NSUInteger Photo_Delay_Interval;             //
@property (nonatomic, assign) NSUInteger Other_RecordOrPhoto;             //拍照或者录像


@property (copy, nonatomic) NSString *goproType;

/*!
 更新参数

 @param allParamData ZYBlWiFiPhotoAllParamData 对象
 */
-(void)updateValueWithZYBlWiFiPhotoAllParamData:(ZYBlWiFiPhotoAllParamData *)allParamData;


- (void)setCode:(NSInteger)code value:(NSInteger)value;

/**
 获取查询分类的文字描述
 
 @param catagory 需要查询的分类名
 @return 相对应的分类当前的文字描述 如4K,
 */
- (NSString *)gainNameFromCatagoryName:(NSString *)catagory;



@end
