//
//  ZYBlWiFiConnectionData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiConnectionData : ZYBlData

/**
 <#Description#>设备信息 对应连接设备中的DEV_SSID
 */
@property (nonatomic, readwrite, copy) NSString* ssid;

/**
 <#Description#>密码 对应连接设备中的DEV_PASSWORD
 */
@property (nonatomic, readwrite, copy) NSString* pwd;

/**
 <#Description#>标识 对应连接设备中的0x01
 */
@property (nonatomic, readonly) NSUInteger flag;

@end
