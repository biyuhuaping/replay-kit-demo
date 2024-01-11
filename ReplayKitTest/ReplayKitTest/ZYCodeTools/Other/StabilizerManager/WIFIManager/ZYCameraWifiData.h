//
//  ZYCameraWifiData.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/7/25.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//
extern NSString * const CameraWIFISSIDChange;
extern NSString * const ZYDC_SupportArgumentCallback;
extern NSString * const ZYDC_CameraArgumentCallback;
extern NSString * const ZYDC_CameraControlRecordState;
extern NSString * const ZYDC_CameraControlGetAllPara;
extern NSString * const ZYDC_CameraLiveSteamEnable;
extern NSString * const ZYDC_CameraModeChange ;
extern NSString * const ZYDC_isCameraConnectingChange; //相机连接改变
extern NSString * const ZYDC_ReImageTransfer; //重新拉流
extern NSString * const ZYDC_ReImageTransferQualityControl;//图传质量的通知

extern NSString * const ZYDC_ImageTransferSupportWithLine;//数据线是否支持图传
extern NSString * const ZYDC_CameraSupportFocus;//是否支持对焦
typedef NS_ENUM(NSUInteger, ZYCameraControlRecord) {
    ZYCameraControlRecordDefault,
    ZYCameraControlRecordVideoStart,//录像开始
    ZYCameraControlRecordVideoStop, //录像结束
    ZYCameraControlTakePhotoStart, //拍照开始
    ZYCameraControlTakePhotoStop, //拍照结束
};

typedef NS_ENUM(NSUInteger, ZYCameraWifiParaCode) {
    ZYCameraWifiParaCodeF_Number = 0,
    ZYCameraWifiParaCodeShutterSpeed,
    ZYCameraWifiParaCodeISO,
    ZYCameraWifiParaCodeEV,
    ZYCameraWifiParaCodeWB,
    ZYCameraWifiParaCodeFocusmode,//闪光灯模式
    ZYCameraWifiParaCodeManualfocus,
    ZYCameraWifiParaCodeFlashmode,
    ZYCameraWifiParaCodeImagequality,//相机的影像质量
    ZYCameraWifiParaCodeCapturemode,
    ZYCameraWifiParaCodeZoom,
    ZYCameraWifiParaCodeBatterylevel,
    ZYCameraWifiParaCodeAspectratio,//照片纵横比
    ZYCameraWifiParaCodeImagesize,//影像尺寸"Large""Medium""Small"
    ZYCameraWifiParaCodePhotograp,//"1":相机可以拍照，"0":相机不能拍照,   默认可以拍照
    ZYCameraWifiParaCodeVideotape,//"1":相机可以录像，"0":相机不能录像,   默认可以录像
    
    ZYCameraWifiParaCodeAfarea = 17,//afarea(对焦区域配置)格式为：“X坐标(范围0~65535)” + ‘x’ +     “y坐标(范围0~65535)” ，例如 设置X坐标为1127，Y坐标为 176，则传入的参数值就为 “1127x176”

    ZYCameraWifiParaCodeLineControlType = 117,//线控类型 如“commonUsb”， “sonyUsb” ,都存放在稳定器配置Json中
    ZYCameraWifiParaCodeLineControlJsonURL = 118,//稳定器配置json文件路径
    ZYCameraWifiParaCodeImageTransferAddressAndPara = 119,//获取图传播放地址及参数，为路径+参数+丢包时显示策略"udp://192.168.2.1:6000","mjpeg"，"0"
    ZYCameraWifiParaCodeImageTransferQualityControl = 120,//PictureTrsCtrlQuality图传质量控制，以字符串形式表示 “1024x680，25，3000”--如果不支持码率和帧数的配置直接放空---如 “1024x680，，”
    ZYCameraWifiParaCodeImageTransferEnable = 121,//相机是否可以图传
    ZYCameraWifiParaCodeCameraConnected = 122,//相机是否连接上后来定义为相机是否可以控制iso等
    ZYCameraWifiParaCodeJsonUrl = 123,//json路径,如果没有就用相机名字加地址
    ZYCameraWifiParaCodeRecordTime = 124,//相机的录像时间
    ZYCameraWifiParaCodeCameraName = 125,
    ZYCameraWifiParaCodeCameraMode = 126,
    ZYCameraWifiParaCodeCameraControlPower = 127,//|获取设备控制权 |127      "1":持有控制权，"0":没有控制权     |
    ZYCameraWifiParaCodeSupplyControlPower = 128,//申请控制权限 0：申请 1.同意 2.拒绝 格式为状态加要切换的设备名称，以字符串表示 如 ”0,XX的iphone6”表示 XX的iphone6 申请控制权
    ZYCameraWifiParaCodeConfigVisitCamera = 129,//0：关闭 1.打开 再打开相机实时预览功能时，需要设置为1，并等待设置成功的通知，相机切换模式可能需要1秒以上，等待时间建议2秒以上。在关闭预览时需要关闭该模式并等待成功的状态
    ZYCameraWifiParaCodeSupportVisitCameraSource = 130,//支持访问相机的资源0：不支持 1.支持
    ZYCameraWifiParaCodeUSB_VID = 254,
    ZYCameraWifiParaCodeAll = 255,
    ZYCameraWifiParaMoveDelayRecord = 256,//延时摄影 0结束 1开始 2取消退出
    ZYCameraWifiParaFullView = 257,//全景 0结束 1开始 2取消退出
    ZYCameraWifiParaNormalRecord = 258,//普通录像 0结束 1开始 2取消退出
    ZYCameraWifiParaCodeAllPara01 = 0x01FF,//所有配置（0x0100-0x01FE）
    ZYCameraWifiCodeSystemStatus_R = 0x0200,// WIFI控制模块系统状态
    ZYCameraWifiDeviceCategory_R = 0x0201,// WIFI控制模块产品序列号
    ZYCameraWifiCanUpgradeSoftware = 0x0202,// WIFI控制模块可升级模块如:"{模块代号1,模块版本1,升级链路1,模块后缀1},不在使用
    ZYCameraWifiProductionNo = 0x0203,// 生产序列号（bit59-0）
    ZYCameraWifiUpgradeProgess = 0x0204,// 升级进度0x0206一起使用
    ZYCameraWifiModelDownMode = 0x0205,// 模块文件下载方式 0 ：整包下载 1：分包下载
    ZYCameraWifiModelUpgradeNeedWait = 0x0206,// 上上传之后是否需要等待，和0x0204一起使用
    ZYCameraWifiParaUpgradeReady = 0x0207,//升级是否准备就续 //不在使用
    ZYCameraWifiParaCodeAllPara02 = 0x02FF,//所有配置（0x0200-0x02FE）

};


typedef NS_ENUM(NSUInteger,STSTUS_WIFI_STATUS) {
    STSTUS_WIFI_STATUS_NONE,//未开启
    STSTUS_WIFI_STATUS_EN,//wifi开启
    STSTUS_WIFI_STATUS_ERROR,//错误状态
};

typedef NS_ENUM(NSUInteger,ZYCameraWifiGetParaState) {
    ZYCameraWifiGetParaState_unknow,//默认
    ZYCameraWifiGetParaState_begain,//wifi开启
    ZYCameraWifiGetParaState_error,//获取参数出差错
    ZYCameraWifiGetParaState_finish,//获取参数完成
};

#import <Foundation/Foundation.h>
#import "ZYAllControlData.h"
#import "ZYSendRequest.h"
@interface ZYCameraWifiData : NSObject

@property (nonatomic)         ZYCameraWifiGetParaState  getAllParaState;//获取所有参数状态

@property (nonatomic, weak)   id<ZYSendRequest> sendDelegate;

@property (nonatomic)         BOOL  containTimelapse;//含有"timelapse":{"ALL":["disableLive"]},拍照的时候关闭图传

/*!
 设备的Wi-Fi名字
 
 */
@property (nonatomic, copy) NSString *ssid;

/*!
 设备的Wi-Fi秘密
 */
@property (nonatomic, copy) NSString *password;


/**
 Wi-Fi的状态
 */
@property (nonatomic)      STSTUS_WIFI_STATUS  wifiStatus;

@property (nonatomic)         BOOL photograpEnable;//"1":相机可以拍照，"0":相机不能拍照,   默认可以拍照
@property (nonatomic)         BOOL videotapeEnable;//"1":相机可以录像，"0":相机不能录像,   默认可以录像

/**
 线控类型 117
 */
@property (nonatomic, copy) NSString *lineControlType;//跟118相关 如“commonUsb”， “sonyUsb” 都存放在稳定器配置Json中
@property (nonatomic)         BOOL   imageTransferSupportWithLine;//数据线是否支持图传，默认为YES
/**
 稳定器配置json文件路径 118
 */
@property (nonatomic, copy) NSString *lineControlJsonURL;//记得读取

/**
 用于lineControlJsonURL的json支持列表
 */
@property (nonatomic, strong)   NSDictionary *lineControlDic;//线控的json

/**
 获取图传播放地址及参数，119
 */
@property (nonatomic, copy) NSString *imageTransferAddressAndPara;//为路径+参数+丢包时显示策略"udp://192.168.2.1:6000","mjpeg"，"0"
@property (nonatomic, readonly) NSString *imageTransferAddress;//为视频流的播放路径119-0，不支持为nil
@property (nonatomic, readonly) NSString *decodeType;//为视频流解码类型119-1，不支持为nil

/**
 是否是私有协议

 @return 是否是私有协议
 */
-(BOOL)isPrivateTranProtocol;
@property (nonatomic, readonly) NSString *ThrowPacket;//为视频流的丢包策略119-2，不支持为nil

@property (nonatomic)       NSString *suppplyControlPower;//128 申请控制权限,不要更改原数据
@property (nonatomic, readonly,copy)       NSString *suppplyControlPowerName;//128 申请控制权限

@property (nonatomic)       NSString *configVisitCameraSource;//129 支持访问相机的资源 0：关闭 1.打开 切换需要大概5s时间，等待通知
@property (nonatomic)       NSString *supportVisitCameraSource;//130 支持访问相机的资源 0：不支持 1.支持 2从控设备获取到的值

// 129指令回调是否需要通知给上层
@property (nonatomic, assign) BOOL needNotifiVisitCameraSource;

/**
 能够进入到相机资源界面

 @return 能够进入
 */
-(BOOL)canEnterCameraSource;

@property (nonatomic)       NSString *cameraControlPower;//127 相机控制权




/**
 图传质量控制 120
 */
@property (nonatomic, copy) NSString *imageTransferQualityControl;


/**
 相机图传是否可以使用121
 */
@property (nonatomic)         BOOL imageTransferEnable;//相机图传是否可以使用


/*!
 相机连接状态 122
 */
@property (nonatomic) BOOL isCameraConnecting;

/*!
 相机拍照和录像状态
 */
@property (nonatomic) ZYCameraControlRecord controlRecord;

#pragma -mark 参数

/**
 用于云鹤3系列f。 0
 */
@property (nonatomic, copy) NSString *fNumber;


/**
 用于云鹤3系列快门。1
 */
@property (nonatomic, copy) NSString *shutterSpeed;


/**
 用于云鹤3系列iso。2
 */
@property (nonatomic, copy) NSString *iso;


/**
 用于云鹤3 相机的EV。3
 */
@property (nonatomic, copy) NSString *ev;


/**
 用于云鹤3 相机的WB 4
 */
@property (nonatomic, copy) NSString *wb;


/**
 用于云鹤3 相机的focusmode 5
 */
@property (nonatomic, copy) NSString *focusmode;


/**
 用于云鹤3 相机的模式，比如手动模式“M” 6
 */
@property (nonatomic, copy) NSString *manualfocus;

/**
 用于云鹤3 相机的模式，比如手动模式“M” 7
 */
@property (nonatomic, copy) NSString *flashmode;


/**
 用于云鹤3 相机的模式，比如手动模式“M” 8
 */
@property (nonatomic, copy) NSString *imagequality;


/**
 用于云鹤3 相机的模式，比如手动模式“M” 9
 */
@property (nonatomic, copy) NSString *capturemode;

/**
 用于云鹤3 相机的zoom 是否支持 10
 */
@property (nonatomic, copy) NSString *zoom;

/**
 用于云鹤3 相机的电量 是否支持 11|batterylevel |11 |"0"--"100"  |0%--100%              |---  电池电量
 */
@property (nonatomic, copy) NSString *batterylevel;

/**
 用于云鹤3 相机的照片纵横比 是否支持 12
 */
@property (nonatomic, copy) NSString *aspectratio;

/**
 用于云鹤3 相机的照片纵横比 是否支持 13
 */
@property (nonatomic, copy) NSString *imagesize;

/**
 用于对焦区域配置 是否支持 17，格式为：“X坐标(范围0~65535)” + ‘x’ +     “y坐标(范围0~65535)” ，例如 设置X坐标为1127，Y坐标为 176，则传入的参数值就为 “1127x176”
 */
@property (nonatomic, copy) NSString *afarea;



/*!
 设备的jsonURL。123
 */
@property (nonatomic, copy) NSString *jsonUrl;

/*!
 设备的recordTime。124
 */
@property (nonatomic, copy) NSString *recordTotalTime;

/*!
 设备的相机名字，用于获取json。125
 
 */
@property (nonatomic, copy) NSString *cameraName;

/**
 用于云鹤3 相机的模式，126
 */
@property (nonatomic, copy) NSString *cameraMode;

/**
 用于云鹤3系列的json支持列表
 */
@property (nonatomic, strong)   NSDictionary *cameraDic;

/**
 获取json

 @param handler 回掉
 */
-(void)getAllCameraDic:(void (^)(NSDictionary *cameraDic))handler;

/**
 获取支持的图传质量控制

 @param handler 回掉
 */
-(void)getImageTransferQualityControlhandler:(void (^)(NSArray *))handler;

/**
  设置参数

 @param code 相机参数指令
 @param value 参数值
 @param handler 回调
 */
-(void)setCameraWithCode:(ZYCameraWifiParaCode)code value:(NSString *)value handler:(void (^)(BOOL success))handler;


/**
 清除数据
 */
-(void)cleanData;

/**
 获取相机时间
 */
- (NSTimeInterval)getcurrentCameraTime;

#pragma -mark getValue

/**
 获取参数

 @param num 获取参数
 @param count 获取几次
 */
-(void)getCameraDataWithNum:(NSUInteger)num withCount:(int)count;

/**
 配置参数

 @return <#return value description#>
 */
#pragma -mark getValue
-(void)getCameraDataWithNum:(NSUInteger)num withCount:(int)count completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;

#pragma mark 兼容RDIS版本 是否正在录像
@property (nonatomic)         BOOL RDISVersion;//默认是YES
@property (nonatomic)         BOOL RDISRecording;//是否正在录像
/**
 获取参数
 
 @param num 获取参数
 @param count 获取几次
 @param handler 回掉
 */
-(void)getCameraDataWithNum:(NSUInteger)num withCount:(int)count completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;
@end
