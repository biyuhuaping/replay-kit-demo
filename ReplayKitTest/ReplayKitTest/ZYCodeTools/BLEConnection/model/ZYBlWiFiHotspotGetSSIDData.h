//
//  ZYBlWiFiHotspotResetData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiHotspotGetSSIDData : ZYBlData
/**
 获取wifi SSID 中的status
 */
@property (nonatomic, readonly) NSUInteger wifiStatus;

/**
 获取wifi SSID 中的ssid
 */
@property (nonatomic, readonly, strong) NSString* SSID;

@end
