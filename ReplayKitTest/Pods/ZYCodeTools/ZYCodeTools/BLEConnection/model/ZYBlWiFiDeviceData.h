//
//  ZYBlWiFiDeviceData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiDeviceData : ZYBlData

/**
 <#Description#>序号 对应扫描到的设备信息中的SEND_NUM
 */
@property (nonatomic, readwrite) NSUInteger num;

/**
 <#Description#>设备信息 对应扫描到的设备信息中deDEV_SSID
 */
@property (nonatomic, readonly, copy) NSString* ssid;

@end
