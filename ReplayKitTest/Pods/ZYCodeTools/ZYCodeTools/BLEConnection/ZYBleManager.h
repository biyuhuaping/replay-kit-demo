//
//  ZYBleManager.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/9/27.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBleDeviceInfo_internal.h"
#import "ZYBleConnection.h"

NS_ASSUME_NONNULL_BEGIN
/**
 蓝牙设备的状态
 
 - ZYBleStateUnknown: 未知
 - ZYBleStateResetting: 重连或正在连接
 - ZYBleStateUnsupported: 不支持
 - ZYBleStateUnauthorized: 未授权
 - ZYBleStatePoweredOff: 关闭
 - ZYBleStatePoweredOn: 打开
 - ZYBleEndScan: 扫描结束
 */

typedef NS_ENUM(NSInteger, ZYBleState) {
    ZYBleStateUnknown = 0,
    ZYBleStateResetting,
    ZYBleStateUnsupported,
    ZYBleStateUnauthorized,
    ZYBleStatePoweredOff,
    ZYBleStatePoweredOn,
    ZYBleStateEndScan
};

@interface ZYBleManager : NSObject

/**
 真的连接dsb
 */
@property (nonatomic)         BOOL virtualConnect;


/**
 初始化对象

 @param connection 连接
 @return 返回对象
 */
+ (instancetype)bleManagerWithBleConnection:(ZYBleConnection *)connection;


/**
 当前连接的设备信息
 */
@property (nonatomic, readonly, strong) ZYBleDeviceInfo* curDeviceInfo;

/**
 是否能够发送指令
 */
@property (nonatomic, readonly) BOOL deviceReady;

/**
 当前设备的状态
 */
@property (nonatomic, readonly) ZYBleState deviceState;

/**
 扫描蓝牙状态及其周围可用的蓝牙外设
 
 @param bleStatusHandler 蓝牙状态扫描结果
 @param deviceHandler 周围外设捕获结果
 */
-(void) scanDevice:(void (^)(ZYBleState state))bleStatusHandler deviceHandler:(void (^)(ZYBleDeviceInfo* deviceInfo))deviceHandler;
//获取到连接的设备
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
-(void) connectDevice:(ZYBleDeviceInfo*)deviceInfo completionHandler:(void (^)(ZYBleDeviceConnectionState state))deviceStatusHandler;


/**
 断开连接
 */
-(void) disconnectDevice:(void (^)(void))handler;

@end

NS_ASSUME_NONNULL_END
