//
//  ZYBlWiFiHotspotDHCPCleanData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiHotspotDHCPCleanData : ZYBlData
/**
 清除DHCP池中的设备信息 中的status
 */
@property (nonatomic, readonly) NSUInteger wifiStatus;

@end
