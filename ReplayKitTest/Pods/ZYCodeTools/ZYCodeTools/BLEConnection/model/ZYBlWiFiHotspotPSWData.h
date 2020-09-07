//
//  ZYBlWiFiHotspotPSWData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiHotspotPSWData : ZYBlData
/**
 获取wifi SSID 中的status
 */
@property (nonatomic, readonly) NSUInteger wifiStatus;

/**
 获取wifi模块密码 中的密码
 */
@property (nonatomic, readonly, strong) NSString* PSW;

@end
