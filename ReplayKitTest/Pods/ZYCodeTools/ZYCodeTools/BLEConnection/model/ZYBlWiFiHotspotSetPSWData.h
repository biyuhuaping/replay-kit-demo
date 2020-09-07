//
//  ZYBlWiFiHotspotSetPSWData.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/17.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiHotspotSetPSWData : ZYBlData
/**
 设置SSID 中的status
 */
@property (nonatomic, readonly) NSUInteger wifiStatus;

/**
 设置密码 中的password
 */
@property (nonatomic,  readwrite, strong) NSString* password;

@end
