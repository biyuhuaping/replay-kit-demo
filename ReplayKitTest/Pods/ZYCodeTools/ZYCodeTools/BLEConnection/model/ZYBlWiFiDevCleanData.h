//
//  ZYBlHandleData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiDevCleanData : ZYBlData

/**
 <#Description#>设备信息 对应清除连接设备信息中的DEV_SSID
 */
@property (nonatomic, readwrite, copy) NSString* ssid;
/**
 <#Description#>结果 对应清除连接设备信息中的0x01
 */
@property (nonatomic, readonly) NSUInteger flag;

@end
