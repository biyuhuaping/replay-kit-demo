//
//  SPCCommandDefine.h
//  ZYCamera
//
//  Created by liuxing on 2018/7/26.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//
#import <CoreGraphics/CoreGraphics.h>

#ifndef SPCCommandDefine_h
#define SPCCommandDefine_h


#pragma mark - single instance

/// wifi manager
#define WiFiManager [ZYDeviceManager defaultManager].stablizerDevice.wifiManager


#pragma mark - custom define

// 设备对应的设备号
#define SN_Crane3Lab 1328
#define SN_WeeBillLab 1329

#define GoPro5 @"HERO5"
#define IsHero5 [WiFiManager.wifiData.goproType isEqualToString:GoPro5] // is hero 5?

#define SPCLS(key) NSLocalizedString(key, nil)

#ifdef DEBUG
// Debug 模式的代码...
//#define SPCLog(format, ...) NSLog(format, ...)

# define SPCLog(fmt, ...) NSLog(( fmt), ##__VA_ARGS__)
#define SPCAssert(condition) assert(condition)

#else
// Release 模式的代码...
//#define SPCLog(format, ...)
# define SPCLog(fmt, ...) nil
#define SPCAssert(condition) nil

#endif

/// 主题色 黄色
#define SPC_SELECTED_COLOR [UIColor colorWithRed:247/255.0 green:197/255.0 blue:40/255.0 alpha:1/1.0]
/// 主题背景色 黑色
#define SPC_SELECTED_BGCOLOR [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1/1.0]




#pragma mark - parameter item setting
static const CGFloat SPCParameterItemTopDistance = 10.0;
static const CGFloat SPCParameterItemHeight = 30.0;
static const CGFloat SPCParameterItemWidth = 56.5;
static const CGFloat SPCParameterItemRadius = 4.0;

#pragma mark - shootButton setting
static const CGFloat SPCShootButtonMaxCircleDia = 72.0;
static const CGFloat SPCShootButtonMinCircleDia = 54.0;


#pragma mark - custom enum


/// 模式
typedef NS_ENUM(int, SPCMode) {
    
    SPCModeVideo,
    SPCModeVideoPhoto,
    SPCModeVideoLoop,
    
    SPCModePhoto ,
    SPCModePhotoNightScene,
    SPCModePhotoContinuous,
    
    SPCModeDelayRecording,
    SPCModeDelayShoot,
    SPCModeDelayNightScene
};

typedef enum {
    ZYWiFiScanStateUnknown = 0,
    ZYWiFiScanStateWifiOff,//Wi-Fi没有开启
    ZYWiFiScanStateWifiOn,//Wi-Fi开启
    ZYWiFiScanStateWillScan,//将要扫描
    ZYWiFiScanStateScaning,//扫描过程中
    ZYWiFiScanStateScaned,//扫描完成
    ZYWiFiScanStateScanStop,//扫描停止
    ZYWiFiScanStateTimeOut,//超时
} ZYWiFiScanState;

typedef enum {
    ZYWiFiConnentStateUnknown = 0,
    ZYWiFiConnentStateWillConnect,//将要连接
    ZYWiFiConnentStateConnecting,//Wi-Fi正在连接中
    ZYWiFiConnentStateConnected,//Wi-Fi连接上
    ZYWiFiConnentStateConnectFail,//Wi-Fi连接失败
    ZYWiFiConnentStateWillDisconnect,//将要断开连接
    ZYWiFiConnentStateDisconnected,//Wi-Fi断开连接
    ZYWiFiConnentStateDisconnectFail,//Wi-Fi断开连接失败
    ZYWiFiConnentStateTimeOut,//超时
} ZYWiFiConnentState;

typedef NS_ENUM(NSUInteger, SPCCatagoryQueryCode) {
    SPCCatagoryQueryCodeNone = 0,
    // 视频 queryCode
    SPCCatagoryQueryCode_videoResolution = 2,
    SPCCatagoryQueryCode_videoFrameRate = 3,
    SPCCatagoryQueryCode_videoFOV = 4,
    SPCCatagoryQueryCode_videoEVComp = 15,
    SPCCatagoryQueryCode_videoWhiteBlance = 11,
    SPCCatagoryQueryCode_videoISOMax = 13,
    SPCCatagoryQueryCode_videoISOMin = 102,
    SPCCatagoryQueryCode_videoISOLimit = 74,
    SPCCatagoryQueryCode_videoInterval = 7,
    SPCCatagoryQueryCode_videoLoopingInterval = 6,
    SPCCatagoryQueryCode_videoTimelapseInterval = 5,
    SPCCatagoryQueryCode_videoManualExposure = 73,
    
    // 照片 queryCode
    SPCCatagoryQueryCode_photoFOV = 17,
    SPCCatagoryQueryCode_photoEVComp = 26,
    SPCCatagoryQueryCode_photoWhiteBlance = 22,
    SPCCatagoryQueryCode_photoISOMax = 24,
    SPCCatagoryQueryCode_photoISOMin = 75,
    SPCCatagoryQueryCode_photoShutterAuto = 97,
    SPCCatagoryQueryCode_photoNightExposure = 19,
    
    // 多拍 queryCode
    SPCCatagoryQueryCode_multiFOV = 28,
    SPCCatagoryQueryCode_multiEVComp = 39,
    SPCCatagoryQueryCode_multiWhiteBlance = 35,
    SPCCatagoryQueryCode_multiISOMax = 37,
    SPCCatagoryQueryCode_multiISOMin = 76,
    SPCCatagoryQueryCode_multiShutter = 31,
    SPCCatagoryQueryCode_multiNightLapseInterval = 32,
    SPCCatagoryQueryCode_multiContinuousShootRate = 29,
    SPCCatagoryQueryCode_multiShotInterval = 30,
    
    // 其他 queryCode
//    SPCCatagoryQueryCode_otherLCDSleep = 51,
//    SPCCatagoryQueryCode_otherDefaultStartUpMode = 89,
//    SPCCatagoryQueryCode_otherVideoFormat = 57,
//    SPCCatagoryQueryCode_otherAutoShutDown = 59,
    
};

typedef NSString * WiFiModeInquireCommand NS_STRING_ENUM;
static WiFiModeInquireCommand const WiFiModeInquireCommandVideo = @"0-0";
static WiFiModeInquireCommand const WiFiModeInquireCommandDelayRecording = @"0-1";
static WiFiModeInquireCommand const WiFiModeInquireCommandVideoPhoto = @"0-2";
static WiFiModeInquireCommand const WiFiModeInquireCommandVideoLoop = @"0-3";
static WiFiModeInquireCommand const WiFiModeInquireCommandPhoto = @"1-1";
static WiFiModeInquireCommand const WiFiModeInquireCommandPhotoNight = @"1-2";
static WiFiModeInquireCommand const WiFiModeInquireCommandPhotoContinuous = @"2-0";
static WiFiModeInquireCommand const WiFiModeInquireCommandDelayShoot = @"2-1";
static WiFiModeInquireCommand const WiFiModeInquireCommandDelayNight = @"2-2";


typedef NS_ENUM(NSUInteger, WiFiInquireCode) {
    WiFiInquireCodeMainMode = 171,
    WiFiInquireCodeSubMode = 172,
    WiFiInquireCodeShutting = 136,
    WiFiInquireCodeSDStatus = 161,
    WiFiInquireCodeSDEnough = 182,
    WiFiInquireCodeBatteryLevel = 130,
    WiFiInquireCodeBatteryAvaliable = 129,
    WiFiInquireCodeLCDSleep = 51,
    WiFiInquireCodeLaunchMainMode = 89,
    WiFiInquireCodeVideoFormater = 57,
    WiFiInquireCodeAutoPowerOff = 59,
    WiFiInquireCodeMaxPhotoCount = 162,
    WiFiInquireCodeMaxVideoSecs = 163,
    WiFiInquireCodeShootOrRecord = 189,
    
};

/// 第一次连接的通知
static NSString * const GPRFirstConnected = @"GPRFirstConnected";

/// Wi-Fi 改变的通知名
static NSString * const GPRWIFISSIDChange = @"GPRWIFISSIDChange";

/// 相机参数改变的通知名
static NSString * const GPRParameterChange = @"GPRParameterChange";

/// gopro 进入相册的通知
static NSString * const GPRIntoAlbum = @"GPRIntoAlbum";

/// gopro 模式切换通知名
static NSString * const GPRModeChange = @"GPRModeChange";

/// spc 相机界面的右上角的每个图标的宽度
static CGFloat const SPCCameraTopRightItemWidth = 43.0f;

#endif /* SPCCommandDefine_h */
