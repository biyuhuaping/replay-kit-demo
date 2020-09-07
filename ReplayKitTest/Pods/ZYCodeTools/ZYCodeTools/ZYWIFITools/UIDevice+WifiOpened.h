//
//  UIDevice+WifiOpened.h
//  ZYCamera
//
//  Created by lgj on 2018/5/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (WifiOpened)

/*!
 wifi 是否打开

 @return wifi打开了
 */
+(BOOL) isWiFiOpened;

/*!
 获得Wi-Fi的名字

 @return Wi-Fi的名字
 */
+ (NSString *)getWifiName;

///*!
// 获得所有Wi-Fi的名字
// 
// @return 所有Wi-Fi的名字
// */
//+ (NSArray *)getAllWifiName;

//获取设备当前网络IP地址,没有分配的时候返回nil
+(NSString *)getIPAddress:(BOOL)preferIPv4;

/**
 获取Wi-Fi列表

 @return 返回Wi-Fi的ssid列表
 */
+(NSMutableArray *)getWifiList;
@end
