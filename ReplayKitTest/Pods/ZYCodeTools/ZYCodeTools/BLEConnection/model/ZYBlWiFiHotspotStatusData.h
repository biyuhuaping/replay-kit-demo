//
//  ZYBlWiFiHotspotStatusData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiHotspotStatusData : ZYBlData
/**
 获取wifi模块状态 中的status
 */
@property (nonatomic, readonly) NSUInteger wifiStatus;

@end
