//
//  ZYBleDeviceInfo.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/9.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ZYConnectPriority) {
    ZYConnectPriorityNormal = 0,
    ZYConnectPriorityLow,
    ZYConnectPriorityHeight
};

@class CBPeripheral;

@interface ZYBleDeviceInfo : NSObject

/**
 最大的发送数据的长度
 */
@property (nonatomic) NSUInteger maxSendWithOutRespondLenth;
/**
 是通过系统设备获取到的蓝牙设备
 */
@property (nonatomic) BOOL isRetriveDevice;

/**

 蓝牙设备连接名字
 */
@property (nonatomic, readonly, copy) NSString* name;

/**
 蓝牙设备连接名字
 */
@property (nonatomic, readonly, copy) NSData* manufacturerData;

/**
 产品型号
 */
@property(nonatomic, readwrite, copy) NSString* modelNumberString;

/**
 UUID是否是16位
 */
@property (nonatomic, readonly) BOOL isAddress16;

/**
是否是OEM设备
 */
@property (nonatomic, readonly) BOOL isOEMDevice;

/**
 蓝牙设备对象
 */
@property (nonatomic, readonly, strong) CBPeripheral* peripheral;

/**
 信号强度显示比例[0, 100]
 */
@property (nonatomic, readonly) NSInteger showSignal;

/**
 校验设备连接名字是否符合ZY设备规范
 */
@property (nonatomic, readonly) BOOL nameValid;

/**
 校验设备是否是ZY设备
 */
@property (nonatomic, readonly) BOOL deviceValid;

/**
 OTA版本号
 */
@property (nonatomic, readonly, copy) NSString* otaVersion;

/**
 蓝牙设备唯一标识
 */
@property (nonatomic, readonly, copy) NSString* identifier;

@property(nonatomic, assign) ZYConnectPriority connectPriority ;

/**
 <#Description#>初始化对象

 @param name 设备名字
 @param peripheral 设备对象
 @return 设备信息对象
 */
-(instancetype) initWithNamePeripheralAndRSSI:(NSString*)name withPeripheral:(CBPeripheral*)peripheral withRSSI:(NSNumber*)RSSI;

/**
 <#Description#>更新厂商信息
 */
-(void)updateManufacturerData:(NSData*)data;

/**
 <#Description#>更新连接的设备的相关信息
 */
-(void)updateConnectedDeviceInfo;

/**
 <#Description#>信息是否最新
 */
-(BOOL)isDataNeedUpdate:(ZYBleDeviceInfo*)info;

/**
 <#Description#>记录本次更新时间
 */
-(void)recordUpdateDataTime;


/**
 对应Wi-Fi设备

 @param name 外部设置
 */
-(void)configName:(NSString *)name;


/**
 是否是支持HID的设备，如果是HID的设备需要屏蔽掉volume
 
 @return 设备
 */
-(BOOL)isHIDSupportDevice;

@end
