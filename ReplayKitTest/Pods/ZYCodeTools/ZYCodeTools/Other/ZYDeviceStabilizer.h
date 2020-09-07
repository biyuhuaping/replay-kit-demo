//
//  ZYDeviceStabilizer.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/12/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//
#import "ZYProductKeyNoti.h"

#import "ZYStabilizerMotionManager.h"
#import "ZYStabilizerCalibrationManager.h"
#import "ZYHardwareUpgradeManager.h"
#import "ZYDeviceBase.h"
#import "ZYBleDeviceClient.h"
#import "ZYBleWiFiManager.h"
#import "ZYCameraWiFIManager.h"
#import "ZYSendRequest.h"
#import "ZYUpgradableInfoModel.h"
#import "ZYBlWiFiPhotoCameraInfoData.h"
#import "ZYOtheSynData.h"
#import "ZYBlOtherCmdMoveLineStatueData.h"
#import "ZYOffLineMoveDelay.h"
#import "ZYModuleUpgrade_New_Model.h"
#import "ZYProductSupportFunctionManager.h"
#import "ZYDeviceAccessories.h"

#define RDISImageBoxConnectingNoti @"RDISImageBoxConnectingNoti"
#define SerialNumberGetNoti        @"SerialNumberGetNoti" //获取到serialNo

typedef NS_ENUM(NSInteger,ZYStabilizeAxis) {
    ZYStabilizeAxis_Pitch = 0,
    ZYStabilizeAxis_Roll,
    ZYStabilizeAxis_Yaw,
};

typedef NS_ENUM(NSInteger,BatteryValueType) {
    BatteryValueTypeAvailable = 0,//batteryValue值可以使用
    BatteryValueTypeCharging,//充电中，batteryValue值可以使用
    BatteryValueTypeUnsupport,//不支持，batteryValue值不可以使用
};

typedef NS_ENUM(NSInteger,DeviceUpgradeCheckType) {
    DeviceUpgradeCheckTypeNoCheck = 0,//设备还没检查是否需要升级
    DeviceUpgradeCheckTypeCheckedNoUpgrade,//不需要升级
    DeviceUpgradeCheckTypeCheckedUpgrade,//需要升级
};

typedef void (^ZYDeviceRequestResultBlock)(ZYBleDeviceRequestState state, NSUInteger param);


typedef void (^ZYFileRequestResultBlock)(BOOL success, id info);

@interface ZYDeviceStabilizer : ZYDeviceBase<ZYSendRequest>


@property (nonatomic ) BOOL   needAppForceUpgrade;//需要app强制升级

/// 激活的状态当self.functionModel.activate == ActivateTypeNoSupport为ActiveStatueActive已经激活了的状态；
@property (nonatomic ) ActiveStatue activeState;//激活的状态
/*
 > 错误状态字段具体定义:
 > | bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0 |
 > | :--- |:--- |:--- |:--- |:--- |:--- |:--- |:--- |:--- |
 > | axislock | overheat | -- | -- | -- | -- | -- | -- |
 > |轴锁|过热|
userInfo:@{@"errorType":@(errorType)}；
 */
@property (nonatomic ) int          errorType;//错误状态
//检查升级
@property (nonatomic ) DeviceUpgradeCheckType upgradeCheckType;//是否检查了升级
/**
 启用第三方心跳，这时候遥感指令回通知app
 */
@property (nonatomic ) BOOL      enableHearOther;//启用第三方心跳，这时候遥感指令回通知app
/**
 设备搭载的子配件信息
 */
@property(nonatomic, strong)  ZYDeviceAccessories *accessory;
/**
 RDIS通知的图传配件是否插上了
 */
@property (nonatomic ) BOOL      RDISImageBoxConnecting;//

/**
 获取支持的设备类型
 */
@property(nonatomic, strong)  ZYProductSupportFunctionModel *functionModel;

/**
 是否支持新模块升级Json
 */
@property (nonatomic ) BOOL      isNewModulesJson;//


/**
 支持离线延时摄影
 */
@property (nonatomic ) BOOL      supportOffLineMoveDelay;//

/*!
 云鹤系列相机相关的管理工具
 */
@property (nonatomic, strong) ZYCameraWiFIManager      *cameraWifiManager;

/*!
 Wi-Fi相关的管理工具
 */
@property (nonatomic, strong) ZYBleWiFiManager      *wifiManager;

/**
 移动管理工具
 */
@property(nonatomic,strong)ZYStabilizerMotionManager *motionManager;

/**
 校准管理工具
 */
@property(nonatomic,strong)ZYStabilizerCalibrationManager *calibrationManager;

@property(nonatomic, strong)ZYHardwareUpgradeManager *hardwareUpgradeManager;


/**
 记录最后一次与设备进行同步的值
 */
@property (nonatomic, strong) ZYBleDeviceDataModel* dataCache;

/**
 记录最后一次与设备进行同步的值
 */
@property (nonatomic, strong) ZYOtheSynData* otherSynData;
/**
 记录离线移动延时摄影
 */
@property (nonatomic, strong) ZYOffLineMoveDelay* offLineMoveDelay;
/**
 序列号 | 型号
 */
@property(nonatomic, copy)NSString *modelNumberString;

/**
 产品型号
 */
@property(nonatomic, assign) NSUInteger modelNumber;

/**
 软件版本 例如：186
 */
@property(nonatomic, copy)NSString *softwareVersion;

/**
 用于显示的软件版本 例如：1.86
 */
@property(nonatomic, copy)NSString *displaySoftwareVersion;

/**
 当前连接的设备信息
 */
@property (nonatomic, readonly, strong) ZYBleDeviceInfo* curDeviceInfo;


/**
 <#Description#>云台电机工作状态
 */
@property (nonatomic, readonly) ZYBleInteractMotorPower motorState;

@property(nonatomic, strong)ZYBleDeviceInfo *connectingDevice;

@property(nonatomic, assign)float pitchSharpTurning ;

@property(nonatomic, assign)float rollSharpTurning ;

/**
 电池电量
 */
@property(nonatomic, assign)float batteryValue;

///  是否在充电中B
@property(nonatomic, assign)BatteryValueType valueType;

@property(nonatomic, assign)ZYBleDeviceMotorForceMode craneMotorForce ;

@property(nonatomic, assign)ZYCameraManufacturerType cameraManufacturer ;

@property(nonatomic, assign)ZYDeviceSeries deviceSeries ;

@property(nonatomic, readwrite)ZYBleInteractHDLFocusModeType handlerFocusMode ;

@property(nonatomic, copy)NSString *serialNo;


@property(nonatomic, strong)ZYModuleUpgrade_New_Model* moduleNewModel;

@property(nonatomic, strong)NSArray<ZYUpgradableInfoModel*>* moduleUpgradeInfos;

/// 升级的信息是否获取到了
-(BOOL)upgradeMessageReady;
/**
 <#Description#>设置电机的工作模式

 @param mode 电机工作模式
 @param handler 设置结果
 */
-(void) enableMotor:(ZYBleInteractMotorPower)mode compeletion:(void (^)(BOOL success, ZYBleInteractMotorPower originalMode))handler;

/**
 <#Description#>触发回中功能

 @param handler 结果
 */
-(BOOL) goToMiddle:(void (^)(BOOL success))handler;
- (BOOL)motion_goToMiddle:(void (^)(ZYBleDeviceRequestState state))handler;

/**
 <#Description#>触发回头功能

 @param handler 结果
 */
-(BOOL) goToBack:(void (^)(BOOL success))handler;

/**
 <#Description#>通知拍照键单击

 @param handler 结果
 @return 设备支持此功能返回YES
 */
-(BOOL) notifyPhotoButtonClick:(void (^)(BOOL success))handler;

/*
 <#Description#>通知拍照键双击

 @param handler 结果
 @return 设备支持此功能返回YES
 */
-(BOOL) notifyPhotoButtonDoubleClick:(void (^)(BOOL success))handler;

/**
 设置云鹤力度

 */
-(void)setCraneMotorForceMode:(ZYBleDeviceMotorForceMode)model handler:(void(^)(BOOL success))handler;

/**
 设置相机厂商
 @param manufacturerType 厂商类型
 */
-(void)setCameraManufacturerWithType:(ZYCameraManufacturerType)manufacturerType Handler:(void(^)(BOOL success))handler;


/**
 获取相机厂商
 */
-(void)readCameraManufacturerHandler:(void(^)(BOOL success,ZYCameraManufacturerType type))handler;

/**
 读取微调
 */
-(void)readSharpTurningSettingsWithHandler:(void(^)(BOOL success, float pitchSharpTurning, float rollSharpTurning))handler;

/**
 设置微调
 */
-(void)writeSharpTurningSettingsWithHandler:(float)pitchSharpTurning roll:(float)rollSharpTurning handler:(void(^)(BOOL success))handler;

/**
 开始IMU补偿模式

 @param handler 结果回调
 */
-(void)beginIMUAdjust:(void(^)(BOOL success))handler;

/**
 设置微调

 @param pitchSharpTurning 俯仰微调
 @param rollSharpTurning 横滚微调
 @param handler 结果回调
 */
-(void)setSharpTurningSetting:(float)pitchSharpTurning roll:(float)rollSharpTurning handler:(void(^)(BOOL success))handler;

/**
 结束IMU补偿模式

 @param handler 结果回调
 */
-(void)endIMUAdjust:(void(^)(BOOL success))handler;

/**
 保存设置
 */
-(void)saveSettingsWithHandler:(void(^)(BOOL success))handler;

/**
 查询生产序列号 不支持的机器返回@""
 */
-(void)queryProductionSerialNo:(void(^)(NSString* serialNo))handler;

/**
 <#Description#>设置对焦变焦模式

 @param flag YES:变焦 NO:对焦
 */
-(void)setFoucsMode:(ZYBleInteractHDLFocusModeType)flag handler:(void(^)(BOOL success))handler;

/**
 <#Description#>获取对焦模式

 @param handler 获取结束时的回调
 */
-(void)getFoucsMode:(void(^)(ZYBleInteractHDLFocusModeType mode))handler;
#pragma mark - 发送code的request

/**
 发送请求
 
 @param code 指令代号
 @param handler 发送指令的结果回调
 */
-(void) sendRequestCode:(NSUInteger)code completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;
/**
 发送请求
 
 @param code 指令代号
 @param data 指令参数
 @param handler 发送指令的结果回调
 */
-(void) sendRequestCode:(NSUInteger)code data:(NSNumber*)data completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;

/**

 <#Description#>获取升级模块信息

 @param handler 获取结束时的回调
 */
-(void)queryUpgradableInfos:(void(^)(NSArray<ZYUpgradableInfoModel*>* infos))handler;

#pragma mark - Battery

-(void)beginqueryBatteryValueLoop;

-(void)endBatteryLoopQuery;

-(void)queryBatteryWithRepeatCount:(int)repeatCount completed:(void(^)(void))completed;
#pragma mark - Hardware upgrade


#pragma mark - Auto Connecttion

//-(void)removeAutoConnectAndDisconnectPeripheralName:(NSString *)peripheralName completed:(void (^)())handler;

/**************************                     黑卡相机                     ******************************/

/**
 变焦事件

 @param isAddZoom 是否是变焦+
 @param isStart 是否事件开始
 @return jieguo
 */
- (BOOL)zoomStatusChanged:(BOOL)isAddZoom isStart:(BOOL)isStart result:(void (^)(BOOL success))handler;

/**
 设置稳定器搭载类型

 @param isMobile 是否是手机（不是手机则为相机）
 */
- (void)setStabilizerCarryDeviceTypeIsMobile:(BOOL)isMobile complete:(void(^)(BOOL success, ZYBlOtherDeviceTypeData *info))complete;

/**
 获取稳定器搭载类型
 
 */
- (void)getStabilizerCarryDeviceType:(void(^)(BOOL success, ZYBlOtherDeviceTypeData *info))complete;


/**
 设置所搭载相机厂商

 @param type 相机厂商
 */
- (void)setRXCameraManufacturer:(ZYBl_CameraManufactureType)type complete:(ZYFileRequestResultBlock)complete;


/**
 获取所搭载相机厂商
 */
- (void)getRXCameraManufacturerWithComplete:(ZYFileRequestResultBlock)complete;

/************************     json文件操作       *********************/
/**
 检验是否支持该格式
 */
- (void)checkJsonFileFormatAvalueble:(ZYBlOtherCustomFileDataFormat)format direct:(int)direct complete:(ZYFileRequestResultBlock)complete;

/**
 检验是否支持该格式，若通过则获取json数据
 */
- (void)queryJsonFileIfFormatAvalueble:(ZYBlOtherCustomFileDataFormat)format complete:(ZYFileRequestResultBlock)complete;


/**
 发送数据，支持4种类型数据发送，内部会自动转成二进制格式

 @param fileInfo 数据格式，目前仅限 NSData，NSArray，NSDictionary， NSString
 @param format 格式  support pathShot pathPoint
 */
- (void)sendJsonFileData:(id)fileInfo format:(ZYBlOtherCustomFileDataFormat)format complete:(ZYFileRequestResultBlock)complete;

/**
 获取配件是否连接上

 @param complete 配件
 */
-(void)querySubTypeConnectionComplete:(void(^)(BOOL success, ZYBlOtherSyncData *info))complete;



/**
 配置request的链路和解码类型

 @param request request
 */
-(void)configRequest:(ZYBleDeviceRequest *)request;

/// 支持跟踪的指令
-(BOOL)newtrackingCodeSupport;
/// 支持信道的指令
-(BOOL)newWifiChannelCodeSupport;
/// 重定义键值列表
-(BOOL)supportKeyRedfineSetting;
/// 支持hid
-(Ble_hidType)supportBle_Hid;
/*
<!--
可重定义键值列表
    默认为[]，列表为空
    当有自定义按键是按照如下格式[[键组,键值1,[事件1,事件2,事件3]],[键组,键值2,[事件1,事件2,事件3]]]
    举例:[[0,3,[3,6,7]],[0,11,[3,6]]]代表键组0内模式按键的单击双击三击可重定义，以及键组0内fn按键单击双击可重定义
 -->
*/
-(NSMutableArray *)keyredefine;
//电机力度
-(NSMutableArray *)motorStrength;
//电机力度的调整范围
/*
 <!--
          此设备支持的电机力度自由设置
          *支持该功能的机型 App将显示相关页面
          轴依次为 俯仰 横滚 航向
          默认为[[0,0],[0,0],[0,0]]
          举例:云鹤2s 自定义电机力度
 -->
 */
-(NSMutableArray *)motorStrengthCustom;
/*
<!--
         此设备支持的电机力度自由设置
         *支持该功能的机型 App将显示相关页面
         0 不支持
         1 支持
         默认为0 不支持
         举例:云鹤2s 支持电机力度校准通知
-->
 */
-(BOOL) motorStrengthAdjustNotify;

/// 发送激活码
/// @param activeState 激活状态
/// @param randomData 激活码长度为11位
/// @param activateDate 激活日期
/// @param handler 回调
-(void)sendActivateWithActivateState:(ActiveStatue)activeState randomData:(NSData *)randomData activateDate:(NSDate *)activateDate completionHandler:(void(^)(ZYBleDeviceRequestState state, ZYBlSendActiveKeyData *sendData))handler;
//检查是否激活 needActivate为NO的时候表示设备不需要激活，跳过激活流程
-(void)checkActivateCompletionHandler:(void(^)(BOOL needActivate,ZYBleDeviceRequestState state, ZYBlCheckActiveInfoData *checkActive))handler;
//开始一键校准,监听通知 ZYOtherSynDataOneStepCalibrationProgressNoti得到进度
-(void)begainOneStepCalibrationCompletionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;
//结束一键校准
-(void)endOneStepCalibrationCompletionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;

/// 横拍模式和竖拍模式
/// @param enable yes 横拍 No 竖拍
/// @param handler 回调
-(void)enableLandscape:(BOOL)enableLandscape completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;

/// 情景模式设置
/// @param type 类型
/// @param handler 回调
-(void)setContextualModel:(ZYBleContextualModelType)type completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler;
/// 情景模式读取
/// @param handler 回调
-(void)readContextualModelCompletionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler;
/// 控制速度读取
/// @param handler 回调
-(void)setControlSpeedDirect:(ZYBleControlSpeedDirectType)type completionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler;
/// 控制速度
/// @param handler 回调
-(void)readControlSpeedDirectCompletionHandler:(void (^)(ZYBleDeviceRequestState, NSUInteger))handler;

/// 激活之后检查升级
-(void)doUpgradeCheckAfterActivate;


/// trackmode的设置和读取
/// @param isRead 0 读取 1 设置
/// @param trackMode 0 关闭 1 开启，当isRead == 0时候，无意义
/// @param handler 回调用
-(void)trackModeIsRead:(BOOL)isRead trackMode:(int)trackMode completionHandler:(void(^)(ZYBleDeviceRequestState state, ZYCMDTrackingModeData *data))handler;

/// trackAnchor的设置和读取
/// @param isRead 0 读取 1 设置
/// @param anchorX 喵点的X 0 当isRead == 0时候，无意义
/// @param anchorY 喵点的Y 0 当isRead == 0时候，无意义
/// @param handler 回调用
-(void)trackAnchorIsRead:(BOOL)isRead anchorX:(int)anchorX anchorY:(int)anchorY completionHandler:(void(^)(ZYBleDeviceRequestState state, ZYCMDTrackingAnchorData *data))handler;

/// 以下为力矩设置pitch roll yaw
/// @param isRead 是否是读取
/// @param value 当为读取的时候不生效，设置的时候可以使用
/// @param handler 回掉
-(void)pitchPowerSetOrRead:(BOOL)isRead value:(int )value completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;
-(void)rollPowerSetOrRead:(BOOL)isRead value:(int )value completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;
-(void)yawPowerSetOrRead:(BOOL)isRead value:(int )value completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;

@end
