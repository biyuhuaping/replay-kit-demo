//
//  ZYBleDeviceDispacther.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/3/31.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBleDeviceCallBack.h"

@interface ZYBleDeviceDispacther : NSObject

-(void) setConnectedPeripheralBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleConnectedPeripheralBlock)block;
-(void) setFailToConnectBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleFailToConnectBlock)block;
-(void) setDisconnectBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleDisconnectBlock)block;
-(void) setDiscoverCharacteristicsBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleDiscoverCharacteristicsBlock)block;
-(void) setReadValueForCharacteristicBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleReadValueForCharacteristicBlock)block;
-(void) setDidWriteValueForCharacteristicBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleDidWriteValueForCharacteristicBlock)block;
-(void) setDidUpdateNotificationStateForCharacteristicBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleDidUpdateNotificationStateForCharacteristicBlock)block;
-(void) setDidDiscoverDescriptorsForCharacteristicBlock:(CBPeripheral *)peripheral atChannel:(NSString*)channel withBlock:(ZYDiscoverDescriptorsForCharacteristicBlock)block;
-(void) setDidDiscoverDescriptorsOnReadValueForDescriptorsBlock:(CBPeripheral *)peripheral atChannel:(NSString*)channel withBlock:(ZYDiscoverDescriptorsOnReadValueForDescriptorsBlcok)block;

-(void) prepare;
-(void) recordCharacteristicForPeripheral:(CBPeripheral*)peripheral withCharacteristic:(CBCharacteristic*)characteristic;
-(void) removeChannelForPeripheral:(CBPeripheral*)peripheral;

@end
