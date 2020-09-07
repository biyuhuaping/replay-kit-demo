//
//  ZYCameraWiFIManager.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/7/25.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//
#import <Foundation/Foundation.h>

extern NSString * const CameraWIFIEnable;
extern NSString * const ZYWifiStatusNoti; //Wi-Fi状态的通知
extern NSString * const ZYCamera_AlbumVisit_Notifi; // 访问相册状态回调
extern NSString * const ZYCamera_DoRetryDataSuccess; // 重新获取数据
#import "ZYCameraWifiData.h"
#import "ZYSendRequest.h"

typedef NS_ENUM(NSUInteger, ZYWifiStatus) {
    ZYWifiStatusUnkown,//默认状态，还没切换到Wi-Fi链路过
    ZYWifiStatusCantSendData,//Wi-Fi链路断开，不能进行通信
    ZYWifiStatusIsReady, //Wi-Fi链路通畅
    
};

typedef NS_ENUM(NSUInteger, ZYCameraFunctonType) {
    ZYCameraFunctonTypeMoveDelayRecord,//延时摄影
    ZYCameraFunctonTypeFullView,//全景
    ZYCameraFunctonTypeNormalRecord, //普通录像
    
};

typedef NS_ENUM(NSUInteger, ZYCameraFunctonTypeStatus) {
    ZYCameraFunctonTypeStatusEnd,//结束
    ZYCameraFunctonTypeStatusBegain,//开始
    ZYCameraFunctonTypeStatusCancel, //取消
    
};

// 相册访问事件类型
typedef NS_ENUM(NSInteger, ZYCameraAlbumActionType) {
    ZYCameraAlbumActionType_None,                           // 默认，无操作
    ZYCameraAlbumActionType_PicVideo_Enter,                 // 进入,访问相册图片和视频，
    ZYCameraAlbumActionType_PicVideo_Exit,                  // 退出,访问相册图片和视频，
    ZYCameraAlbumActionType_SDCardLut_Enter,                // 进入，访问lut资源
    ZYCameraAlbumActionType_SDCardLut_Exit,                 // 退出，访问lut资源
};

typedef NS_ENUM(NSInteger, ZYCameraAlbumActionState) {
    ZYCameraAlbumActionState_Idle,                // 默认，空闲
    ZYCameraAlbumActionState_Waiting,             // 等待回复中
    ZYCameraAlbumActionState_Timeout,             // 操作超时
    ZYCameraAlbumActionState_Success,             // 操作成功
    ZYCameraAlbumActionState_Fail,                // 操作失败
};

@protocol ZYCameraWiFIManagerDelegate<NSObject>

-(void)changeConnectWithWifiEnable:(BOOL)wifiEnable;

@end

@interface ZYCameraWiFIManager : NSObject


//////////////////////////////////////////////   访问相册功能用（包含查看照片、视频，查看及下载Lut资源）

// 是否处于活跃状态，当调用 tryToVisitAlbum:isEnter:方法时开始，超时或者收到对应指令129回复时结束
@property (nonatomic, assign) BOOL albumActionActive;

// 事件类型，访问图片视频资源还是lut资源
@property (nonatomic, assign) ZYCameraAlbumActionType albumActionType;

// 访问状态
@property (nonatomic, assign) ZYCameraAlbumActionState albumActionState;

/**
 尝试访问相册，可能失败

 @param actionType 事件类型
 */
- (void)tryToVisitAlbum:(ZYCameraAlbumActionType)actionType;

//////////////////////////////////////////////




@property (nonatomic,copy)    NSString    *modelNameString;//产品的系列号,用于发送不同的获取系统状态


@property (nonatomic)         ZYWifiStatus   isWifiReady;//Wi-Fi链路可以使用

@property (nonatomic, weak)   id<ZYSendRequest> sendDelegate;

@property (nonatomic)         BOOL    wifiEnable;


/*!
 云鹤系列相机设备的数据模型
 */
@property (nonatomic, readonly) ZYCameraWifiData  *cameraData;

/**
 用于全景，移动延时摄影，普通录像的开始结束取消

 @param type ZYCameraFunctonType
 @param status ZYCameraFunctonTypeStatus
 @param handler 状态回掉
 @return 是否成功设置的回掉
 */
-(BOOL)appFunctionWithType:(ZYCameraFunctonType)type status:(ZYCameraFunctonTypeStatus)status handler:(void (^)(BOOL success))handler;
#pragma -mark zoom
/**
 相机添加变焦，按键组3键值及对应功能
 
 @param isWOrT 只有WT
 @param level level  0~7等级
 @param handler 设置成功的回掉
 @return 是否成功设置的回掉
 */
-(BOOL)zoomCameraWithIsW:(BOOL)isWOrT level:(NSInteger)level handler:(void (^)(BOOL success))handler;

/**
 相机添加调焦，按键组1键值及对应功能

 @param isClockwise CW  CCW
 @param handler 设置成功的回掉
 @return 是否成功设置的回掉
 */
-(BOOL)focusWithClockwise:(BOOL)isClockwise handler:(void (^)(BOOL success))handler;


/**
 调焦，对应WT

 @param value 对应的值
 @param handler 设置成功的回掉
 @return 是否成功设置的回掉
 */
-(BOOL)zoomWithValue:(NSUInteger)value handler:(void (^)(BOOL success))handler;

/**
 获取WT

 @param handler 设置成功的回掉
 */
-(void)zoomValueHandler:(void (^)(NSUInteger value))handler;

/**
 变焦，对应AF

 @param value 对应的值
 @param handler 设置成功的回掉
 @return 是否成功设置的回掉
 */
-(BOOL)focusWithValue:(NSUInteger)value handler:(void (^)(BOOL success))handler;


/**
 获取AF
 
 @param handler 设置成功的回掉
 */
-(void)focusValueHandler:(void (^)(NSUInteger value))handler;
/**
 相机iso调节
 
 @param isoValue ISO的值
 @param handler 回掉
 @return 是否成功设置的回掉
 */
-(BOOL)configCameraWithISO:(NSString *)isoValue handler:(void (^)(BOOL success))handler;

/**
 相机ev调节
 
 @param evValue ev的值
 @param handler 回掉
 @return 是否成功设置的回掉
 */
-(BOOL)configCameraWithEV:(NSString *)evValue handler:(void (^)(BOOL success))handler;


-(BOOL)configCameraWithShutterTime:(NSString *)shutterTime handler:(void (^)(BOOL success))handler;
-(BOOL)configCameraWithAperture:(NSString *)aperture handler:(void (^)(BOOL))handler;

/**
 设置相机控制器
 0：申请 1.同意 2.拒绝 格式为状态加要切换的设备名称，以字符串表示 如 ”0,XX的iphone6”表示 XX的iphone6 申请控制权
 @param controlPower 控制器
 @param handler 控制权的回掉
 @return 是否设置
 */
-(BOOL)supplyLineCameraControlPower:(NSString *)controlPower handler:(void (^)(BOOL success))handler;

/**
 相机wb调节
 
 @param wbValue ev的值
 @param handler 回掉
 @return 是否成功设置的回掉
 */
-(BOOL)configCameraWithWB:(NSString *)wbValue handler:(void (^)(BOOL success))handler;

/**
 相机对焦区域配置

 @param x X坐标为 (范围0~65535)
 @param y Y坐标 (范围0~65535)
 @param handler 回掉
 @return 是否成功设置的回掉
 */
-(BOOL)configCameraWithAFareaWithXloction:(int )x yLocation:(int)y handler:(void (^)(BOOL success))handler;


/**
 ZYCameraWifiParaCodeImageTransferQualityControl 120调节
 
 @param qualityValue qualityValue的值  --如果不支持码率和帧数的配置直接放空---如 “1024x680，，”
 @param handler 回掉
 @return 是否成功设置的回掉
 */
-(BOOL)configCameraWithimageTransferQualityControl:(NSString *)qualityValue handler:(void (^)(BOOL success))handler;

/**
 配置视频流解码类型

 @param decodeType h264 h265等
 @param handler 回掉
 @return 是否成功设置的回掉
 */
-(BOOL)configCameraTransitionDecodeType:(NSString *)decodeType handler:(void (^)(BOOL success))handler;

/**
访问相册的配置
 
 @param enableVisitCamera
 @param handler 回掉
 @return 是否成功设置的回掉
 */
-(BOOL)configVisitCameraSource:(BOOL)enableVisitCamera handler:(void (^)(BOOL success))handler;

/**
 支持的所有ISO
 @param argument 相机的参数类型，比如ISO，exposurecompensation
 @param handler 在主线程回掉
 */
-(void)supportArgument:(NSString *)argument  handler:(void (^)(NSArray *))handler;

/**
 支持的所有设置的ISO，exposurecompensation等

 @param handler 数组
 */
-(void)allSupportArgumentHandler:(void (^)(NSArray *))handler;

/**
 支持的图传质量的高，中，低等
 
 @param handler 数组
 */
-(void)supportImageTransQualityArgumentHandler:(void (^)(NSArray *))handler;

/**
 开关图传
 
 @param enable 开关
 @param handler 回掉
 */
-(void)enableImageTransport:(BOOL)enable handler:(void (^)(BOOL success))handler;

/**
 开关图传
 
 @param enable 开关
 @param noti 是否需要通知
 @param handler 回掉
 */
-(void)enableImageTransport:(BOOL)enable noti:(BOOL)noti handler:(void (^)(BOOL success))handler;


/**
 开关图传
 
 @param enable 开关
 @param noti 是否需要通知
 @param handler 回掉
 */
-(void)enableImageTransport:(BOOL)enable noti:(BOOL)noti sendCode:(BOOL)sendCode handler:(void (^)(BOOL success))handler;


/**
 查询基本的数据
 */

-(void)doBaseQueryData:(void (^)(void))completed changeToWifiConnection:(void (^)(BOOL wifiEnable))wifiConnection;
/**
  是否支持相机参数的设置
 @return 是否支持相机参数的设置
 */
+(BOOL)supportCameraSetting;

#pragma -mark wifi相关

/**
 重置wifi

 @param handler 回掉
 */
-(void)resetWifiCompletionHandler:(void(^)(BOOL success))handler;

/**
 开启或者关闭Wi-Fi模块

 @param enable 开启或者关闭
 @param handler 回掉
 */
-(void)enableWifi:(BOOL)enable completionHandler:(void(^)(BOOL success))handler;

/**
 清除DHCP

 @param handler 回掉
 */
-(void)clearDHCPCompletionHandler:(void(^)(BOOL success))handler;

/**
 获取SSID

 @param handler handler 回掉
 */
-(void)getSSIDcompletionHandler:(void(^)(NSString *ssid))handler;
/**
 获取密码
 
 @param handler handler 回掉
 */
-(void)getPwdCompletionHandler:(void(^)(NSString *pwd))handler;

/**
  设置密码

 @param password 密码
 @param handler 回掉
 */
-(void)setPassword:(NSString *)password completionHandler:(void(^)(BOOL success))handler;

/**
 获取wifi的状态

 @param handler Wi-Fi的状态
 */
-(void)getWifiStatusCompletionHandler:(void(^)(STSTUS_WIFI_STATUS statue))handler;
/**
 自动连接Wi-Fi
 */
-(void)autoConnectWifi;

/**
 需要显示自动连接

 @return 是否显示
 */
-(BOOL)needShowAutoConnectWifi;

/**
 检查Wi-Fi是否持续可用

 @return Wi-Fi是否持续可用
 */
-(BOOL)checkWifiSustain;

/**
 发送消息给稳定器设备
 */
-(void)sendMessage;

/**
清除数据
 */
-(void)clearData;

/**
 扫描/获取WiFi周围的信道信息 扫描时间为5秒 如果需要获取或者再次扫描 请在5秒之后再调用此接口
 @param type 0代表扫描 1代表获取
 @param handler scanSuccess为扫描是否成功 results数组为获取到的信道信息 格式为"信道状态，信道，信道强度"
 */
- (void)scanWiFiInfosWithType:(uint8_t)type :(void(^)(BOOL scanSuccess, NSArray *results))handler;


/**
 返回当前WiFi模块支持的信道列表

 @param handler 返回数组为支持的信道列表
 */
- (void)getWiFiList:(void(^)(NSArray<NSString *> *results))handler;


/**
 获取当前WiFi的信道

 @param handler status: 0代表未知 1代表为手动信道 2代表自动信道模式 channelStr表示当前信道
 */
- (void)getWiFiChannel:(void(^)(NSString *channelStr, uint8_t status))handler;


/**
 设置WiFi信道

 @param status 0代表未知 1代表为手动信道 2代表自动信道模式 当设置自动信道时 channel参数不生效
 @param channel 信道字符串
 @param handler 是否成功
 */
- (void)setWiFiChannelWithStatus:(uint8_t)status channel:(NSString *)channel handler:(void(^)(bool isSuccess))handler;
@end
