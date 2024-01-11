//
//  ZYDeviceManager.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/12/19.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZYStabilizerConnectManager.h"

#import "ZYDeviceStabilizer.h"
#import "ZYDeviceRemoteControl.h"
#import "ZYBleDeviceClient.h"
#import "ZYBleManager.h"

/**
 设备的链路

 - ZYConnectTypeNone: 没有链路
 - ZYConnectTypeBle: 只有蓝牙链路
 - ZYConnectTypeBleAndWifi: 蓝牙和Wi-Fi共存
 - ZYConnectTypeOnlyWifi: 只有Wi-Fi
 */
typedef NS_ENUM(NSInteger, ZYConnectType) {
    ZYConnectTypeNone = 0,
    ZYConnectTypeBle,
    ZYConnectTypeBleAndWifi,
    ZYConnectTypeOnlyWifi,
};

typedef NS_ENUM(NSInteger, ZYChoiceConnectType) {
    ZYChoiceConnectTypeBle = 0,
    ZYChoiceConnectTypeWifi,
};

extern NSString * const ConnectLinkChange;

typedef void(^MessageBlock)(void);
typedef NSDictionary *(^DicUserMessageBlock)(void);

@interface ZYDeviceManager : NSObject

@property (nonatomic,copy) MessageBlock connectMessageBlock;//连接上设备的时候

@property (nonatomic,copy) MessageBlock disConnectMessageBlock;//断开连接的设备时候

@property (nonatomic,copy) MessageBlock updateConnectMessageBlock;//连接的设备数据更新的时候

@property (nonatomic,copy) DicUserMessageBlock dicUserMessageBlock;//连接的设备数据更新的时候包含了NSString *userid;//用户id 用于记录数据 NSString *longitude;//经度 NSString *latitude;//纬度，两种block二选一

/**
 设置WiFi连接的设备
 */
@property (nonatomic)         ZYChoiceConnectType     choiceConnectType;


/**
 切换到ble连接
 return BLE是否Ready
 */
-(BOOL)changToBlConnect;

/**
 只开启Wi-Fi通路
 */
@property (nonatomic)         BOOL          enableOnlyWifi;


/**
 用于切换链路使用
 */
@property (nonatomic)         ZYConnectType  connectType;


/**
 设备管理类，单例

 @return 对象
 */
+(instancetype)defaultManager;


/**
 设备
 */
@property(nonatomic, strong)ZYDeviceStabilizer *stablizerDevice;

/**
 遥控设备
 */
@property(nonatomic, strong)ZYDeviceRemoteControl *remoteControlDevice;

#pragma -mark 后续的方法使用
/**
 升级的对象管理类
 */
@property(nonatomic, weak)ZYHardwareUpgradeManager *upgradeManager;
/**
 设备是否可用
 */
@property(nonatomic, assign)NSInteger workingState ;

/**
 序列号 | 型号
 */
@property(nonatomic, copy)NSString *modelNumberString;



/**
 连接上的设备

 @return stablizerDevice或者是remoteControlDevice
 */
-(ZYDeviceBase *)connectingDevice;

- (BOOL)isConnected;

-(BOOL)deviceReady;

-( ZYBleState)deviceState;

-(ZYBleDeviceInfo*)curDeviceInfo;

/**
 遥控器设备

 @return 是否是遥控器
 */
-(BOOL)isZWB_Device;

/**
  扫描蓝牙状态及其周围可用的蓝牙外设

 @param bleStatusHandler 蓝牙状态扫描结果
 @param deviceHandler 周围外设捕获结果
 */
-(void) scanStabalizerDevice:(void (^)(ZYBleState state))bleStatusHandler deviceHandler:(void (^)(ZYDeviceStabilizer* deviceInfo))deviceHandler;

-(void) scanRemoteControlDevice:(void (^)(ZYBleState state))bleStatusHandler deviceHandler:(void (^)(ZYDeviceRemoteControl* deviceInfo))deviceHandler;

-(void) scanStabalizerAndRemoteControlDevice:(void (^)(ZYBleState state))bleStatusHandler deviceHandler:(void (^)(ZYDeviceBase* deviceInfo))deviceHandler;

//获得HID连接的设备
-(void)retriveConnecting;

/**
 停止扫描
 */
-(void) stopScan;

/**
  通过扫描出的设备信息连接外设

 @param deviceInfo 外设信息
 @param deviceStatusHandler 外设连接状态
 */
-(void) connectDevice:(ZYDeviceBase*) deviceInfo completionHandler:(void (^)(ZYBleDeviceConnectionState state))deviceStatusHandler;

/**
 断开连接
 */
-(void) disconnectDevice:(void (^)(void))handler;


@end
