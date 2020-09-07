//
//  ZYBleDeviceInfo.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/9.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBleDeviceInfo.h"

@class CBCharacteristic;

@interface ZYBleDeviceInfo(internal)
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
 <#Description#>更新值
 */
-(void)updateValueFromCharacteristic:(CBCharacteristic*)characteristic;

@end
