//
//  ZYBleDeviceCallBack.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/3/31.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//连接设备成功的block
typedef void (^ZYBleConnectedPeripheralBlock)(CBCentralManager *central);
//连接设备失败的block
typedef void (^ZYBleFailToConnectBlock)(CBCentralManager *central, NSError *error);
//断开设备连接的bock
typedef void (^ZYBleDisconnectBlock)(CBCentralManager *central, NSError *error);
//找到Characteristics的block
typedef void (^ZYBleDiscoverCharacteristicsBlock)(CBService *service, NSError *error);
//读取 Characteristics的value的block
typedef void (^ZYBleReadValueForCharacteristicBlock)(CBCharacteristic *characteristic, NSError *error);
//写入 Characteristics的value的block
typedef void (^ZYBleDidWriteValueForCharacteristicBlock)(CBCharacteristic *characteristic, NSError *error);
//characteristic 通知状态改变的block
typedef void (^ZYBleDidUpdateNotificationStateForCharacteristicBlock)(CBCharacteristic *characteristic, NSError *error);

//获取Characteristics的名称
typedef void (^ZYDiscoverDescriptorsForCharacteristicBlock)(CBPeripheral *peripheral,CBCharacteristic *service,NSError *error);
typedef void (^ZYDiscoverDescriptorsOnReadValueForDescriptorsBlcok)(CBPeripheral *peripheral,CBDescriptor *descriptor,NSError *error);

@interface ZYBleDeviceCallBack : NSObject

@property(nonatomic, readwrite, copy) ZYBleConnectedPeripheralBlock connectedPeripheralBlock;
@property(nonatomic, readwrite, copy) ZYBleFailToConnectBlock failToConnectBlock;
@property(nonatomic, readwrite, copy) ZYBleDisconnectBlock disconnectBlock;
@property(nonatomic, readwrite, copy) ZYBleDiscoverCharacteristicsBlock discoverCharacteristicsBlock;
@property(nonatomic, readwrite, copy) ZYBleReadValueForCharacteristicBlock readValueForCharacteristicBlock;
@property(nonatomic, readwrite, copy) ZYBleDidWriteValueForCharacteristicBlock didWriteValueForCharacteristicBlock;
@property(nonatomic, readwrite, copy) ZYBleDidUpdateNotificationStateForCharacteristicBlock didUpdateNotificationStateForCharacteristicBlock;
@property(nonatomic, readwrite, copy) ZYDiscoverDescriptorsForCharacteristicBlock didDiscoverDescriptorsForCharacteristicBlock;
@property(nonatomic, readwrite, copy) ZYDiscoverDescriptorsOnReadValueForDescriptorsBlcok didDiscoverDescriptorsOnReadValueForDescriptorsBlock;

@end
