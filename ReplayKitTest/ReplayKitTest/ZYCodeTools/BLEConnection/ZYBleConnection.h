//
//  ZYBleConnection.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/6.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYConnection.h"
@class CBPeripheral;
@class ZYBleDeviceRequest;
@class ZYBleDeviceDataModel;
@class ZYBleDeviceDispacther;
@class ZYBleDeviceInfo;
@class ZYControlCoder;

@interface ZYBleConnection : NSObject<ZYConnection>

/**
 设备状态

 - ZYBleDeviceStateUnknown: 未知状态
 - ZYBleDeviceStateConnected: 连上设备
 - ZYBleDeviceStateConnecting: 正在连接设备
 - ZYBleDeviceStateReady: 设备交互就绪
 - ZYBleDeviceStateMissConnected: 设备失去连接
 - ZYBleDeviceStateDisconnecting: 设备正在断开
 - ZYBleDeviceStateFail: 设备连接失败
 */
typedef NS_ENUM(NSInteger, ZYBleDeviceConnectionState) {
    ZYBleDeviceStateUnknown = 0,
    ZYBleDeviceStateConnected = 1,
    ZYBleDeviceStateConnecting = 2,
    ZYBleDeviceStateReady = 3,
    ZYBleDeviceStateMissConnected = 4,
    ZYBleDeviceStateDisconnecting = 5,
    ZYBleDeviceStateFail = 6,
};

@property (nonatomic, readonly, strong) CBPeripheral* curPeripheral;
/**
 记录最后一次与设备进行同步的值
 */
@property (nonatomic, weak) ZYBleDeviceDataModel* dataCache;
@property (atomic, readonly) ZYBleDeviceConnectionState connectState;
@property (nonatomic, readonly) NSInteger waitingRequestCount;
@property (nonatomic, readwrite, strong) ZYControlCoder* sendCoder;
@property (nonatomic, readwrite, strong) NSDate* lastRecvTimeStamp;
@property (nonatomic, readwrite, strong) NSDate* lastSendTimeStamp;
@property (nonatomic, readwrite) NSInteger maxAsynRequestCount;

/**
 连接指定的设备

 @param deviceInfo 蓝牙设备信息
 @param deviceStatusHandler 连接结果
 */
-(void) connectDevice:(ZYBleDeviceInfo*)deviceInfo withDispatcher:(ZYBleDeviceDispacther*)dispacther completionHandler:(void (^)(ZYBleDeviceConnectionState state))deviceStatusHandler;

/**
 断开连接
 */
-(void) disconnectDevice;


-(BOOL)canConnect;

-(BOOL)canDisconnect;

-(void)changeCoderIfNeed:(NSString*)coderName clsType:(Class) cls;

-(void)mindBlueToothNotify;
@end
